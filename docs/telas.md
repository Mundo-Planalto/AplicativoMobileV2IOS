# Telas do app (especificação e dados de demonstração) — revisão de 01/10/2026

Todas as telas usam fundo `hrBlack`, rolagem vertical e os componentes de `design-system.md`. Os textos e valores abaixo são os mesmos nas duas plataformas (Android e iOS) e devem ser reproduzidos exatamente no modo mock. Esta versão incorpora a revisão do CEO de 01/10 (`docs/revisao-ceo-01-10.md`); as seções marcadas com **[01/10]** mudaram em relação ao MVP de 28/09.

## Navegação

- Fluxo: Splash (2 s) → Login (se não há token) ou Início.
- Barra com 5 abas: **Início**, **Benefícios**, **Campanhas**, **Empreendimentos**, **Perfil**. **[01/10]** "Ofertas" virou "Campanhas".
- Telas empilhadas (push, com `HrBackHeader`): Viagens, Financeiro, Extrato, Informe de rendimentos, Página do empreendimento, Galeria, Vídeos da obra, Documentos, Cartão digital, Perfil de viagem, Alteração de dados, Avisos/Notícias, Detalhe da notícia, Navegador interno, Política de privacidade, Configurações.
- **[01/10] Removidas:** Unity e Milhas, Milhas, Certificados (antiga), Collection.
- **Sessão fixa [01/10]:** token persistido; o app só volta ao Login em "Sair" ou 401 persistente ("Sua sessão expirou, entre novamente").
- Usuário de demonstração: nome "José R. Castro", membro "8150", nível "Founder", desde "2026", clube "Mundo Planalto", token "DEMO-HRVC". O cliente real vem do login (`docs/api-existente.md`).
- Primeiro nome exibido nos headers: primeira palavra do nome, capitalizada ("ROBSON SILVA" → "Robson").
- **Navegador interno:** toda URL externa (Unity, Mais Viagens, Instagram, YouTube, WhatsApp web, links de campanha) abre em WebView dentro do app com barra superior "Fechar" e título; iOS `SFSafariViewController` ou `WKWebView` em sheet, Android `WebView` em tela própria (Custom Tab aceitável). Exceções: `wa.me` pode abrir o app do WhatsApp; Instagram/YouTube podem abrir o app nativo se instalado.

## Marca [01/10]

- O símbolo oficial chegou (`docs/brand/simbolo-mundo-planalto.svg`, dourado `#9E8033`); regras, área de proteção, ícone do app e paleta em `docs/marca.md`.
- `MundoPlanaltoSymbol(size, color)`: o símbolo vetorial. Substitui a estrela do header, o `music.note` do cartão e o ícone do app.
- `MundoPlanaltoLogo(compact:)`: símbolo + wordmark em texto "MUNDO PLANALTO" (34 black, spacing 3, `hrGold`) e "VACATION CLUB" (12 semibold, spacing 2, `hrGoldLight`); compacto: símbolo 24pt + "MUNDO PLANALTO" 14 bold. Quando a logo horizontal oficial chegar, o componente passa a mostrar a imagem sem mudar os chamadores.
- `HrWordmark` ("HARD ROCK / HOTEL & VACATION CLUB") deixa de ser usado em telas; pode ficar no código apenas se algum conteúdo específico do empreendimento precisar.
- Botão principal: dourado sólido `hrGold`, texto preto bold. Sem gradiente.
- Nome do app nas lojas: "Mundo Planalto"; ícone: `docs/brand/app-icon-1024-escuro.png` (símbolo `#9E8033` sobre `#0A0A0A`, área de proteção do brandbook). Android usa `docs/brand/ic_launcher_foreground.xml`.

## Splash

Fundo preto com gradiente radial dourado sutil (12%) no centro. `MundoPlanaltoLogo` centralizado com animação de opacidade 0.5↔1 (1 s, repetindo). Linha dourada de 60pt abaixo. **[01/10]** sem o texto "GRAMADO". Depois de 2 s decide Login ou Início pelo token salvo.

## Login

`MundoPlanaltoLogo` no topo; título "Bem-vindo ao seu clube"; subtítulo "Acesse com seu CPF/CNPJ e senha". Campo CPF/CNPJ (ícone `doc.text`, teclado numérico, aceita 11 ou 14 dígitos), campo Senha (olho para mostrar/ocultar, mínimo 6). Bordas: `hrGoldBorder` normal, `hrGold` em foco; fundo `hrSurface`. `HrGoldButton("Entrar")`, que vira spinner durante o login. Links: "Esqueci minha senha" (abre `https://portal.mundoplanalto.com.br/Account/ForgotPassword` no navegador interno), separador de 60pt, "Primeiro acesso" (cadastro simples: CPF + dados básicos, pode ser WebView do portal na primeira fase; sem 2FA), "Acessar demonstração" em muted, visível só quando `AppConfig.showDemoLogin` (padrão `true` em debug, `false` em release). Erro em card vermelho translúcido. **[01/10]** Um layout novo virá do CEO; até lá, esta estrutura.

## Início (aba) [01/10]

1. `HrHeader(nome, "Seus benefícios", "Experiências que valorizam sua jornada", sino → Avisos/Notícias)`.
2. Card hero com foto (`https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800`): tag "CERTIFICADO DE VIAGEM", "Gramado te espera" (24 bold), "Natureza, cultura e momentos inesquecíveis em um dos destinos mais encantadores do Brasil.", `HrStatusDot("2 certificados disponíveis")` (contagem dos certificados com status `available` ou `released`), `HrGoldButton("Ver meus certificados")` → Viagens. Se o cliente não tiver certificado: subtítulo "Conheça as experiências do seu clube" e botão "Ver viagens".
3. Grade 2x2 de `HrShortcut`: Viagens / "Seus certificados e reservas" → Viagens; Descontos / "Em parceiros selecionados" → aba Benefícios; Unity / "Vantagens Hard Rock no mundo" → card Unity (aba Benefícios, rolando até o card) ; Campanhas / "Condições especiais" → aba Campanhas.
4. Card "Resumo financeiro": ícone, "Próximo vencimento", `HrStatusDot("Em dia")` à direita, valor "R$ 2.480,00" (34 bold dourado), "15 OUT 2026", link "Ver detalhes" → Financeiro.
5. Card em destaque "Campanhas para você": "Antecipe parcelas e ganhe desconto — Condições válidas até 31 de outubro" → aba Campanhas.

Removidos: card "Meu empreendimento", seção "Collection Hard Rock", atalho Milhas.

## Viagens (push) [01/10]

`HrBackHeader("Viagens", "Seus certificados, reservas e vouchers")`.

**Seção "Meus certificados"** (`HrSectionTitle`, subtítulo "Cadastrados pela Central de Contratos na sua compra"). Um `HrCard` por certificado:
- Linha 1: `HrTag(tipo)` (RCI / MAIS VIAGENS / BRINDE) e, à direita, `HrStatusDot` do status.
- Nome (16 bold) exatamente como veio do cadastro; quantidade ("1 certificado" / "2 certificados").
- "Expira em 31/12/2027" (12 muted; em `hrError` se faltar menos de 60 dias).
- Protocolo quando houver: "Protocolo CERT-2026-000123" (12 muted).
- Ação por status:
  - `available`: `HrStatusDot("Disponível")`; `HrGoldButton("Solicitar ativação")` → alerta de confirmação "Solicitar ativação do certificado?" / "O Pós-vendas vai fazer a reserva e liberar o código." [Cancelar | Solicitar] → alerta "Solicitação enviada" / "Protocolo CERT-2026-000123. O Pós-vendas responde em até 2 dias úteis." O card passa a `requested`.
  - `requested`: `HrStatusDot("Aguardando Pós-vendas", hrWarning)`; `HrOutlineButton("Aguardando Pós-vendas")` desabilitado.
  - `released`: `HrStatusDot("Liberado")`; código em destaque ("Código MV-8150-2026", 14 semibold dourado, toque copia); `HrGoldButton("Usar")` → navegador interno em `useUrl`. Texto abaixo: "Você vai reservar na plataforma Mais Viagens com seu login de lá."
  - `used`: `HrStatusDot("Utilizado", hrTextMuted)` e "Utilizado em 12/08/2026"; sem botão.
  - `expired`: `HrStatusDot("Expirado", hrError)` e "Expirado em 30/06/2026"; sem botão.
- Mock: "Certificado RCI — 7 noites" (RCI, 1, `available`, expira 31/12/2027); "Mais Viagens — Experiência Gramado" (MAIS VIAGENS, 1, `released`, código `MV-8150-2026`, `useUrl` `https://maisviagens.com.br/`, expira 30/06/2027).

**Seção "Minhas viagens"**: V1 sem integração; card vazio com `airplane` e "Suas reservas aparecerão aqui quando forem confirmadas pelo Pós-vendas."

**Seção "Vouchers"**: V1 vazia; card com `gift.fill` e "Em breve: seus vouchers e brindes digitais."

Card informativo (`info.circle`): "Após a solicitação, o Pós-vendas faz a reserva e libera o código. Você recebe um aviso no app."

Com API: `GET members/me/certificates`, `POST certificates/{id}/request`.

## Benefícios (aba) [01/10]

`HrHeader(nome, "Benefícios", "Vantagens exclusivas para você")`. Chips: Todos, Viagens, Gramado (filtram os cards; as categorias podem vir do backend).

1. **Destaques**: até 2 cards com foto, marcados `featured` no cadastro. Mock: Restaurante Belle du Val (`photo-1414235077428-338989a2e8c0`): tag "PARCEIRO", "20% no jantar", "Restaurante Belle du Val • Gramado", `HrGoldButton("Ver voucher")` → alerta de cupom; Snowland (`photo-1483921020237-2ff51e8e4b22`): tag "PARCEIRO NOVO", "15% no ingresso", "Snowland • Gramado", "Ver voucher".
2. Card **Unity** com identidade do programa: fundo `#1A1A1A`, logo "Hard Rock Unity" (asset quando chegar; até lá texto "HARD ROCK UNITY" 18 bold branco), "Vantagens no Hard Rock no mundo", "Cadastre-se no programa e aproveite experiências, ofertas e reconhecimento em destinos participantes.", `HrGoldButton("Cadastrar no Unity")` → navegador interno em `https://www.hardrock.com/unity`; 3 mini atalhos: Hotéis, Restaurantes, Experiências (mesma URL).
3. Seção "Parceiros" (subtítulo "Mínimo de 10% de desconto • validação por cupom") com `HrListRow` por parceiro, cada um abrindo o alerta de cupom (nome, cupom em dourado, "Apresente este código no parceiro"):

| Parceiro | Desconto | Cupom |
|---|---|---|
| Chocolates Lugano | 10% de desconto | HRVC-LUGANO10 |
| Restaurante Belle du Val | 20% no jantar | HRVC-20JANTAR |
| Snowland | 15% no ingresso | HRVC-SNOW15 |
| Mini Mundo | 10% no ingresso | HRVC-MINI10 |
| Cervejaria Rasen Bier | 10% na conta | HRVC-RASEN10 |
| Vinícola Ravanello | 15% em vinhos | HRVC-RAVA15 |

4. Card "Certificados de viagem": "Veja seus certificados e solicite a ativação", `HrOutlineButton("Ver meus certificados")` → Viagens.

Removidos: três `HrStatPill`, card "Suas milhas", card "Perfil de viagem", toggle "Receber novas promoções". A lista já vem filtrada por empreendimento do backend.

## Campanhas (aba) [01/10]

`HrHeader(nome, "Campanhas", "Condições especiais e campanhas para você")`. Chips dinâmicos: "Todas" + uma por categoria presente nas campanhas ativas (mock: Antecipação, Upgrade, Indicação, Viagem).

Card de campanha (foto à esquerda 96pt ou destaque com foto grande se `featured`): `HrTag(categoria)`, título (16 bold), subtítulo (12 muted), `HrTag("Até 31 de outubro")` quando houver validade, botão com `ctaLabel`.

Ao tocar o botão: envia `POST campaigns/{id}/interest` (mock: só registra em log) e executa `ctaType`:
- `online` ou `postsales`: alerta "Recebemos seu interesse" / "Nossa equipe entra em contato em breve."
- `whatsapp`: abre `https://wa.me/{whatsappNumber}?text={whatsappMessage}`.
- `link`: navegador interno em `ctaUrl`.
- `certificate`: Viagens.

Mock (nesta ordem):
1. Destaque (foto `photo-1519681393784-d120267933ba`): ANTECIPAÇÃO / "Antecipe parcelas e ganhe desconto" / "Condições válidas por tempo limitado" / "Até 31 de outubro" / "Quero antecipar" (`postsales`).
2. UPGRADE / "Faça upgrade do seu plano" / "Mais semanas e mais benefícios" / "Quero saber mais" (`online`).
3. INDICAÇÃO / "Indique um amigo e ganhe um brinde" / "Seu amigo compra, você ganha" / "Indicar agora" (`link`, abre `https://hrh.vacation.mundoplanalto.com.br/` no navegador interno).
4. VIAGEM (foto `photo-1507525428034-b723cf961d3e`) / "Gramado em julho com preço especial" / "Use seu certificado nesta oferta do Mais Viagens" / "Usar certificado" (`certificate`).

Removidos: "Milhas em dobro", toggle "Receber novas promoções", categorias fixas Hospedagem/Gastronomia/Experiências.

## Empreendimentos (aba) [01/10]

Título "Meu empreendimento" com estrela. Lista dos empreendimentos do cliente (`GET ventures`): card com foto full-bleed 320pt, nome em badge preto translúcido com borda dourada, cidade/UF, e `HrGoldButton("Abrir")`; o toque no card também abre. Sem outros botões na lista. Mock: "Hard Rock Hotel Gramado", "Gramado • RS", "Unidade 1208 • Torre A".

## Página do empreendimento (push) [01/10]

`HrBackHeader("Hard Rock Hotel Gramado", "Gramado • RS")`.
1. Foto de capa 200pt com gradiente inferior; "Unidade 1208 • Torre A" sobre a foto.
2. Grade 2x2 de `HrShortcut`: Financeiro / "Parcelas, boletos e extrato" → Financeiro (filtrado por este empreendimento); Galeria de fotos / "Imagens do projeto" → Galeria; Vídeos da obra / "Acompanhamento no YouTube" → Vídeos; Documentos / "Contrato, informe e boletos" → Documentos (lista com Informe de rendimentos, Segunda via de boleto, Extrato; contrato quando houver API).
3. `HrSectionTitle("Acompanhe o empreendimento")` com 3 `HrListRow`: Instagram / "@hardrockhotelgramado" → `instagramUrl`; Canal no YouTube / "Vídeos e atualizações da obra" → `youtubeUrl`; Canal do WhatsApp / "Novidades direto no seu celular" → `whatsappChannelUrl`. Abrem no app nativo se instalado, senão no navegador interno. Se a URL vier vazia, a linha não aparece.
4. Seção "Última atualização": card com título "Diário de Obras | Hard Rock Hotel Gramado — Setembro/2026", data, descrição curta e `HrGoldButton("Assistir no YouTube")` → Vídeos.

Sem percentual/evolução da obra.

**Vídeos da obra**: lista de atualizações (`GET ventureupdates/venture/{id}`) com player YouTube em WebView, título, data e descrição. **Galeria**: grade 2 colunas das fotos do empreendimento com visualização em tela cheia.

## Financeiro (push) [01/10]

`HrBackHeader("Financeiro", "Acompanhe sua situação e tenha mais controle sobre seu investimento")`. Seletor de empreendimento (miniatura 48pt, tag "EMPREENDIMENTO", "Hard Rock Hotel Gramado", "Gramado • RS", chevron para baixo; fixo quando aberto pela página do empreendimento). Card de situação **sem foto de fundo**: `HrCard` com borda `hrGold`, tag "SITUAÇÃO FINANCEIRA", `HrStatusDot("Em dia")`, "Próximo vencimento", "15 OUT 2026", "R$ 2.480,00" (34 bold dourado), `HrGoldButton("Pagar parcela")` → Extrato. Três `HrStatPill`: "R$ 172.480,00" / "Saldo do contrato"; "28 de 48" / "Parcelas pagas"; "20 de 48" / "Parcelas restantes". `HrSectionTitle("Próximas parcelas", acao: "Ver todas" → Extrato)` com 3 linhas (calendário, data, valor dourado, `HrTag("A vencer")`): 15 OUT 2026, 15 NOV 2026, 15 DEZ 2026, todas R$ 2.480,00. `HrSectionTitle("Documentos financeiros")` com `HrListRow`: "Segunda via de boleto" / "Emita a segunda via da sua parcela"; "Extrato financeiro" / "Acompanhe seu histórico de pagamentos"; "Informe de rendimentos" / "Acesse seu informe anual".

Com API real: resumo de `GET financial/resumo`, parcelas de `GET financial/extrato`, boleto de `GET financial/boleto-data/...`.

## Perfil (aba) [01/10]

`HrHeader(nome, "Perfil", "Sua jornada, ainda mais especial.")`. `CartaoDigitalCard` (toque → Cartão digital). Linha: `HrGoldButton("Ver benefícios")` → aba Benefícios + botão quadrado outline 46pt com `qrcode` → Cartão digital.

`HrSectionTitle("Perfil de viagem", "Usamos isso para escolher campanhas para você")`: card com "Onde você mora" = "Goiânia • GO"; "Destinos preferidos" = chips Gramado, Orlando, Cancún, Lisboa; "Próxima viagem" = "Em até 6 meses • Gramado"; `HrOutlineButton("Editar perfil de viagem")` → tela Perfil de viagem.

`HrSectionTitle("Dados pessoais", "Mantenha seus dados atualizados")` e 4 linhas expansíveis:
- `person.fill` "Informações pessoais" / "Nome, CPF, e-mail e telefone": mostra os dados de `GET customers/data` e `HrOutlineButton("Solicitar alteração")` → tela Alteração de dados (campo: Telefone ou E-mail).
- `house.fill` "Endereço de correspondência" / "Seu endereço cadastrado": endereço e `HrOutlineButton("Solicitar alteração")` → Alteração de dados (campo: Endereço).
- `slider.horizontal.3` "Preferências" / "Comunicações e campanhas": `Toggle` "Receber campanhas e novidades" (ligado por padrão) e `Toggle` "Avisos do empreendimento" (ligado). Único lugar do opt-in (LGPD / App Store).
- `shield.fill` "Segurança" / "Senha e acesso": trocar senha (`POST auth/change-password`).

Linha "Sair" / "Encerrar a sessão neste dispositivo" com ícone vermelho e alerta de confirmação; limpa o token e volta ao Login.

## Perfil de viagem (push) [01/10]

`HrBackHeader("Perfil de viagem", "Conte para onde você quer ir")`. Campos: "Onde você mora" (cidade, UF); "Destinos preferidos" (chips selecionáveis de uma lista: Gramado, Orlando, Cancún, Lisboa, Punta Cana, Buenos Aires, Paris, Dubai; até 4); "Quando pretende viajar" (segmentado: Em até 6 meses / Em até 1 ano / Mais de 1 ano / Ainda não sei); "Para onde" (texto livre). Rodapé: "Preenchido com as respostas da sua compra. Suas alterações ficam registradas para o Pós-vendas." `HrGoldButton("Salvar")` → `PUT members/me/travel-profile` (mock: salva em memória) → toast "Perfil atualizado".

## Alteração de dados (push) [01/10]

`HrBackHeader("Solicitar alteração", "A Central de Contratos confirma em até 2 dias úteis")`. Seletor do campo (Endereço / Telefone / E-mail), valor atual (somente leitura), novo valor (formulário de endereço completo quando for Endereço), `HrGoldButton("Enviar solicitação")` → `POST customers/change-requests` → alerta "Solicitação enviada". Abaixo, "Suas solicitações": lista com campo, data e `HrTag` de status (Em análise / Aprovada / Recusada). Mock: uma solicitação "Telefone • 20/09/2026 • Aprovada".

## Cartão digital (push) [01/10]

`CartaoDigitalCard(nome, nivel, numeroMembro, desde, clube)`: proporção 1.6:1, gradiente preto→`#1C1C1C` com brilho diagonal dourado 15%, borda 1pt `hrGold`, raio 18; `MundoPlanaltoLogo(compact)` no canto superior esquerdo; nome do clube (`clubName`, 9pt dourado, uppercase) no superior direito; tag "MEMBRO" e nome 22 bold branco no meio; rodapé "•••• 8150" à esquerda, "Desde 2026" e `HrTag("FOUNDER", filled)` à direita (tier vem do backend). Sem slogan Hard Rock; marca d'água `MundoPlanaltoSymbol(140, hrGold 12%)` à direita no lugar do `music.note`.

Tela: `HrBackHeader("Cartão do membro", "Apresente nos parceiros para validar seus benefícios")`; o cartão; `HrCard` centralizado com QR Code 220pt (preto sobre quadrado branco raio 12) codificando `https://portal.mundoplanalto.com.br/card/HRVC-8150-DEMO` (com API: `verifyUrl` de `GET members/me/card`); "Status: " + `HrStatusDot("Ativo")`; "Nível Founder • Membro desde 2026"; texto "O parceiro escaneia o QR Code e vê em tempo real se o cliente está ativo e quantas vezes o benefício já foi usado."; `HrSectionTitle("Utilizações recentes")` com 3 `HrListRow` e `HrTag("Usado")`: "Chocolates Lugano • 10% • 20/09/2026", "Restaurante Belle du Val • 20% • 14/09/2026", "Snowland • 15% • 02/09/2026".

## Telas herdadas do portal (podem ser WebView na primeira fase, nativas depois)

Extrato (parcelas, boleto com linha digitável e PDF), Informe de rendimentos (anos + PDF), Avisos/Notícias e detalhe (recebem também "Seu certificado foi liberado" e "Sua solicitação de alteração foi aprovada"), Política de privacidade, Configurações (notificações, política, versão).
