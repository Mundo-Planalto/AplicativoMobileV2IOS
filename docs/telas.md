# Telas do app (especificação e dados de demonstração)

Todas as telas usam fundo `hrBlack`, rolagem vertical e os componentes de `design-system.md`. Os textos e valores abaixo são os mesmos do Android e devem ser reproduzidos exatamente no modo mock. Código de referência (se precisar de detalhe): `ui/hardrock/*.kt` e `ui/screens/*.kt` no repositório `Mundo-Planalto/AplicativoMobileV2`.

## Navegação

- Fluxo: Splash (2 s) → Login (se não há token) ou Início.
- `TabView` com 5 abas: **Início**, **Benefícios**, **Ofertas**, **Empreendimentos**, **Perfil**.
- Telas empilhadas (push, com `HrBackHeader`): Financeiro, Extrato, Informe de rendimentos, Certificados, Unity e Milhas, Cartão digital, Detalhes do empreendimento, Avisos/Notícias, Detalhe da notícia, Política de privacidade, Sistema/Configurações.
- Usuário de demonstração: nome "José R. Castro", membro "8150", nível "Founder", desde "2026", token "DEMO-HRVC". O cliente real vem do login (`docs/api-existente.md`).
- Primeiro nome exibido nos headers: primeira palavra do nome, capitalizada ("ROBSON SILVA" → "Robson").

## Splash

Fundo preto com gradiente radial dourado sutil (12%) no centro. `HrWordmark` centralizado com animação de opacidade 0.5↔1 (1 s, repetindo). Abaixo: linha dourada de 60pt e texto "GRAMADO" 11pt, spacing 4, muted. Depois de 2 s decide Login ou Início pelo token no Keychain.

## Login

`HrWordmark` no topo; título "Bem-vindo ao seu clube"; subtítulo "Acesse com seu CPF/CNPJ e senha". Campo CPF/CNPJ (ícone `doc.text`, teclado numérico, aceita 11 ou 14 dígitos), campo Senha (olho para mostrar/ocultar, mínimo 6). Bordas: `hrGoldBorder` normal, `hrGold` em foco; fundo `hrSurface`. `HrGoldButton("Entrar")`, que vira spinner durante o login. Links: "Esqueci minha senha" (abre `https://portal.mundoplanalto.com.br/Account/ForgotPassword`), separador de 60pt, "Primeiro acesso" (tela de cadastro, pode ser WebView do portal na primeira fase), "Acessar demonstração" em muted (entra com o usuário fictício). Erro em card vermelho translúcido.

## Início (aba)

1. `HrHeader(nome, "Seus benefícios", "Experiências que valorizam sua jornada", sino → Avisos/Notícias)`.
2. Card hero com foto (`https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800`): tag "CERTIFICADO DE VIAGEM", "Gramado te espera" (24 bold), "Natureza, cultura e momentos inesquecíveis em um dos destinos mais encantadores do Brasil.", `HrStatusDot("Disponível")`, `HrGoldButton("Solicitar código")` → Certificados.
3. Grade 2x2 de `HrShortcut`: Viagens / "Experiências exclusivas" → Certificados; Descontos / "Em parceiros selecionados" → aba Benefícios; Unity / "Vantagens para você" → Unity e Milhas; Milhas / "Acumule e aproveite" → Unity e Milhas.
4. Card "Resumo financeiro": ícone, "Próximo vencimento", `HrStatusDot("Em dia")` à direita, valor "R$ 2.480,00" (34 bold dourado), "15 OUT 2026", link "Ver detalhes" → Financeiro.
5. Card "Meu empreendimento": miniatura 64pt, "Hard Rock Hotel Gramado", "Unidade 1208 • Torre A", chevron → aba Empreendimentos.
6. Seção "Collection Hard Rock": "Complete sua coleção mantendo as parcelas em dia"; 6 camisetas (`tshirt.fill` em caixas arredondadas): 1 e 2 douradas com legenda "Enviada"; 3 a 6 cinza (muted 40%) com cadeado pequeno e legenda "Bloqueada"; "2 de 6 camisetas desbloqueadas"; barra de progresso dourada fina (2/6).
7. Card em destaque "Ofertas para você": "20% de desconto — Restaurante parceiro em Gramado" → aba Ofertas.

## Financeiro (push a partir da Início)

`HrBackHeader`/`HrHeader(nome, "Financeiro", "Acompanhe sua situação e tenha mais controle sobre seu investimento")`. Seletor de empreendimento (miniatura 48pt, tag "EMPREENDIMENTO", "Hard Rock Hotel Gramado", "Gramado • RS", chevron para baixo). Card grande com foto de fundo: tag "SITUAÇÃO FINANCEIRA", `HrStatusDot("Em dia")`, "Próximo vencimento", "15 OUT 2026", "R$ 2.480,00" (34 bold), `HrGoldButton("Pagar parcela")` → Extrato. Três `HrStatPill`: "R$ 172.480,00" / "Saldo do contrato"; "28 de 48" / "Parcelas pagas"; "20 de 48" / "Parcelas restantes". `HrSectionTitle("Próximas parcelas", acao: "Ver todas" → Extrato)` com 3 linhas (calendário, data, valor dourado, `HrTag("A vencer")`): 15 OUT 2026, 15 NOV 2026, 15 DEZ 2026, todas R$ 2.480,00. `HrSectionTitle("Documentos financeiros")` com `HrListRow`: "Segunda via de boleto" / "Emita a segunda via da sua parcela"; "Extrato financeiro" / "Acompanhe seu histórico de pagamentos"; "Informe de rendimentos" / "Acesse seu informe anual".

Com API real: resumo de `GET financial/resumo`, parcelas de `GET financial/extrato`, boleto de `GET financial/boleto-data/...`.

## Benefícios (aba)

`HrHeader(nome, "Benefícios", "Vantagens exclusivas para você")`. Chips: Todos, Viagens, Gramado, Milhas (filtram os cards). Três `HrStatPill`: "2" certificados, "6" ofertas, "12.500" milhas. Card foto Gramado: tag "CERTIFICADO", "Experiência Gramado", `HrStatusDot("Disponível")`, "Solicitar código" → Certificados. Card foto restaurante (`photo-1414235077428-338989a2e8c0`): tag "PARCEIRO", "20% no jantar", "Restaurante Belle du Val • Gramado", `HrGoldButton("Ver voucher")` → alerta com cupom "HRVC-20JANTAR" em dourado e "Apresente este código no parceiro". Card "Hard Rock Unity": "Conecte sua conta e desbloqueie benefícios", "Cadastrar" → Unity e Milhas. Card "Suas milhas": "12.500" dourado, "Ver histórico" → Unity e Milhas. Seção "Parceiros em Gramado" (subtítulo "Mínimo de 10% de desconto • validação por cupom", ação "Ver ofertas" → aba Ofertas) com 6 `HrListRow`, cada um abrindo o alerta de cupom:

| Parceiro | Desconto | Cupom |
|---|---|---|
| Chocolates Lugano | 10% de desconto | HRVC-LUGANO10 |
| Restaurante Belle du Val | 20% no jantar | HRVC-20JANTAR |
| Snowland | 15% no ingresso | HRVC-SNOW15 |
| Mini Mundo | 10% no ingresso | HRVC-MINI10 |
| Cervejaria Rasen Bier | 10% na conta | HRVC-RASEN10 |
| Vinícola Ravanello | 15% em vinhos | HRVC-RAVA15 |

## Ofertas (aba)

`HrHeader(nome, "Ofertas", "Promoções e campanhas selecionadas para você")`. Chips: Todas, Hospedagem, Gastronomia, Experiências. Card destaque com foto: tag "CAMPANHA EM DESTAQUE", "Experiências que valem mais", "Condições especiais por tempo limitado", `HrTag("Até 31 de outubro")`, "Ver campanha" (alerta). `HrSectionTitle("Ofertas disponíveis")`; 3 cards horizontais com miniatura 96pt à esquerda: GASTRONOMIA / "20% de desconto" / "Restaurantes parceiros em Gramado" / "Ver oferta"; HOSPEDAGEM / "Fim de semana especial" / "Condições exclusivas para membros" / "Ver oferta"; MILHAS / "Milhas em dobro" / "Campanha promocional ativa" / "Participar" → Unity e Milhas. Card final com `Toggle` dourado: "Receber novas promoções" / "Seja o primeiro a saber sobre ofertas e benefícios", ligado.

## Certificados de viagem (push)

`HrBackHeader("Certificados de viagem", "Escolha uma experiência para solicitar")`. Card foto Gramado: tag "NACIONAL", "Experiência no Brasil", "Hospedagem para momentos inesquecíveis.", `HrStatusDot("Disponível")`, "Solicitar código". Card foto praia (`photo-1507525428034-b723cf961d3e`): tag "INTERNACIONAL", "Experiência Internacional", "Descubra destinos ao redor do mundo.", `HrStatusDot("Disponível")`, "Solicitar código". Ao solicitar: alerta "Solicitação enviada" / "Sua solicitação foi registrada. O Pós-vendas entrará em contato com o código do certificado."; o card passa a `HrStatusDot("Solicitado", hrWarning)` e botão outline desabilitado "Aguardando Pós-vendas". Card informativo (`info.circle`): "Após a solicitação, o Pós-vendas fará a reserva e a liberação do código." Com API: `POST certificates/requests`.

## Unity e Milhas (push)

`HrBackHeader("Vantagens", "Mais benefícios para sua jornada")`. Card Unity com gradiente escuro→dourado e `globe` grande a 18% à direita: "Unity" (dourado, itálico bold), "Vantagens no Hard Rock no mundo", "Cadastre-se no programa e aproveite experiências, ofertas e reconhecimento em destinos participantes.", `HrTag("Cadastro disponível")`, `HrGoldButton("Cadastrar no Unity")` → abre `https://www.hardrock.com/unity` (Safari); 3 mini atalhos: Hotéis, Restaurantes, Experiências. Card Milhas com foto avião (`photo-1436491865332-7a61a109cc05`): "Ofertas e promoções", pílula "Seu saldo atual 12.500 milhas", "Acompanhe campanhas e oportunidades cadastradas para você", botões "Ver ofertas" → aba Ofertas e "Histórico de milhas" → alerta com "+2.000 Campanha Milhas em dobro • 12/09/2026", "+500 Hospedagem Gramado • 28/08/2026", "+10.000 Bônus de boas-vindas • 01/08/2026". Card "Perfil de viagem": "Onde você mora" = "Goiânia • GO"; "Destinos preferidos" = chips Gramado, Orlando, Cancún, Lisboa; `HrOutlineButton("Editar perfil")` (alerta "Em breve"). Card com `Toggle` "Receber novas promoções".

## Empreendimentos (aba) e Detalhes

Lista dos empreendimentos do cliente (`GET ventures`), cards com foto full-bleed 320pt, nome em badge preto translúcido com borda dourada, botões "Galeria de fotos" (outline) e "Acompanhamento de obras" (dourado). Título "Meu empreendimento" com estrela. Detalhes: `HrBackHeader(nomeEmpreendimento, "Atualizações da obra")`, seção "Vídeos da obra" / "Acompanhamento no YouTube" com player em WebView, descrição e galeria. **Sem** percentual/evolução da obra (removido por decisão da diretoria). Mock: "Hard Rock Hotel Gramado", "Unidade 1208 • Torre A", vídeo "Atualização da obra — Setembro de 2026".

## Perfil (aba)

`HrHeader(nome, "Perfil", "Sua jornada, ainda mais especial.")`. `CartaoDigitalCard` (toque → Cartão digital). Linha: `HrGoldButton("Ver benefícios")` → aba Benefícios + botão quadrado outline 46pt com `qrcode` → Cartão digital. `HrSectionTitle("Dados pessoais", "Gerencie suas informações e preferências.")` e 4 linhas expansíveis: `person.fill` "Informações pessoais" / "Seu nome, e-mail e telefone" (nome, CPF/CNPJ, e-mail, telefone de `GET customers/data`); `house.fill` "Endereço de correspondência" / "Seu endereço cadastrado" (+ `HrOutlineButton("Solicitar alteração")` → formulário `POST address/change-request`); `slider.horizontal.3` "Preferências" / "Comunicações e experiências"; `shield.fill` "Segurança" / "Senha, acesso e dispositivos". Linha "Sair" / "Encerrar a sessão neste dispositivo" com ícone vermelho e alerta de confirmação; limpa Keychain e volta ao Login.

## Cartão digital (push)

`CartaoDigitalCard`: proporção 1.6:1, gradiente preto→`#1C1C1C` com brilho diagonal dourado 15%, borda 1pt `hrGold`, raio 18; `HrWordmark(compact)` no canto superior esquerdo; "GOOD MUSIC · GREATER JOURNEYS" (9pt dourado) no superior direito; tag "MEMBRO" e nome 22 bold branco no meio; rodapé "•••• 8150" à esquerda, "Desde 2026" e `HrTag("FOUNDER", filled)` à direita; `music.note` 140pt a 25% como marca d'água à direita.

Tela: `HrBackHeader("Cartão do membro", "Apresente nos parceiros para validar seus benefícios")`; o cartão; `HrCard` centralizado com QR Code 220pt (preto sobre quadrado branco raio 12) codificando `https://portal.mundoplanalto.com.br/card/HRVC-8150-DEMO` (com API: `verifyUrl` de `GET members/me/card`); "Status: " + `HrStatusDot("Ativo")`; "Nível Founder • Membro desde 2026"; texto "O parceiro escaneia o QR Code e vê em tempo real se o cliente está ativo e quantas vezes o benefício já foi usado."; `HrSectionTitle("Utilizações recentes")` com 3 `HrListRow` e `HrTag("Usado")`: "Chocolates Lugano • 10% • 20/09/2026", "Restaurante Belle du Val • 20% • 14/09/2026", "Snowland • 15% • 02/09/2026".

## Telas herdadas do portal (podem ser WebView na primeira fase, nativas depois)

Extrato (parcelas, boleto com linha digitável e PDF), Informe de rendimentos (anos + PDF), Avisos/Notícias e detalhe, Política de privacidade, Sistema/Configurações (notificações, política, versão).
