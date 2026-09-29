# Pendências (iOS Hard Rock Hotel & Vacation Club)

O que não está documentado em `docs/telas.md`, `docs/api-existente.md` ou `docs/openapi-hardrock.yaml`
fica em mock e é registrado aqui, com a decisão tomada no iOS. Atualizado em 29/09/2026.

## Ambiente e configuração

| Item | Situação | Decisão no iOS |
|---|---|---|
| Homologação `https://api.portal.mundoplanalto.com.br/api/` | Não responde (TLS fecha após handshake; backend na porta 5083 não está no ar) | `Development.xcconfig` aponta para produção por autorização de 29/09; a URL de homologação está comentada no arquivo para a troca |
| `Config.plist` com `API_BASE_URL` (api-existente.md) | Substituído | A URL vem de `API_BASE_URL` nos xcconfigs (Debug → Development, Release → Production), exposta no Info.plist e lida em `ApiConfig` |
| `GoogleService-Info.plist` | Saiu do git (`.gitignore`) | Cada máquina precisa do arquivo em `Mundo planalto Portal App/`; combinar entrega fora do repositório |
| `PDFService` e `SystemService` | URL fixa `http://10.35.0.55:5187/api/` e endpoints (`pdfs`, `system/*`) fora de api-existente.md | Não usados pelas telas novas; avaliar remoção na limpeza das telas herdadas |

## Dados em mock (sem endpoint ainda)

| Tela / dado | Endpoint futuro | Observação |
|---|---|---|
| Cartão do membro, nível, número, "desde", QR `verifyUrl` | `GET members/me/card` | Com login real o cartão mostra o nome do usuário e os demais campos do mock (8150 / Founder / 2026) até o endpoint existir |
| Utilizações recentes | `GET members/me/redemptions` | 3 linhas fixas de telas.md |
| Parceiros e cupons | `GET partners`, `POST partners/{id}/coupon` | 6 parceiros de Gramado; o cupom abre em folha com o código em dourado |
| Certificados | `GET/POST certificates/requests` | Estado "Solicitado" em memória; some ao reabrir o app |
| Ofertas e campanha em destaque | `GET offers` | "Ver oferta" da oferta de gastronomia abre o cupom do parceiro 2; "Ver campanha" e a oferta de hospedagem mostram alerta com o texto da oferta |
| Milhas (saldo e histórico) | `GET members/me/miles` | 12.500 e 3 lançamentos de telas.md |
| Perfil de viagem | `GET/PUT members/me/travel-profile` | Somente leitura; "Editar perfil" mostra "Em breve" |
| Preferências ("Receber novas promoções") | `GET/PUT members/me/notification-preferences` | Persistidas em UserDefaults no mock |
| Collection Hard Rock | `GET members/me/collection` | 2 de 6 camisetas |
| Unity | `POST unity/interest` | Mock registra e abre `https://www.hardrock.com/unity` |
| Financeiro e "Meu empreendimento" na demonstração | API existente | Valores fixos de telas.md; com login real usa `financial/resumo`, `financial/extrato` e `ventures` |

## Não documentado (decisão provisória)

| Item | Decisão |
|---|---|
| Dados pessoais do usuário de demonstração (CPF, e-mail, telefone, endereço) | Fictícios: `***.456.789-**`, `jose.castro@exemplo.com`, `(62) 98888-0000`, "Rua T-63, 1200 — Apto 1208, Setor Bueno — Goiânia/GO, CEP 74230-100". Alinhar com o Android |
| "Alterar senha" no Perfil → Segurança | Alerta "Em breve" (a API `auth/change-password` existe; falta a tela) |
| Política de privacidade | Placeholder; falta a URL/conteúdo oficial |
| "Unidade 1208 • Torre A" com login real | A API `ventures` não devolve unidade; o card mostra só o nome do empreendimento |
| "Gramado • RS" com login real | A API `ventures` não devolve cidade/UF; o seletor de empreendimento omite a linha |
| Filtro dos chips em Benefícios (Todos, Viagens, Gramado, Milhas) | Viagens = certificado + Unity; Gramado = parceiro + lista de parceiros; Milhas = milhas + Unity |
| Push por tópico `user_{id}` | Ainda não inscrito no iOS (só `announcements`); e `POST /devices` aguarda o backend |
| Sessão de demonstração nas telas herdadas (Extrato, Informe, Empreendimentos, Avisos) | Em construção na etapa 5 (mock para a demonstração) |
