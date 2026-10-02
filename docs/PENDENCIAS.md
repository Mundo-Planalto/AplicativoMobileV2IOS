# Pendências (iOS Mundo Planalto)

O que não está documentado em `docs/telas.md`, `docs/api-existente.md` ou `docs/openapi-hardrock.yaml`
fica em mock e é registrado aqui, com a decisão tomada no iOS. Atualizado em 02/10/2026, depois da
revisão do CEO de 01/10 (`docs/revisao-ceo-01-10.md`).

## Ambiente e configuração

| Item | Situação | Decisão no iOS |
|---|---|---|
| Homologação `https://api.portal.mundoplanalto.com.br/api/` | Não responde (TLS fecha após o handshake; backend na porta 5083 não está no ar) | `Development.xcconfig` aponta para produção por autorização de 29/09; a URL de homologação está comentada no arquivo para a troca |
| `Config.plist` com `API_BASE_URL` (api-existente.md) | Substituído | A URL vem de `API_BASE_URL` nos xcconfigs (Debug → Development, Release → Production), exposta no Info.plist e lida em `ApiConfig` |
| `GoogleService-Info.plist` | Fora do git (`.gitignore`) | Cada máquina precisa do arquivo em `Mundo planalto Portal App/`; entregar fora do repositório |
| `PDFService` e `SystemService` | URL fixa `http://10.35.0.55:5187/api/` e endpoints (`pdfs`, `system/*`) fora de api-existente.md | Não usados pelas telas atuais; candidatos a remoção |
| Simulador "iPhone 15" (CLAUDE.md) | Não instalado nesta máquina | Builds validados no simulador iPhone 17 (iOS 26.2) |
| Sessão fixa | JWT do cliente dura 7 dias e não há `POST auth/refresh` | O app só encerra a sessão quando `GET auth/me` confirma 401 duas vezes e mostra "Sua sessão expirou, entre novamente". Enquanto o backend não emitir token longo, o cliente volta ao Login a cada 7 dias |

## Em mock com `AppConfig.useMockData = true` (sem endpoint ainda)

Vale também para quem entra com login real: os dados abaixo são os de demonstração de `docs/telas.md`
até o backend existir. **Atenção em builds para a diretoria:** as ações marcadas com (*) parecem
funcionar, mas nada é enviado ao backend.

| Tela / dado | Endpoint futuro | Observação |
|---|---|---|
| Certificados e solicitação de ativação (*) | `GET members/me/certificates`, `POST certificates/{id}/request` | 2 certificados fixos; o protocolo `CERT-2026-000123` é fictício e o estado "Aguardando Pós-vendas" some ao reabrir o app |
| Parceiros, destaques e cupons | `GET partners`, `POST partners/{id}/coupon` | 6 parceiros de Gramado; destaques Belle du Val e Snowland |
| Campanhas e registro de interesse (*) | `GET campaigns`, `POST campaigns/{id}/interest` | 4 campanhas; o clique só vai para o log em debug. O WhatsApp da campanha de indicação usa o número de exemplo `5562999999999` |
| Cartão do membro, tier, número, "desde", clube, QR `verifyUrl` | `GET members/me/card` | Com login real mostra o nome do cliente e os demais campos do mock (8150 / Founder / 2026 / Mundo Planalto) |
| Utilizações recentes | `GET members/me/redemptions` | 3 linhas fixas |
| Perfil de viagem (*) | `GET/PUT members/me/travel-profile` | Salvo em memória; volta ao padrão ao reabrir o app |
| Preferências (opt-in) | `GET/PUT members/me/notification-preferences` | Persistidas em UserDefaults |
| Alteração de telefone e e-mail | `POST/GET customers/change-requests` | Na demonstração é mock. **Com login real, o endereço usa o endpoint que o portal já tem (`address/change-requests`)** e telefone/e-mail mostram que a função chega em breve |
| Redes sociais, cidade/UF e unidade do empreendimento | `GET ventures` com os campos novos | Com login real as linhas de redes sociais ficam ocultas e a unidade não aparece, porque a API ainda não devolve |
| Financeiro por empreendimento | `GET ventures/{id}/financial` | Com login real o extrato é filtrado pelo nome do empreendimento no app; o valor do próximo vencimento segue o resumo geral |

## Demonstração (usuário José R. Castro)

| Item | Decisão |
|---|---|
| Dados pessoais (CPF, e-mail, telefone, endereço) | Fictícios: `***.456.789-**`, `jose.castro@exemplo.com`, `(62) 98888-0000`, "Rua T-63, 1200 — Apto 1208, Setor Bueno — Goiânia/GO, CEP 74230-100". Alinhar com o Android |
| Links do Hard Rock Hotel Gramado | `instagram.com/hardrockhotelgramado`, `youtube.com/@mundoplanalto` e `whatsapp.com/channel/` são de exemplo; trocar pelos oficiais |
| Vídeo "Diário de Obras — Setembro/2026" | Na demonstração usa o vídeo cadastrado no book do empreendimento no portal (`Bh4EpKvdCpY`); no login real vêm as atualizações e os vídeos do portal |
| Galeria | 4 fotos do Unsplash |
| Extrato | 48 parcelas de R$ 2.480,00 (28 pagas, 20 a vencer a partir de 15/10/2026); boleto abre o modal "Boleto não gerado" |
| Informe de rendimentos | Mostra os anos 2025 e 2026 e avisa que o documento só é gerado com login real |
| Avisos | 3 avisos fictícios, incluindo "Seu certificado foi liberado" |
| Troca de senha | Avisa que na demonstração a senha não é alterada |

## Não documentado (decisão provisória)

| Item | Decisão |
|---|---|
| `MundoPlanaltoLogo` não compacto em telefone | Símbolo à esquerda e wordmark 34 black não cabem em 393pt; o texto reduz de escala para caber em uma linha |
| Etiqueta "PARCEIRO NOVO" nos destaques | Vem de `isNew` no mock; o contrato só tem `isFeatured`. Definir o campo no backend |
| Chips de Benefícios | "Todos", "Viagens" e uma opção por cidade dos parceiros. Viagens mostra Unity e Certificados |
| Logo do Hard Rock Unity | Texto "HARD ROCK UNITY" sobre `#1A1A1A` até o asset oficial chegar |
| Documentos → Contrato | Linha informativa "O contrato ficará disponível aqui em breve"; falta endpoint |
| Política de privacidade e Termos de uso | Placeholder; faltam URL ou conteúdo oficiais |
| Layout de iPad | Telas desenhadas e conferidas em iPhone; no iPad o conteúdo estica na largura |
| Push por tópico `user_{id}` | Ainda não inscrito no iOS (só `announcements`); `POST /devices` aguarda o backend |
| Toggle "Notificações push" em Configurações | Só grava a preferência local; não desinscreve dos tópicos FCM |
| Variantes de Home (`AppConfig.homeVariant`) | Não implementadas; só a variante A, como manda a revisão, até Rodrigo pedir |
| Ícone do app claro (`app-icon-1024-claro.png`) | Gerado em `docs/brand/`; o app usa o escuro. Rodrigo decide qual vai para as lojas |

## Fora da V1 (seção 6 da revisão; não implementar)

| Item | O que foi dito | Quando |
|---|---|---|
| The Orb | Clube de benefícios próprio, uma camada acima de todos os produtos; pode virar app próprio | Fase 2, após o lançamento Planalto |
| Cadastro sem produto | Não-cliente baixa o app para retirar brinde e receber comunicação; arquitetura separada do CINJ/Sienge | V2 |
| Brinde por QR Code | Vouchers de brinde digitalizados, com as regras de aprovação atuais | Após regras |
| Milhas | Cadastro manual de promoções e, depois, IA lendo imagens dos grupos | Depois |
| Pontos Mundo Planalto | Pontuação por antecipação, resgate em parceiros | Ideia |
| Benefícios e cores por produto (Arca não é preto) | Personalização total | V2 |
| RCI por API | Reservar sem sair do app | Investigar |
| 2FA | Exigência legal; e-mail como segundo fator | Até o fim de 2027 |
| Portal do cliente web | Será descontinuado com migração para o app | Plano de comunicação |
| Layout novo do Login e propostas de Home | José e Rodrigo | Em andamento |
| Cartões físico e digital com The Orb | Diego (layout), Julio (assets) | Em andamento |
| Collection (camisetas) | Vira campanha de indicação no futuro | Depois |
