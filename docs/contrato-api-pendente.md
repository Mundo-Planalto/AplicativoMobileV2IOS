# Contrato de API pendente (app Mundo Planalto, iOS e Android)

Especificação para o time de backend de tudo que o app hoje mostra com dados fixos ou deixa travado
com "Disponível em breve". Organizado por endpoint, com o JSON que o app envia e o que espera receber.
Os nomes de campo são exatamente os que o app iOS já decodifica; qualquer diferença quebra a tela.
Fonte formal: `docs/openapi-hardrock.yaml` (este documento é o resumo de trabalho). Atualizado em 05/10/2026.

## Regras gerais

- **Base**: a mesma da API do portal (`https://portal.mundoplanalto.com.br/api/`); em homologação, o host de homologação.
- **Autenticação**: `Authorization: Bearer {jwt}` em todos os endpoints abaixo. O usuário vem do token; o app não envia id de cliente.
- **Envelope**: toda resposta no formato já usado pelo portal:
  ```json
  { "success": true, "message": null, "data": { } }
  ```
  Em erro: `success: false` e `message` com texto que pode ser mostrado ao cliente.
- **Nomes**: camelCase. **Datas**: `yyyy-MM-dd`; data e hora em ISO 8601 UTC (`2026-09-20T15:30:00Z`).
- **Valores em dinheiro**: número (`2480.00`), nunca texto formatado.
- **401**: o app confere `GET auth/me`; só encerra a sessão se o 401 se repetir.
- **Campos opcionais**: enviar `null` ou omitir. Enum desconhecido não derruba o app (cai no valor padrão indicado).

## Ordem sugerida de entrega

| Prioridade | Endpoint | Destrava no app |
|---|---|---|
| 1 | `POST auth/refresh` ou JWT longo | Sessão fixa (hoje o cliente volta ao Login a cada 7 dias) |
| 1 | `GET members/me/certificates`, `POST certificates/{id}/request` | Tela Viagens e o botão "Solicitar ativação" |
| 1 | `GET campaigns`, `POST campaigns/{id}/interest` | Aba Campanhas e os botões de interesse |
| 2 | `GET partners`, `POST partners/{id}/coupon` | Aba Benefícios e o cupom |
| 2 | `GET members/me/card`, `GET members/me/redemptions` | Cartão digital e QR Code |
| 2 | `GET ventures` com os campos novos | Redes sociais, cidade/UF e unidade no empreendimento |
| 3 | `GET/PUT members/me/travel-profile` | Perfil de viagem e o botão "Salvar" |
| 3 | `GET/PUT members/me/notification-preferences` | Preferências do Perfil |
| 3 | `GET/POST customers/change-requests` | Alteração de telefone e e-mail |
| 3 | `GET ventures/{id}/financial` | Financeiro por empreendimento |
| 3 | `POST devices`, `DELETE devices/{token}` | Push direcionado por aparelho |
| 3 | Exclusão de conta, política e termos (seção final) | Exigências da App Store |

---

## 1. Certificados

### GET `members/me/certificates`

Lista os certificados do cliente logado (cadastrados pela Central de Contratos por venda).

Resposta `data`:
```json
[
  {
    "id": 1,
    "name": "Certificado RCI — 7 noites",
    "type": "rci",
    "quantity": 1,
    "status": "available",
    "expiresAt": "2027-12-31",
    "protocol": null,
    "code": null,
    "useUrl": null,
    "requestedAt": null,
    "releasedAt": null,
    "usedAt": null
  },
  {
    "id": 2,
    "name": "Mais Viagens — Experiência Gramado",
    "type": "maisviagens",
    "quantity": 1,
    "status": "released",
    "expiresAt": "2027-06-30",
    "protocol": "CERT-2026-000045",
    "code": "MV-8150-2026",
    "useUrl": "https://maisviagens.com.br/",
    "requestedAt": "2026-08-30T14:00:00Z",
    "releasedAt": "2026-09-02",
    "usedAt": null
  }
]
```

| Campo | Tipo | Obrigatório | Observação |
|---|---|---|---|
| `id` | inteiro | sim | |
| `name` | texto | sim | Título do card |
| `type` | `rci` \| `maisviagens` \| `gift` | sim | Desconhecido vira `gift` (etiqueta "Brinde") |
| `quantity` | inteiro | sim | "1 certificado" / "N certificados" |
| `status` | `available` \| `requested` \| `released` \| `used` \| `expired` | sim | Define o botão e a cor do status |
| `expiresAt` | data | não | Fica vermelho a menos de 60 dias |
| `protocol` | texto | não | Mostrado como "Protocolo X" depois da solicitação |
| `code` | texto | só em `released` | Código que o cliente copia |
| `useUrl` | URL | só em `released` | Aberta pelo botão "Usar" no navegador interno |
| `requestedAt`, `releasedAt`, `usedAt` | data/hora | não | `usedAt` aparece em "Utilizado em" |

### POST `certificates/{id}/request`

Cliente pede a ativação. Corpo: `{}`.

Resposta `data`:
```json
{ "protocol": "CERT-2026-000123", "slaHours": 48 }
```
O app mostra "Protocolo CERT-2026-000123. O Pós-vendas responde em até 2 dias úteis" (`slaHours / 24`).
Depois disso o `GET` deve devolver o certificado com `status: "requested"` e o `protocol`.
Erros esperados: `404` (não é do cliente), `409` (já solicitado), com `message`.

---

## 2. Campanhas

### GET `campaigns`

Campanhas ativas, já filtradas pelos empreendimentos do cliente, na ordem de exibição.

```json
[
  {
    "id": 1,
    "category": "Antecipação",
    "title": "Antecipe parcelas e ganhe desconto",
    "subtitle": "Condições válidas por tempo limitado",
    "imageUrl": "https://.../campanha.jpg",
    "validUntil": "2026-10-31",
    "ctaLabel": "Quero antecipar",
    "ctaType": "postsales",
    "ctaUrl": null,
    "whatsappNumber": null,
    "whatsappMessage": null,
    "ventureIds": [82],
    "isFeatured": true
  },
  {
    "id": 3,
    "category": "Indicação",
    "title": "Indique um amigo e ganhe um brinde",
    "subtitle": "Seu amigo compra, você ganha",
    "imageUrl": null,
    "validUntil": null,
    "ctaLabel": "Indicar agora",
    "ctaType": "link",
    "ctaUrl": "https://hrh.vacation.mundoplanalto.com.br/",
    "whatsappNumber": null,
    "whatsappMessage": null,
    "ventureIds": [82],
    "isFeatured": false
  }
]
```

| Campo | Tipo | Obrigatório | Observação |
|---|---|---|---|
| `category` | texto livre | sim | Os filtros da tela são montados com as categorias que vierem |
| `title`, `subtitle`, `ctaLabel` | texto | sim | |
| `imageUrl` | URL | não | Obrigatória na prática quando `isFeatured` |
| `validUntil` | data | não | Vira "Até 31 de outubro" |
| `ctaType` | `online` \| `postsales` \| `whatsapp` \| `link` \| `certificate` | sim | Ver tabela abaixo; desconhecido vira `online` |
| `ctaUrl` | URL | se `link` | |
| `whatsappNumber`, `whatsappMessage` | texto | se `whatsapp` | Número só com dígitos, com DDI (`5562...`) |
| `ventureIds` | lista de inteiros | não | |
| `isFeatured` | booleano | não | Card grande com foto |

| `ctaType` | O que o app faz ao tocar |
|---|---|
| `online`, `postsales` | Registra o interesse e mostra "Recebemos seu interesse. Nossa equipe entra em contato em breve." |
| `whatsapp` | Registra o interesse e abre `https://wa.me/{whatsappNumber}?text={whatsappMessage}` |
| `link` | Registra o interesse e abre `ctaUrl` no navegador interno |
| `certificate` | Registra o interesse e abre a tela Viagens |

### POST `campaigns/{id}/interest`

Chamado em **todo** toque no botão da campanha (é a métrica de clique e conversão). Corpo: `{}`.
Resposta: `{ "success": true, "message": null, "data": {} }`. Deve ser idempotente por cliente e campanha
para o contador de pessoas, mas pode contar cliques repetidos à parte.

---

## 3. Parceiros e cupons

### GET `partners`

Parceiros ativos dos empreendimentos do cliente.

```json
[
  {
    "id": 3,
    "name": "Snowland",
    "category": "experiencias",
    "city": "Gramado",
    "state": "RS",
    "discountPercent": 15,
    "discountText": "15% no ingresso",
    "terms": null,
    "validationType": "coupon",
    "logoUrl": null,
    "imageUrl": "https://.../snowland.jpg",
    "address": null,
    "usageLimitPerCustomer": null,
    "validUntil": null,
    "isActive": true,
    "isFeatured": true,
    "isNew": true,
    "ventureIds": [82]
  }
]
```

| Campo | Tipo | Obrigatório | Observação |
|---|---|---|---|
| `category` | `gastronomia` \| `hospedagem` \| `experiencias` \| `compras` \| `outros` | sim | Define o ícone |
| `city`, `state` | texto | sim | A tela cria um filtro por cidade |
| `discountPercent` | inteiro | sim | |
| `discountText` | texto | sim | Título do destaque ("20% no jantar") |
| `validationType` | texto | sim | Hoje `coupon` |
| `isActive` | booleano | sim | |
| `isFeatured` | booleano | não | Destaque com foto; o app mostra no máximo 2 e só os que têm `imageUrl` |
| **`isNew`** | booleano | não | **Campo novo, ainda fora do contrato.** `true` mostra a etiqueta "PARCEIRO NOVO" no destaque; `false` ou ausente mostra "PARCEIRO". Sugestão: o backend calcula (ex.: cadastrado há menos de 30 dias) ou o admin marca |
| demais | | não | `terms`, `logoUrl`, `address`, `usageLimitPerCustomer` (`null` = ilimitado), `validUntil`, `ventureIds` |

### POST `partners/{id}/coupon`

Gera (ou devolve o já gerado) cupom do cliente para o parceiro. Corpo: `{}`.

```json
{
  "partnerId": 3,
  "partnerName": "Snowland",
  "code": "MP-SNOW15-8F2K",
  "discountText": "15% no ingresso",
  "validUntil": "2026-12-31",
  "remainingUses": 2,
  "instructions": "Apresente este código no parceiro"
}
```
`code`, `partnerName`, `discountText` e `instructions` são obrigatórios. Erro `409` com `message` quando o limite de uso acabou.

---

## 4. Cartão do membro

### GET `members/me/card`

```json
{
  "name": "Robson Exemplo",
  "level": "Founder",
  "memberNumber": "8150",
  "memberSince": "2026-01-15",
  "status": "active",
  "cardToken": "c1f0…",
  "verifyUrl": "https://portal.mundoplanalto.com.br/cartao/c1f0…",
  "benefitUsageCount": 3,
  "clubName": "Mundo Planalto"
}
```

| Campo | Observação |
|---|---|
| `level` | `Founder` \| `Legacy` \| `Discovery` (sem diferenciar maiúsculas); desconhecido vira `Discovery` |
| `memberNumber` | O app mostra "•••• 8150" |
| `memberSince` | Data; o app usa só o ano ("Desde 2026") |
| `status` | `active` \| `inactive` |
| `verifyUrl` | Conteúdo do QR Code; o parceiro abre e vê se o cliente está ativo |
| `clubName` | Opcional; nome do clube no cartão |

### GET `members/me/redemptions`

Utilizações recentes de benefício (o app mostra as primeiras).

```json
[
  { "id": 1, "partnerId": 1, "partnerName": "Chocolates Lugano", "discountText": "10%", "usedAt": "2026-09-20T15:30:00Z", "source": "qr" }
]
```
`source`: `qr` ou `coupon`.

---

## 5. Perfil de viagem

### GET `members/me/travel-profile`

Pré-preenchido com as respostas da compra (PEP).

```json
{
  "homeCity": "Goiânia",
  "homeState": "GO",
  "preferredDestinations": ["Gramado", "Orlando", "Cancún", "Lisboa"],
  "nextTripWhen": "within_6_months",
  "nextTripDestination": "Gramado",
  "source": "pep"
}
```

| Campo | Observação |
|---|---|
| `preferredDestinations` | Até 4 textos. Opções do app hoje: Gramado, Orlando, Cancún, Lisboa, Punta Cana, Buenos Aires, Paris, Dubai |
| `nextTripWhen` | `within_6_months` \| `within_1_year` \| `more_than_1_year` \| `unknown` |
| `nextTripDestination` | Texto livre, opcional |
| `source` | `pep` (carga inicial) ou `app` (editado pelo cliente) |

### PUT `members/me/travel-profile`

Envia o mesmo objeto, com `source: "app"`. Resposta: o objeto salvo. Cada alteração deve gerar histórico
para o Pós-vendas (`GET admin/members/{id}/travel-profile/history`).

---

## 6. Preferências de comunicação

### GET e PUT `members/me/notification-preferences`

```json
{ "campaigns": true, "announcements": true }
```
`campaigns`: "Receber campanhas e novidades". `announcements`: "Avisos do empreendimento".
O `PUT` envia o objeto inteiro e recebe o objeto salvo. O backend usa esses valores para decidir os envios de push.

---

## 7. Alteração de dados cadastrais

Hoje só o endereço funciona, pelo endpoint antigo `address/change-requests`. O contrato novo unifica.

### GET `customers/change-requests`

```json
[
  { "id": 12, "field": "phone", "newValue": "(62) 98888-0000", "status": "approved", "createdAt": "2026-09-20T12:00:00Z" }
]
```
`field`: `address` \| `phone` \| `email`. `status`: `pending` \| `approved` \| `rejected` (desconhecido vira `pending`).

### POST `customers/change-requests`

Envia:
```json
{ "field": "email", "newValue": "novo@exemplo.com" }
```
Para `address`, o app hoje manda o endereço em uma linha em `newValue`
("Rua T-63, 1200 — Apto 1208 — Setor Bueno, Goiânia/GO, CEP 74230-100").
**Decisão pendente do backend:** se preferirem os campos separados (como o endpoint antigo), definam o objeto
`address` (`street`, `number`, `complement`, `neighborhood`, `city`, `state`, `zipCode`) e o app passa a enviar.

Resposta `data`: o item criado, no formato do `GET`, com `status: "pending"`.

---

## 8. Empreendimentos

### GET `ventures` (já existe; campos novos)

Cada item passa a trazer também:

```json
{
  "id": 82,
  "name": "Hard Rock Hotel Gramado",
  "imageUrl": "/uploads/...",
  "photoBook": [ { "id": 1, "photoUrl": "/uploads/...", "mediaType": "image", "youtubeUrl": null, "createdAt": "2026-08-01T00:00:00Z" } ],
  "city": "Gramado",
  "state": "RS",
  "unit": "Unidade 1208 • Torre A",
  "instagramUrl": "https://www.instagram.com/...",
  "instagramHandle": "@...",
  "youtubeUrl": "https://www.youtube.com/@...",
  "whatsappChannelUrl": "https://whatsapp.com/channel/..."
}
```
Todos os campos novos são opcionais; sem eles a linha correspondente fica oculta no app.
`city`, `state`, `instagramUrl`, `youtubeUrl` e `whatsappChannelUrl` o app já lê. `unit` e `instagramHandle` são propostas: ainda não estão no `openapi-hardrock.yaml` e o app passa a ler quando forem confirmados.

### GET `ventures/{id}/financial`

Resumo financeiro só daquele empreendimento (hoje o app filtra o extrato geral pelo nome).

```json
{
  "ventureId": 82,
  "totalOverdue": 0,
  "totalDue": 49600.00,
  "contractBalance": 172480.00,
  "paidInstallments": 28,
  "totalInstallments": 48,
  "nextDue": { "dueDate": "2026-10-15", "amount": 2480.00 }
}
```

---

## 9. Sessão e push

### POST `auth/refresh`

Corpo vazio, com o Bearer atual. Resposta: `{ "success": true, "token": "novo.jwt" }`. `401` encerra a sessão no app.
Alternativa aceita: JWT de validade longa (ex.: 180 dias).

### POST `devices`

Depois do login e quando o token de push muda:
```json
{ "token": "fcm-token…", "platform": "ios", "appVersion": "1.0.9", "deviceModel": "iPhone17,2" }
```
Resposta: `{ "success": true }`. Idempotente por `token`.

### DELETE `devices/{token}`

No "Sair".

### Payload das notificações

Para o toque abrir a tela certa, o app lê a chave `screen` nos **dados** da mensagem (FCM `data`), além do
`notification` com título e corpo:

| `screen` | Tela aberta |
|---|---|
| ausente ou outro valor | Avisos |
| `ventures` | Empreendimentos |
| `certificates` | Viagens |
| `campaigns` | Campanhas |
| `financial` | Financeiro |

Tópicos em que o iOS se inscreve hoje: `announcements` (todos) e `user_{id}` (depois do login; sai ao deslogar).

---

## 10. Exigências da App Store que dependem do backend

Sem contrato ainda; precisam existir antes da submissão de 18/11 (ver `docs/app-store-bloqueadores.md`).

| Necessidade | Proposta |
|---|---|
| Exclusão de conta pedida de dentro do app | `DELETE customers/me` ou `POST customers/me/deletion-request` (resposta com protocolo e prazo). O app precisa de um endpoint que **inicie** a exclusão; pode ser um pedido atendido pela Central, desde que o cliente não precise ligar nem mandar e-mail |
| Política de privacidade e Termos de uso | Duas URLs públicas (sem login), ex.: `https://portal.mundoplanalto.com.br/privacidade` e `/termos` |
| Conta de teste para o revisor da Apple | Um cliente de teste em produção com financeiro, empreendimento, certificado e campanha preenchidos |
