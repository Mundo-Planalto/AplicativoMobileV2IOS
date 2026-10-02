# Backend: implementação dos recursos do app Mundo Planalto (clube de férias)

> **Atualizado em 02/10/2026** com a revisão do CEO de 01/10 (`docs/revisao-ceo-01-10.md`, seção 3): certificados por cliente com protocolo e SLA, campanhas no lugar de ofertas, perfil de viagem com próxima viagem e histórico, alteração de dados, redes sociais do empreendimento e sessão longa. **Milhas e Collection saíram da V1.**

Guia para implementar, no repositório `Mundo-Planalto/MundoPlanaltoPortal` (.NET 10, EF Core, PostgreSQL), os endpoints definidos em [`openapi-hardrock.yaml`](openapi-hardrock.yaml). Segue o padrão do projeto levantado em 28/09/2026: controller por recurso em `Api/Controllers`, DTOs em `Api/DTOs`, entidades em `Models/Core`, envelope `ApiResponse<T>`, políticas `ClientOnly`/`AdminOnly`, soft delete por `IsActive`.

## 0. Pré-requisitos (antes de qualquer endpoint)

1. **Homologação de verdade.** Substituir o processo que roda de `/root/.local/share/Trash/files/portal_dev` por:
   - `dotnet publish -c Release -o /opt/portal-homolog/app` a partir do branch `dev`;
   - banco `mundo_planalto_portal_homolog` (nunca o de produção);
   - `portal_homolog.service` (cópia de `portal.service` com `WorkingDirectory=/opt/portal-homolog/app`, `ASPNETCORE_URLS=http://0.0.0.0:5083`, `ASPNETCORE_ENVIRONMENT=Staging`);
   - o Nginx de `api.portal.mundoplanalto.com.br` já aponta para 5083.
2. **Fechar o que o QR público vai expor:** remover `GET /api/customers/debug/ventures/{cpf}`; `limit_req` no Nginx para `/api/card/`, `/api/faqs`, `/api/tickets`, `/api/customers/external-support-request`; restringir `6379` e `6432` no ufw.
3. **Segredos fora do `appsettings.json`:** `Environment=` no systemd ou `dotnet user-secrets`; trocar a senha do Postgres.
4. **Branch `feature/app-hardrock`** a partir de `dev`; uma migration por entidade, nomes abaixo.

## 1. Entidades novas (`Models/Core`) e migrations

| Entidade | Tabela | Campos principais | Migration |
|---|---|---|---|
| `MemberProfile` | `MemberProfiles` | `CustomerUserId` (FK única), `Level` (Founder/Legacy/Discovery; a Central de Contratos define), `MemberNumber` (string, único), `MemberSince`, `CardToken` (único, opaco, 16+ chars aleatórios), `CardTokenRotatedAt`, `ClubName` (padrão "Mundo Planalto") | `AddMemberProfiles` |
| `TravelProfile` | `TravelProfiles` | `CustomerUserId` (FK única), `HomeCity`, `HomeState`, `PreferredDestinationsJson` (até 4), `NextTripWhen` (within_6_months/within_1_year/more_than_1_year/unknown), `NextTripDestination`, `Source` (pep/app), `UpdatedAt` | `AddTravelProfiles` |
| `TravelProfileHistory` | `TravelProfileHistory` | `CustomerUserId`, snapshot JSON do perfil, `Source`, `ChangedAt` | `AddTravelProfileHistory` |
| `NotificationPreference` | `NotificationPreferences` | `CustomerUserId` (FK única), `Campaigns` (bool, opt-in único do app), `Announcements` (bool), `UpdatedAt` | `AddNotificationPreferences` |
| `Partner` | `Partners` | `Name`, `Category`, `City`, `State`, `DiscountPercent`, `DiscountText`, `Terms`, `ValidationType`, `CouponCode`, `PartnerCode` (único), `PartnerPinHash`, `LogoUrl`, `ImageUrl`, `Address`, `UsageLimitPerCustomer?`, `ValidUntil?`, `IsFeatured` (máx. 2 por empreendimento), `IsActive`, `CreatedAt` + tabela de junção `PartnerVentures` | `AddPartners` |
| `BenefitRedemption` | `BenefitRedemptions` | `CustomerUserId`, `PartnerId`, `Source` (qr/coupon/card), `UsedAt`, `Note`, `IpAddress` | `AddBenefitRedemptions` |
| `Certificate` | `Certificates` | `CustomerUserId`, `ContractId`/`CostCenterId`, `Name` (como a Central cadastrou), `Type` (rci/maisviagens/gift), `Quantity`, `Status` (available/requested/released/used/expired), `ExpiresAt`, `Protocol?` (único, `CERT-yyyy-nnnnnn`), `CrmIncidentId?`, `Code?`, `UseUrl?`, `RequestedAt?`, `ReleasedAt?`, `UsedAt?`, `HandledByAdminId?` | `AddCertificates` |
| `Campaign` | `Campaigns` | `Category` (livre), `Title`, `Subtitle`, `ImageUrl`, `ValidUntil?`, `CtaLabel`, `CtaType` (online/postsales/whatsapp/link/certificate), `CtaUrl?`, `WhatsappNumber?`, `WhatsappMessage?`, `IsFeatured`, `IsActive`, `CreatedByAdminId` + junção `CampaignVentures` | `AddCampaigns` |
| `CampaignInterest` | `CampaignInterests` | `CampaignId`, `CustomerUserId`, `ClickedAt`, `CrmIncidentId?`, `ConvertedAt?` | `AddCampaignInterests` |
| `ChangeRequest` | `ChangeRequests` | `CustomerUserId`, `Field` (address/phone/email), `NewValue`, `Status` (pending/approved/rejected), `AdminNotes`, `CreatedAt`, `ProcessedAt?`, `ProcessedByAdminId?` | `AddChangeRequests` |
| `DeviceToken` | `DeviceTokens` | `CustomerUserId`, `Token` (único), `Platform`, `AppVersion`, `DeviceModel`, `CreatedAt`, `LastSeenAt` | `AddDeviceTokens` |
| `CostCenter` (existente) | — | acrescentar `City`, `State`, `InstagramUrl`, `YoutubeUrl`, `WhatsappChannelUrl` | `AddVentureSocialLinks` |

Registrar todos como `DbSet<>` em `Data/ApplicationDbContext.cs`. Índices únicos: `MemberProfiles.CardToken`, `MemberProfiles.MemberNumber`, `Partners.PartnerCode`, `DeviceTokens.Token`, `Certificates.Protocol`.

Saíram da V1 (não criar): `MilesEntry`, `MilesOffer`, `CollectionItem`, `Offer`, `CertificateRequest` (substituído por `Certificate`).

## 2. Serviços (`Services/`)

| Serviço | Responsabilidade |
|---|---|
| `MemberCardService` | Cria `MemberProfile` sob demanda no primeiro acesso (`MemberNumber` sequencial a partir de 8000, `CardToken` aleatório via `RandomNumberGenerator`); calcula `Status`: `inactive` se `FinancialDataCache.TotalOverdue > 0` para o documento ou se `CustomerCostCenter.ContractSituation` indicar cancelado; conta `BenefitRedemptions`; devolve `ClubName`. |
| `BenefitService` | Lista parceiros ativos **filtrados pelos empreendimentos do cliente** (`PartnerVentures`), com no máximo 2 `IsFeatured`; valida PIN (`PartnerPinHash`, mesmo hasher de senha do projeto); aplica `UsageLimitPerCustomer`; registra `BenefitRedemption`; gera cupom (`CouponCode` do parceiro). |
| `CertificateService` | Lista os certificados do cliente; em `request` gera `Protocol`, chama `DynamicsService` para abrir ocorrência `"Certificado {nome} - {cliente} - {protocolo}"`, guarda `CrmIncidentId` e devolve `slaHours` (parametrizado, padrão 48). Job diário: SLA estourado → e-mail ao responsável do Pós-vendas; `ExpiresAt` vencido → `expired`. Na liberação (`released`) dispara push "Seu certificado foi liberado" e cria aviso. |
| `CampaignService` | Lista campanhas ativas filtradas por empreendimento (`CampaignVentures`); `interest` grava `CampaignInterest` e, para `ctaType` online/postsales, abre ocorrência no CRM; expõe contagem de cliques e conversão por campanha no admin. |
| `TravelProfileService` | Cria o perfil a partir das respostas do PEP (`Source = pep`); cada `PUT` grava `TravelProfileHistory` e marca `Source = app`. |
| `ChangeRequestService` | Cria solicitação de alteração (address/phone/email); aprovação pela Central aplica o dado no Sienge/CRM e dispara push "Sua solicitação de alteração foi aprovada". Generaliza o fluxo de `address/change-request` existente. |
| `DeviceTokenService` | Upsert por token; usado por `FirebaseService` para envio direcionado (`SendMulticastAsync` com tokens do usuário) além do envio por tópico existente. |

Registrar em `Program.cs`: `builder.Services.AddScoped<...>()` para cada um (padrão do projeto, classes concretas).

## 3. Controllers (`Api/Controllers`)

| Controller | Rota base | Política | Endpoints |
|---|---|---|---|
| `MembersController` | `api/members` | `ClientOnly` | `GET me/card`, `GET me/certificates`, `GET/PUT me/travel-profile`, `GET/PUT me/notification-preferences`, `GET me/redemptions` |
| `CardController` | `api/card` | `[AllowAnonymous]` | `GET verify/{token}`, `POST verify/{token}/redemptions` |
| `PartnersController` | `api/partners` | `ClientOnly` | `GET`, `GET {id}`, `POST {id}/coupon` |
| `CertificatesController` | `api/certificates` | `ClientOnly` | `POST {id}/request` |
| `CampaignsController` | `api/campaigns` | `ClientOnly` | `GET`, `POST {id}/interest` |
| `CustomersController` (existente) | `api/customers` | `ClientOnly` | adicionar `GET change-requests`, `POST change-requests` |
| `AuthController` (existente) | `api/auth` | `[Authorize]` | adicionar `POST refresh` **ou** emitir JWT de cliente com validade longa (ex.: 180 dias) para a sessão fixa |
| `DevicesController` | `api/devices` | `[Authorize]` | `POST`, `DELETE {token}` |
| `VenturesController` (existente) | `api/ventures` | `ClientOnly` | `GET` passa a devolver `city`, `state`, `instagramUrl`, `youtubeUrl`, `whatsappChannelUrl`; adicionar `GET {id}/videos` (a partir de `VenturePhoto` com `MediaType == "video"`) e `GET {id}/financial` (resumo filtrado) |
| `AdminClubController` | `api/admin` | `AdminOnly` | `partners` CRUD, `campaigns` CRUD, `members/{id}/level`, `PATCH certificates/{id}` (status, code, useUrl), `PATCH change-requests/{id}`, `GET members/{id}/travel-profile/history`, cadastro de certificados por contrato (Central de Contratos) |

`CardController` e a página pública ficam fora do `DynamicAuth` de cookie: manter sob `/api` e usar `[AllowAnonymous]` como `FaqsController`.

## 4. Página pública do QR (`Pages/Card/Index.cshtml`)

Rota `/card/{token}`. Razor Page simples, sem login, que chama `MemberCardService` e mostra: nome (primeiro), nível, status em verde/vermelho, contagem de usos e um formulário "Registrar uso" (código e PIN do parceiro) que faz `POST /api/card/verify/{token}/redemptions`. É o que o parceiro vê ao escanear com a câmera do celular. O cartão físico impresso usa o mesmo `verifyUrl`.

## 5. Notificações

- Liberação de certificado (`PATCH /api/admin/certificates/{id}` com `status = released`): `FirebaseService.SendToUsersAsync` para o cliente com "Seu certificado foi liberado" + aviso em `announcements` do usuário. Precisa de `DeviceTokens`.
- Aprovação de alteração de dados: push "Sua solicitação de alteração foi aprovada".
- Campanhas novas: push para os clientes com `NotificationPreference.Campaigns = true` dos empreendimentos da campanha.
- Manter o envio por tópico `announcements` para avisos gerais.

## 6. Ordem de entrega (alinhada ao cronograma do app)

| Até | Entregar em homolog |
|---|---|
| 16/10 | Ambiente `portal_homolog` correto; JWT longo ou `POST auth/refresh` (sessão fixa); `MemberProfiles` + `GET members/me/card` (com `clubName`); `DeviceTokens` + `POST /devices`; `GET ventures` com cidade/UF e redes sociais; `GET ventures/{id}/videos`; URL pública de "esqueci a senha" |
| 23/10 | `Certificates` + `GET members/me/certificates` + `POST certificates/{id}/request` com Dynamics e SLA + `PATCH admin/certificates/{id}` + cadastro pela Central; `CardController` + página `/card/{token}` + `limit_req` |
| 30/10 | `Partners` (com `IsFeatured` e `PartnerVentures`), `BenefitRedemptions`, `PartnersController`, admin de parceiros; `Campaigns` + `CampaignInterests` + admin de campanhas |
| 06/11 | `TravelProfiles` + `TravelProfileHistory` (carga inicial do PEP); `NotificationPreferences`; `ChangeRequests` + aprovação pela Central; `GET ventures/{id}/financial`; push direcionado |
| 13/11 | Ajustes de homologação com o app (Build 2 de 01/11) e relatórios de cliques/conversão de campanhas |

## 7. Checklist por endpoint (padrão do projeto)

- [ ] DTOs próprios, nunca a entidade EF.
- [ ] `try/catch` com `StatusCode(500, new ApiResponse<T>{ Success=false, Message="Erro interno do servidor" })`.
- [ ] `ILogger` com evento no sucesso e erro.
- [ ] Testar sem token (401 JSON), com token de cliente e com token de admin.
- [ ] Migration gerada com `dotnet ef migrations add <Nome>` e revisada antes do deploy (o startup aplica sozinho).
- [ ] Adicionar a rota ao `openapi-hardrock.yaml` se divergir do contrato.
