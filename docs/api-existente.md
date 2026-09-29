# API existente do portal (o que o iOS consome já hoje)

Backend: ASP.NET Core (.NET 10) + EF Core + PostgreSQL, repositório `Mundo-Planalto/MundoPlanaltoPortal`. Sem Swagger; o app iOS existente já tem os modelos e chamadas destes endpoints. A referência Android fica em `network/models/*.kt` e `network/api/ApiService.kt` do repositório `Mundo-Planalto/AplicativoMobileV2`.

## Ambientes

| Ambiente | Base URL | Observação |
|---|---|---|
| Homologação | `https://api.portal.mundoplanalto.com.br/api/` | Use para desenvolvimento |
| Produção | `https://portal.mundoplanalto.com.br/api/` | Só com cliente real e cuidado |

Configurar em `Config.plist` (`API_BASE_URL`), com `Config.example.plist` commitado.

## Convenções

- `Authorization: Bearer <jwt>` em tudo, exceto login, register, reset-password, faqs, tickets (POST) e external-support-request.
- Envelope `ApiResponse<T>`: `{ "success": bool, "message": string?, "data": T? }`. Alguns endpoints antigos devolvem o objeto direto (ex.: `address/change-requests` devolve lista pura; `dashboard` devolve `CustomerDashboardResponse`). Conferir cada DTO Kotlin.
- Erros sob `/api` sempre em JSON: `{ success:false, message, statusCode }`. 401 = token inválido/expirado → voltar ao Login.
- JWT do cliente expira em 7 dias. Claims: `NameIdentifier` (id), `Name`, `Document`, `DocumentType`, `IsAdmin=false`.
- Documento (CPF/CNPJ) sempre sem máscara.

## Endpoints usados pelo app

| Método | Rota | Corpo / retorno | Tela |
|---|---|---|---|
| POST | `auth/login` | `LoginRequest { document, password }` → `LoginResponse` (token, user) | Login |
| POST | `auth/register` | `RegisterRequest` (primeiro acesso) | Primeiro acesso |
| POST | `auth/reset-password` | `{ "email": "..." }` | Esqueci a senha |
| POST | `auth/change-password` | `{ "currentPassword", "newPassword" }` | Perfil → Segurança |
| GET | `auth/me` | `ApiResponse<UserData>` | Sessão |
| GET | `customers/data` | `ApiResponse<CustomerProfileApiData>` (nome, documento, e-mail, telefone, endereço) | Perfil |
| GET | `dashboard/client` | `CustomerDashboardResponse` (financeiro + empreendimentos + avisos consolidados) | Início (dados reais) |
| GET | `ventures` | `ApiResponse<List<Venture>>` | Empreendimentos |
| GET | `ventureupdates/venture/{ventureId}` | atualizações de obra (fotos, vídeos YouTube, descrição) | Detalhes |
| GET | `financial/resumo` | `ApiResponse<FinancialResumoData>` (total em atraso, a vencer, próximo vencimento) | Início, Financeiro |
| GET | `financial/extrato?showPaid=true` | parcelas (`ExtratoItem`: vencimento, valor, saldo, pago, atrasado, boleto gerado) | Extrato |
| POST | `financial/refresh` | força atualização do cache no Sienge | Pull-to-refresh |
| GET | `financial/boleto-data/{billReceivableId}/{installmentId}` | linha digitável e URL do PDF (Sienge) | Boleto |
| GET | `financial/boleto-data/esolution/{esolutionBoletoId}` | idem, sistema legado | Boleto |
| GET | `incometax/years` / POST `incometax/generate/{year}` | anos e PDF do informe | Informe de rendimentos |
| GET | `announcements` / `announcements/{id}` | avisos e notícias | Avisos |
| GET/POST | `address/change-requests` / `address/change-request` | solicitações de troca de endereço | Perfil |
| POST | `customers/support-request` | chamado de suporte | Atendimento |
| GET | `faqs` (público) | FAQ | Ajuda |

Nomes dos campos: os mesmos que o app iOS atual já usa nesses endpoints; em caso de dúvida, os `@SerializedName` dos modelos Kotlin do Android são a referência.

## Ainda não existe (usar mock até entrar em homologação)

Tudo de `openapi-hardrock.yaml`: cartão/QR, parceiros e cupons, certificados, ofertas, milhas, collection, perfil de viagem, preferências, dispositivos (token APNs), vídeos por empreendimento, Unity. Ordem de entrega do backend em `backend-implementacao.md`, seção 6.

## Push

Hoje o backend envia por tópico FCM (`announcements`, `user_{id}`). No iOS: Firebase Messaging via SPM, inscrever nos mesmos tópicos após login; quando `POST /devices` existir, registrar o token APNs/FCM também.
