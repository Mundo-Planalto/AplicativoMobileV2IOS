# Revisão do MVP com o CEO (01/10/2026): o que muda no app

Documento único para os dois agentes: **Claude Code no Mac (iOS)** e **Claude Code no Windows (Android, `Mundo-Planalto/AplicativoMobileV2`)**. Ele altera o que está em `docs/telas.md` e no `CLAUDE.md`; onde houver conflito, **este documento vence**. `docs/telas.md` já foi reescrito para refletir o estado final; use este arquivo para entender *o que mudou e por quê*, e `telas.md` para saber *como cada tela fica*.

Fontes: reunião "10-01 Reunião APP: Visão José Roberto sobre MVP" (gravação Plaud, 1h05, 01/10/2026), anotações de Rodrigo Silva e a apresentação do projeto de 28/09. Participantes: José Roberto (CEO), Rodrigo Silva (TI), Arthur, Diego, Flávia e outros.

## 0. Resumo em uma tela

| Área | Antes (MVP 28/09) | Depois (decisão 01/10) |
|---|---|---|
| Marca | "Hard Rock Vacation Club" em texto, preto e dourado | Lançar como **Mundo Planalto** com a nova identidade dourada (logo oficial, não wordmark em texto); Hard Rock aparece só no conteúdo do empreendimento. "The Orb" (clube de benefícios) fica para fase 2, no máximo um símbolo discreto no cartão |
| Dourado | Gradiente com sombra ("cor de burro fugido"), `#D4AF37` | Dourado oficial do brandbook `#9E8033`, chapado nos botões; gradiente só onde for sutil (`docs/marca.md`) |
| Login | Deslogava | **Sessão fixa**: só sai no "Sair". Novo layout virá do José (gerado por IA); até lá, só troca a logo |
| Início | Hero "Solicitar código", card Meu empreendimento, Collection | Hero vira **"Ver meus certificados"**; **remove** card Meu empreendimento e **remove** Collection |
| Certificados | 2 fixos (Brasil / Internacional), "Solicitar código" → alerta | **Lista vinda do cadastro** (N por cliente, feita pela Central de Contratos), **protocolo** com SLA, **data de expiração**, status Disponível → Solicitado → Liberado ("Usar" abre Mais Viagens no navegador do app) → Usado / Expirado |
| Viagens | Não existia | Tela **Viagens**: certificados + vouchers do cliente e o que está ativo/reservado (acessada pelo hero da Início e pelo atalho Viagens) |
| Benefícios | Pills de estatística, Milhas, Unity genérico, perfil de viagem, toggle | **Remove** pills, Milhas, perfil de viagem e toggle. **Até 2 parceiros em destaque com imagem** (rotativo) e os demais em lista. Unity com **identidade do programa** e aberto **dentro do app** (WebView) |
| Ofertas | Promoções por categoria fixa | Aba renomeada **"Campanhas"**: upgrade, antecipação, quitação, indicação, brindes, destino Mais Viagens. Filtros dinâmicos. Cada campanha tem **CTA rastreável** (online, pós-vendas, WhatsApp, link) e registra clique |
| Milhas | Tela, saldo, histórico, robô | **Fora da V1.** Remover tela, atalho e card. Sem saldo de milhas no app |
| Collection | 6 camisetas na Início | **Fora da V1.** Remover tudo (vira campanha de indicação no futuro) |
| Empreendimentos | Card + 2 botões | Card com foto + **1 botão "Abrir"** → página-hub do empreendimento com **Financeiro, Galeria, Vídeos/Obra, Documentos e redes sociais (Instagram, YouTube, Canal do WhatsApp)** |
| Financeiro | Só pela Início; card de situação com foto atrás dos valores | Também **dentro do empreendimento**; card de situação **sem foto**, só box com borda dourada |
| Perfil | Cartão, dados, endereço | Ganha **Perfil de viagem** (onde mora, destinos, **próxima viagem**; pré-preenchido do PEP; histórico de edições) e **solicitação de alteração de endereço, telefone e e-mail** com aprovação da Central. **Opt-in de promoções** fica só aqui (LGPD/Apple) |
| Cartão | "Hard Rock", nível Founder | Mantém QR e nível; textos do clube **configuráveis** (nome do clube e tier vêm do backend). Layout físico/digital: Diego, com logo The Orb |
| Cadastro sem produto, brindes por QR, 2FA, pontos Mundo Planalto | — | **Fora da V1** (ver seção 6) |

**Build 1 (18/10) continua valendo** com estas mudanças: marca, 5 abas, Início, Viagens/Certificados, Benefícios, Campanhas, Empreendimentos com hub e Financeiro, Perfil. Tudo com `Mock` até o backend chegar.

## 1. Decisões globais

1. **Marca de lançamento é Mundo Planalto.** O app continua sendo o "Mundo Planalto Portal" atualizado nas lojas (sem app novo). O tema preto e dourado permanece, com a nova identidade: o Marketing entregou em 02/10 o **símbolo oficial** (asterisco de 8 pontas com ponto, dourado `#9E8033`) e o brandbook; tudo em `docs/marca.md` e `docs/brand/`. `MundoPlanaltoLogo` = símbolo + wordmark em texto até a logo horizontal chegar. "Hard Rock Hotel & Vacation Club" só aparece como nome de empreendimento e em conteúdos específicos dele.
2. **The Orb fica para fase 2.** Não escrever "The Orb" em tela. O cartão pode receber o símbolo quando Diego entregar o layout; o texto do clube no cartão vem de `clubName` do backend (mock: "Mundo Planalto").
3. **Dourado.** O CEO achou o dourado "meio cor de burro fugido" e com sombra. Ajuste: adotar o dourado oficial do brandbook `hrGold = #9E8033` (com `hrGoldLight #C9A84C` e `hrGoldDark #6E5A22`), botões principais em `hrGold` sólido com texto preto, sem gradiente nem sombra; `hrGoldGradient` só em detalhes finos (linha do splash, brilho do cartão). Fundo das telas continua `#0A0A0A`. Paleta completa em `docs/marca.md`.
4. **Sessão fixa.** Depois do primeiro login o app nunca desloga sozinho. Token no Keychain (iOS) / `EncryptedSharedPreferences` (Android). Só volta ao Login em "Sair" ou quando a API responder 401 de forma consistente (token realmente inválido); nesse caso mostra "Sua sessão expirou, entre novamente". Pendência de backend: JWT do cliente com validade longa (hoje 7 dias) ou endpoint de refresh.
5. **Segmentação por empreendimento.** Benefícios, certificados, campanhas e cartão são **filtrados no backend pelo CPF/empreendimentos do cliente** (Central de Contratos ativa o que cada venda deu). O app não decide nada por nome de empreendimento: só renderiza o que a API devolve. Cliente com Hard Rock e Terra Santa vê os dois conjuntos. No mock, o usuário de demonstração tem só Hard Rock Gramado.
6. **Opt-in de promoções** existe em um único lugar, Perfil → Preferências, ligado por padrão, porque a Apple e a LGPD exigem. Sai de Ofertas e de Unity/Milhas.
7. **Fora da V1 (não implementar, não deixar tela escondida):** Milhas, Collection, chat de IA, cadastro de não-cliente, brinde por QR Code, 2FA, pontos Mundo Planalto, integração RCI por API.

## 2. Mudanças tela a tela

Os textos finais estão em `docs/telas.md`. Aqui vai o diff e a motivação.

### 2.1 Splash e Login
- Trocar `HrWordmark` por `MundoPlanaltoLogo` e a estrela dos headers por `MundoPlanaltoSymbol` (ver `docs/marca.md`). Ícone do app novo (`docs/brand/`). Subtexto "GRAMADO" sai do splash.
- Layout novo do Login chega depois (José vai gerar uma proposta por IA em Medellín a partir do print da tela atual). Enquanto não chega: manter a estrutura, só marca e cores.
- "Primeiro acesso" continua simples (CPF + dados básicos), sem 2FA.
- "Acessar demonstração" continua, só para builds internos (ocultar em release de loja via `AppConfig.showDemoLogin`).

### 2.2 Início
- Hero do certificado: botão **"Ver meus certificados"** → tela Viagens. Texto do hero vem do primeiro certificado disponível (mock: "Gramado te espera").
- Grade de atalhos 2x2: **Viagens** → Viagens; **Descontos** → aba Benefícios; **Unity** → Unity; **Campanhas** → aba Campanhas. (Milhas sai.)
- Card "Resumo financeiro" permanece (valor, próximo vencimento, "Ver detalhes" → Financeiro).
- **Remover** card "Meu empreendimento" ("já tem lá em cima que é Hard Rock, não precisa desse cardzão").
- **Remover** seção "Collection Hard Rock" ("o que é pra resolver vira problema de explicar pro cliente").
- Card "Ofertas para você" vira "Campanhas para você" → aba Campanhas.
- Rodrigo vai apresentar 2 ou 3 propostas de nova Home ao CEO. Agente: criar essas variantes como telas alternativas atrás de `AppConfig.homeVariant` (A = atual ajustada, B e C = propostas) só se Rodrigo pedir; por padrão, implementar a A.

### 2.3 Viagens (nova tela) e Certificados
Motivação: na venda o cliente ganha 1 a 5 certificados (RCI, Mais Viagens etc.); o app tem que mostrar exatamente o que a Central de Contratos cadastrou, com governança, e o pedido tem que virar protocolo com SLA medido pelo Pós-vendas (John) para não virar ligação.

- **Viagens**: seção "Meus certificados" (lista) + seção "Minhas viagens" (reservas ativas, vazia na V1 com texto "Suas reservas aparecerão aqui") + seção "Vouchers" (vazia na V1).
- Cada certificado mostra: nome **como está no cadastro** (nunca inventar "Experiência Internacional"), tipo (RCI, Mais Viagens, Brinde), quantidade, **validade ("Expira em 31/12/2027")**, status e, quando houver, protocolo.
- Status e ações:
  - `available` → `HrStatusDot("Disponível")` + botão "Solicitar ativação" → confirma → alerta "Solicitação enviada" com **protocolo** (`CERT-2026-000123`) e "O Pós-vendas responde em até 2 dias úteis".
  - `requested` → `HrStatusDot("Aguardando Pós-vendas", hrWarning)` + protocolo + botão outline desabilitado.
  - `released` → `HrStatusDot("Liberado")` + código do certificado + botão **"Usar"** → abre a plataforma Mais Viagens (`useUrl`) **no navegador interno do app** (WebView com barra de fechar). Na V1 não há retorno da reserva para o app.
  - `used` → "Utilizado em dd/mm/aaaa"; `expired` → "Expirado em dd/mm/aaaa" em `hrError`.
- Mudança de status chega por push e aparece em Avisos ("Seu certificado foi liberado").
- Backend: `GET members/me/certificates`, `POST certificates/{id}/request` (gera protocolo e ocorrência no CRM). Ver seção 3.
- RCI por API: só investigar; nada no app.

### 2.4 Benefícios
- **Remover** os três `HrStatPill` do topo ("era só pra efeito").
- Topo: **até 2 parceiros em destaque** com imagem, marcados como `featured` no cadastro (o Marketing troca para dar evidência a parceiro novo). Abaixo, "Parceiros" em lista com desconto e cupom, como hoje.
- Card **Unity** com a identidade visual do programa (logo e cores do Hard Rock Unity, assets do site de marcas da Hard Rock; mock: placeholder com nome "Hard Rock Unity" e fundo escuro, sem inventar logo). "Cadastrar no Unity" abre `https://www.hardrock.com/unity` em **WebView dentro do app** (iOS: `SFSafariViewController` ou `WKWebView` em sheet com botão Fechar; Android: Custom Tab ou `WebView` em tela com AppBar e voltar). Nunca o navegador externo.
- **Remover** card "Suas milhas", card "Perfil de viagem" e toggle "Receber novas promoções".
- A lista já vem **filtrada por empreendimento** do backend; o app não filtra por cidade.
- A tela Unity e Milhas deixa de existir: Unity vira só o card + WebView; Milhas sai.

### 2.5 Ofertas → Campanhas
Motivação: "ofertas" soava como desconto de parceiro (já está em Benefícios); o que a empresa quer aqui é campanha com ação mensurável.

- Renomear aba, título e rotas para **Campanhas** ("Campanhas e condições especiais para você").
- Tipos de campanha (categoria vem do backend): **Upgrade**, **Antecipação**, **Quitação**, **Indicação**, **Brinde**, **Viagem** (destino do Mais Viagens com preço bom, com CTA "Usar certificado"), **Promoção**.
- **Filtros dinâmicos**: chips gerados das categorias que existem nas campanhas ativas, com "Todas" na frente. Nada fixo.
- Card de campanha: imagem, categoria, título, subtítulo, validade, botão com `ctaLabel`. Ao tocar: registra o clique (`POST campaigns/{id}/interest`) e executa `ctaType`:
  - `online` / `postsales`: abre ocorrência para o time e mostra "Recebemos seu interesse. Nossa equipe entra em contato."
  - `whatsapp`: abre `https://wa.me/<numero>?text=<mensagem>` (número e texto da campanha).
  - `link`: abre URL no navegador interno.
  - `certificate`: vai para Viagens.
- Medição: o backend conta cliques e conversões por campanha; o app só envia o evento.
- **Remover** "Milhas em dobro", toggle de promoções e qualquer menção a Collection.

### 2.6 Milhas (removida)
Fica para depois. Hoje a ideia é alguém do Marketing/Pós-vendas cadastrar promoções de milhas (lendo os grupos de WhatsApp) e, depois, uma IA ler a imagem do grupo e preencher. Nada disso entra no app agora. Remover tela, rota, atalho, repositório mock e textos.

### 2.7 Empreendimentos e página do empreendimento
Motivação: "deixa só o cardzinho do empreendimento, o cara clica e abre uma página com galeria, acompanhamento de obra, financeiro"; "tudo que a gente quiser comunicar do empreendimento vai pra dentro".

- Lista: card com foto full-bleed, nome e **um botão "Abrir"** (ou toque no card). Saem "Galeria de fotos" e "Acompanhamento de obras" da lista.
- **Página do empreendimento** (hub), com `HrBackHeader(nome, cidade)`:
  1. Foto de capa.
  2. Grade de atalhos: **Financeiro**, **Galeria de fotos**, **Vídeos da obra**, **Documentos** (contrato, informe, boletos). 
  3. Seção "Acompanhe": botões **Instagram**, **Canal no YouTube**, **Canal do WhatsApp** (links por empreendimento vindos de `GET ventures`; no mock, links do Hard Rock Gramado ou `#` se ainda não houver). Abrem no navegador interno (ou no app do Instagram/YouTube, se instalado).
  4. Vídeos: player YouTube (como hoje) e descrição da última atualização.
  5. Sem "evolução da obra" em percentual (decisão mantida de 28/09).
- Financeiro passa a ser acessível **daqui** (filtrado por este empreendimento) e da Início.

### 2.8 Financeiro
- Card de situação financeira **sem foto de fundo**: só `HrCard` com borda dourada, valor e vencimento. Os valores não ficam mais sobre logo ou imagem.
- Resto igual (parcelas, extrato, boleto com linha digitável e PDF, informe). "O vídeo ficou bom, o boleto funcionou" foi o feedback.

### 2.9 Perfil
- Cartão digital continua no topo; textos do clube vêm do backend (`clubName`, `tier`). Mock: nome "José R. Castro", tier "Founder", membro 8150, `clubName` "Mundo Planalto". **Não** escrever "Hard Rock" nem "The Orb" no cartão até Diego entregar o layout.
- **Perfil de viagem** (vem de Unity/Milhas para cá): "Onde você mora", "Destinos preferidos" (até 4 chips), **"Próxima viagem"** (quando: "Em até 6 meses / Em até 1 ano / Mais de 1 ano / Ainda não sei" + destino livre). Pré-preenchido com o que o cliente respondeu no PEP (vem do backend); editável; cada edição gera histórico que o Pós-vendas consulta.
- **"Mantenha seus dados atualizados"**: além de endereço, o cliente solicita alteração de **telefone e e-mail**; a Central aprova. Linha "Informações pessoais" ganha botão "Solicitar alteração" e lista de solicitações com status.
- **Preferências**: toggle "Receber promoções e novidades" (ligado por padrão) e "Avisos do empreendimento". Único lugar do opt-in.
- Segurança: trocar senha. Sem 2FA (planejado para 2027).
- "Sair" continua igual.

### 2.10 Cartão digital
- Igual ao atual, com `clubName` e `tier` dinâmicos e sem a frase "GOOD MUSIC · GREATER JOURNEYS" (é slogan Hard Rock; só volta se o layout do Diego trouxer).
- O cartão físico será impresso na sala de vendas com o mesmo `verifyUrl`; a Central de Contratos define o tier. Nada muda no app por isso.

## 3. Impacto no backend (`Mundo-Planalto/MundoPlanaltoPortal`)

Atualizar `docs/openapi-hardrock.yaml` e `docs/backend-implementacao.md` com isto. Até os endpoints existirem, o app usa `Mock`.

| Mudança | Endpoint | Observação |
|---|---|---|
| Certificados cadastrados por cliente | `GET members/me/certificates` → `[{ id, name, type (rci/maisviagens/gift), quantity, status (available/requested/released/used/expired), expiresAt, protocol?, code?, useUrl?, requestedAt?, releasedAt?, usedAt? }]` | Substitui o modelo de 2 tipos fixos. Cadastro feito pela Central de Contratos no admin, vinculado ao contrato antes de ir ao CRM |
| Solicitar ativação | `POST certificates/{id}/request` → `{ protocol, slaHours }` | Gera protocolo `CERT-yyyy-nnnnnn`, abre ocorrência no CRM para o Pós-vendas, SLA parametrizado; estourou o SLA, e-mail para o responsável |
| Liberação | `PATCH admin/certificates/{id}` (status, code, useUrl) | Dispara push "Seu certificado foi liberado" |
| Parceiros em destaque | `Partner.isFeatured`, `Partner.ventureIds[]` | `GET partners` já devolve filtrado por empreendimento do cliente; no máximo 2 `featured` |
| Campanhas | `GET campaigns` (substitui `offers`) → `[{ id, category, title, subtitle, imageUrl, validUntil, ctaLabel, ctaType (online/postsales/whatsapp/link/certificate), ctaUrl?, whatsappNumber?, whatsappMessage?, ventureIds[] }]`; `POST campaigns/{id}/interest` | Backend conta cliques e conversão por campanha; categorias livres |
| Perfil de viagem | `TravelProfile` ganha `nextTripWhen`, `nextTripDestination`, `source` (pep/app) e tabela `TravelProfileHistory` | PEP alimenta o registro inicial |
| Alteração de dados | `POST customers/change-requests` com `{ field: address/phone/email, newValue }`; `GET customers/change-requests` | Generaliza `address/change-request`; aprovação pela Central |
| Empreendimento | `Venture` ganha `instagramUrl`, `youtubeUrl`, `whatsappChannelUrl`; `GET ventures/{id}/financial` (resumo filtrado) | |
| Cartão | `GET members/me/card` devolve também `clubName` | |
| Sessão | JWT de cliente com validade longa (ex.: 180 dias) ou `POST auth/refresh` | Para a "sessão fixa" |
| Remover do contrato | `miles/*`, `members/me/miles`, `members/me/collection`, `admin/miles/*`, `admin/collection/*`, `members/me/notification-preferences.milesOffers` | Fora da V1 |

Governança fora do código (não é tarefa do agente, mas explica os campos): Central de Contratos cadastra/ativa certificados e benefícios por venda (referência: Ariane); Marketing é o gestor de comunidade por produto (MKT Sul = Hard Rock; MKT Centro-Oeste = Terra Santa e Arca) e cadastra campanhas e parceiros; Pós-vendas atende protocolos de certificado com SLA. Rodrigo vai formalizar a RACI.

## 4. Navegação final

5 abas: **Início · Benefícios · Campanhas · Empreendimentos · Perfil**.

Telas empilhadas: Viagens (certificados), Financeiro, Extrato, Informe, Página do empreendimento, Galeria, Vídeos, Documentos, Cartão digital, Perfil de viagem, Solicitação de alteração de dados, Avisos, Detalhe do aviso, Navegador interno (WebView), Política, Configurações.

Rotas removidas: Unity e Milhas (tela), Milhas, Collection, Ofertas (renomeada para Campanhas), Certificados antiga (substituída por Viagens).

Nota: o CEO falou em "aba de viagem". Com Financeiro dentro de Empreendimentos e o Perfil de viagem no Perfil, a sexta aba não cabe bem na barra; a decisão registrada aqui é Viagens como tela acessada pela Início (hero e atalho) e pela aba Benefícios. Se Rodrigo decidir que Viagens vira aba, ela substitui a aba Benefícios e os parceiros entram como seção de Viagens.

## 5. Dados de demonstração (mock) que mudam

- Certificados do José R. Castro: 2 itens: "Certificado RCI — 7 noites" (tipo rci, `available`, expira 31/12/2027) e "Mais Viagens — Experiência Gramado" (tipo maisviagens, `released`, código `MV-8150-2026`, `useUrl` `https://maisviagens.com.br/`, expira 30/06/2027). Ao solicitar o primeiro: protocolo `CERT-2026-000123`, SLA 48 h.
- Parceiros: os 6 de Gramado continuam; `featured` = Restaurante Belle du Val e Snowland (com imagem).
- Campanhas: "Antecipe parcelas e ganhe desconto" (Antecipação, `postsales`), "Faça upgrade do seu plano" (Upgrade, `online`), "Indique um amigo e ganhe um brinde" (Indicação, `whatsapp`), "Gramado em julho com preço especial" (Viagem, `certificate`). Validade "Até 31 de outubro" na primeira.
- Perfil de viagem: Goiânia • GO; Gramado, Orlando, Cancún, Lisboa; próxima viagem "Em até 6 meses", destino "Gramado".
- Empreendimento: Hard Rock Hotel Gramado com `instagramUrl`, `youtubeUrl`, `whatsappChannelUrl` de exemplo.
- Removidos: saldo 12.500 milhas, histórico de milhas, camisetas 2 de 6, "Milhas em dobro".

## 6. Fora da V1 (registrar em `docs/PENDENCIAS.md`, não implementar)

| Item | O que foi dito | Quando |
|---|---|---|
| The Orb | Clube de benefícios próprio, evolução do modelo RCI, uma camada acima de todos os produtos; pode virar app próprio | Fase 2, após o lançamento Planalto |
| Cadastro sem produto | Não-cliente baixa o app para retirar brinde e receber comunicação; acesso limitado; vira cliente completo quando o contrato sobe. Precisa de arquitetura separada do CINJ/Sienge por segurança | V2 |
| Brinde por QR Code | Vouchers de brinde digitalizados, regras de aprovação iguais às atuais (quem aprova, quantos por cliente), controle pela Central | Após regras |
| Milhas | Cadastro manual de promoções e, depois, IA lendo imagens dos grupos | Depois |
| Pontos Mundo Planalto | Pontuação por antecipação etc., resgate em parceiros (ex.: Expedia) | Ideia |
| Benefícios diferentes por produto e cores por marca (Arca não é preto) | Personalização total | V2 |
| RCI por API | Reservar sem sair do app | Investigar |
| 2FA | Exigência legal; e-mail como segundo fator | Até fim de 2027 |
| Portal do cliente web | Será descontinuado com migração para o app | Plano de comunicação |
| Layout novo do Login e propostas de Home | José e Rodrigo | Esta semana |
| Cartões físico/digital com The Orb | Diego (layout), Julio (assets) | Esta semana |

## 7. Como o agente deve aplicar

1. Ler este arquivo e o `docs/telas.md` novo inteiro antes de tocar em código.
2. Fazer **um commit por item** da ordem abaixo, build passando antes de cada commit (simulador iPhone 15 no iOS; `assembleDebug` no Android).
3. Ordem:
   1. Remoções: Milhas, Collection, Unity e Milhas (tela), pills de Benefícios, card Meu empreendimento, toggles de promoção fora do Perfil, "GOOD MUSIC · GREATER JOURNEYS".
   2. Marca: paleta `#9E8033`, `MundoPlanaltoSymbol`, `MundoPlanaltoLogo`, ícone do app, botões em dourado sólido, splash/login (tudo em `docs/marca.md`).
   3. Sessão fixa.
   4. Modelos e `Mock` novos: `Certificate`, `Campaign`, `TravelProfile` com próxima viagem, `Venture` com redes sociais, `ChangeRequest`.
   5. Viagens + certificados com status e protocolo; navegador interno.
   6. Benefícios com destaques e Unity em WebView.
   7. Campanhas (renomear Ofertas) com filtros dinâmicos e CTA.
   8. Empreendimentos: lista simples + página-hub + redes sociais; Financeiro dentro do hub e sem foto no card.
   9. Perfil: perfil de viagem, alteração de dados, preferências.
   10. Atualizar `docs/openapi-hardrock.yaml`, `docs/backend-implementacao.md` e `docs/PENDENCIAS.md`.
4. O que não estiver aqui nem em `telas.md`, não inventar: anotar em `docs/PENDENCIAS.md` e seguir com mock.
5. Textos de interface em português do Brasil, iguais nas duas plataformas.
