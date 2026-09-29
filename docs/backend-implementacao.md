# Backend: implementação dos recursos do app Hard Rock

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
| `MemberProfile` | `MemberProfiles` | `CustomerUserId` (FK única), `Level` (Founder/Legacy/Discovery), `MemberNumber` (string, único), `MemberSince`, `CardToken` (string único, opaco, 16+ chars aleatórios), `CardTokenRotatedAt` | `AddMemberProfiles` |
| `TravelProfile` | `TravelProfiles` | `CustomerUserId` (FK única), `HomeCity`, `HomeState`, `PreferredDestinationsJson` (até 4), `UpdatedAt` | `AddTravelProfiles` |
| `NotificationPreference` | `NotificationPreferences` | `CustomerUserId` (FK única), `MilesOffers` (bool), `Announcements` (bool), `UpdatedAt` | `AddNotificationPreferences` |
| `Partner` | `Partners` | `Name`, `Category`, `City`, `State`, `DiscountPercent`, `DiscountText`, `Terms`, `ValidationType`, `CouponCode`, `PartnerCode` (único), `PartnerPinHash`, `LogoUrl`, `ImageUrl`, `Address`, `UsageLimitPerCustomer?`, `ValidUntil?`, `IsActive`, `CreatedAt` | `AddPartners` |
| `BenefitRedemption` | `BenefitRedemptions` | `CustomerUserId`, `PartnerId`, `Source` (qr/coupon/card), `UsedAt`, `Note`, `IpAddress` | `AddBenefitRedemptions` |
| `CertificateRequest` | `CertificateRequests` | `CustomerUserId`, `Type`, `Status`, `Protocol` (único, `CERT-yyyy-nnnnnn`), `CrmIncidentId`, `PreferredDestination`, `PreferredPeriod`, `Notes`, `CertificateCode`, `AdminNotes`, `RequestedAt`, `UpdatedAt`, `HandledByAdminId?` | `AddCertificateRequests` |
| `Offer` | `Offers` | `Title`, `Subtitle`, `Description`, `Category`, `ImageUrl`, `IsFeatured`, `CtaLabel`, `CtaUrl`, `PartnerId?`, `ValidFrom?`, `ValidUntil?`, `IsActive`, `CreatedByAdminId` | `AddOffers` |
| `MilesEntry` | `MilesEntries` | `CustomerUserId`, `Amount` (int, +/-), `Description`, `CreatedAt`, `CreatedByAdminId?` | `AddMilesEntries` |
| `MilesOffer` | `MilesOffers` | `ExternalId` (único), `Title`, `Summary`, `Destination`, `Program`, `SourceGroup`, `Url`, `CapturedAt`, `ExpiresAt?`, `IsActive` | `AddMilesOffers` |
| `CollectionItem` | `CollectionItems` | `CustomerUserId`, `Index` (1..6), `Status` (locked/unlocked/sent), `UnlockedAt?`, `ShippedAt?`, `TrackingCode?` | `AddCollectionItems` |
| `DeviceToken` | `DeviceTokens` | `CustomerUserId`, `Token` (único), `Platform`, `AppVersion`, `DeviceModel`, `CreatedAt`, `LastSeenAt` | `AddDeviceTokens` |
| `UnityInterest` | `UnityInterests` | `CustomerUserId`, `CrmActivityId?`, `CreatedAt` | `AddUnityInterests` |

Registrar todos como `DbSet<>` em `Data/ApplicationDbContext.cs`. Índices únicos: `MemberProfiles.CardToken`, `MemberProfiles.MemberNumber`, `Partners.PartnerCode`, `DeviceTokens.Token`, `MilesOffers.ExternalId`, `CertificateRequests.Protocol`.

## 2. Serviços (`Services/`)

| Serviço | Responsabilidade |
|---|---|
| `MemberCardService` | Cria `MemberProfile` sob demanda no primeiro acesso (`MemberNumber` sequencial a partir de 8000, `CardToken` aleatório via `RandomNumberGenerator`); calcula `Status`: `inactive` se `FinancialDataCache.TotalOverdue > 0` para o documento ou se `CustomerCostCenter.ContractSituation` indicar cancelado; conta `BenefitRedemptions`. |
| `BenefitService` | Lista parceiros ativos; valida PIN (`PartnerPinHash`, usar o mesmo hasher de senha do projeto); aplica `UsageLimitPerCustomer`; registra `BenefitRedemption`; gera cupom (`CouponCode` do parceiro). |
| `CertificateService` | Gera `Protocol`; chama `DynamicsService` para abrir incidente com título `"Certificado de viagem {tipo} - {nome} - {protocolo}"` e guarda `CrmIncidentId`; um pedido `requested/in_progress` por tipo por cliente. |
| `CollectionService` | Regra do kit: elegível se o contrato (em `CustomerCostCenter`) for de 6 semanas (campo/flag a definir com o Comercial); item 1 desbloqueia com a entrada (5%) paga, itens 2..6 com cada parcela seguinte paga em dia (`FinancialItemsCache` ordenado por `DueDate`, `IsPaid = true`). Recalcula ao consultar; `sent` só via admin. |
| `MilesService` | Saldo = soma de `MilesEntries`; lista `MilesOffers` ativas, filtrando por `TravelProfile.PreferredDestinations` quando houver. |
| `DeviceTokenService` | Upsert por token; usado por `FirebaseService` para envio direcionado (`SendMulticastAsync` com tokens do usuário) além do envio por tópico existente. |

Registrar em `Program.cs`: `builder.Services.AddScoped<...>()` para cada um (padrão do projeto, classes concretas).

## 3. Controllers (`Api/Controllers`)

| Controller | Rota base | Política | Endpoints |
|---|---|---|---|
| `MembersController` | `api/members` | `ClientOnly` | `GET me/card`, `GET/PUT me/travel-profile`, `GET/PUT me/notification-preferences`, `GET me/redemptions`, `GET me/miles`, `GET me/collection` |
| `CardController` | `api/card` | `[AllowAnonymous]` | `GET verify/{token}`, `POST verify/{token}/redemptions` |
| `PartnersController` | `api/partners` | `ClientOnly` | `GET`, `GET {id}`, `POST {id}/coupon` |
| `CertificatesController` | `api/certificates` | `ClientOnly` | `GET requests`, `POST requests`, `GET requests/{id}` |
| `OffersController` | `api/offers` | `ClientOnly` | `GET`, `GET {id}` |
| `MilesController` | `api/miles` | `ClientOnly` | `GET offers` |
| `DevicesController` | `api/devices` | `[Authorize]` | `POST`, `DELETE {token}` |
| `UnityController` | `api/unity` | `ClientOnly` | `POST interest` |
| `VenturesController` (existente) | `api/ventures` | `ClientOnly` | adicionar `GET {id}/videos` a partir de `VenturePhoto` com `MediaType == "video"` |
| `AdminHardRockController` | `api/admin` | `AdminOnly` (+ `X-Robot-Key` em `miles/offers`) | `partners` CRUD, `offers` CRUD, `members/{id}/level`, `certificates/requests/{id}/status`, `collection/{id}/items/{index}/shipped`, `miles/offers`, `miles/{id}/entries` |

`CardController` e a página pública ficam fora do `DynamicAuth` de cookie: manter sob `/api` e usar `[AllowAnonymous]` como `FaqsController`.

## 4. Página pública do QR (`Pages/Card/Index.cshtml`)

Rota `/card/{token}`. Razor Page simples, sem login, que chama `MemberCardService` e mostra: nome (primeiro), nível, status em verde/vermelho, contagem de usos e um formulário "Registrar uso" (código e PIN do parceiro) que faz `POST /api/card/verify/{token}/redemptions`. É o que o parceiro vê ao escanear com a câmera do celular. O cartão físico impresso usa o mesmo `verifyUrl`.

## 5. Notificações

- `POST /api/admin/miles/offers` (robô) grava `MilesOffer` e chama `FirebaseService.SendToUsersAsync(userIds, title, body, data)` para os clientes com `NotificationPreference.MilesOffers = true` (e, se houver `TravelProfile`, com destino compatível). Precisa de `DeviceTokens`.
- Manter o envio por tópico `announcements` para avisos gerais.

## 6. Ordem de entrega (alinhada ao cronograma do app)

| Até | Entregar em homolog |
|---|---|
| 16/10 | Ambiente `portal_homolog` correto; `MemberProfiles` + `GET members/me/card`; `DeviceTokens` + `POST /devices`; `GET ventures/{id}/videos`; URL pública de "esqueci a senha" |
| 23/10 | `CardController` + página `/card/{token}` + `limit_req`; `Partners`, `BenefitRedemptions`, `PartnersController`, admin de parceiros |
| 30/10 | `CertificateRequests` + Dynamics; `Offers` + admin; `UnityController` |
| 06/11 | `TravelProfiles`, `NotificationPreferences`, `MilesEntries`, `MilesOffers` + endpoint do robô + push direcionado |
| 13/11 | `CollectionItems` + `CollectionService` (após regra por escrito) |

## 7. Checklist por endpoint (padrão do projeto)

- [ ] DTOs próprios, nunca a entidade EF.
- [ ] `try/catch` com `StatusCode(500, new ApiResponse<T>{ Success=false, Message="Erro interno do servidor" })`.
- [ ] `ILogger` com evento no sucesso e erro.
- [ ] Testar sem token (401 JSON), com token de cliente e com token de admin.
- [ ] Migration gerada com `dotnet ef migrations add <Nome>` e revisada antes do deploy (o startup aplica sozinho).
- [ ] Adicionar a rota ao `openapi-hardrock.yaml` se divergir do contrato.
