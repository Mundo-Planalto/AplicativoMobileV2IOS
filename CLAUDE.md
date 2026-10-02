# App iOS Mundo Planalto / Hard Rock Hotel & Vacation Club

Você é o agente que transforma o app iOS existente do **Mundo Planalto Portal** (Swift, Xcode) na nova versão do app do clube de férias operado pela Mundo Planalto (Goiânia/GO), espelhando o que está sendo feito no Android (`Mundo-Planalto/AplicativoMobileV2`). Responda e escreva textos de interface em **português do Brasil**.

**Atualização de 01/10/2026:** o CEO revisou o MVP e mudou marca, navegação e várias telas. Leia `docs/revisao-ceo-01-10.md` antes de qualquer coisa; `docs/telas.md` já reflete o estado final. Em conflito entre arquivos, vale a ordem: `revisao-ceo-01-10.md` > `telas.md` > este arquivo > demais docs.

## O que o app entrega (estado após 01/10)

1. **Marca**: tema preto e dourado com a identidade **Mundo Planalto**: símbolo oficial em `docs/brand/simbolo-mundo-planalto.svg`, dourado `#9E8033`, componentes `MundoPlanaltoSymbol` e `MundoPlanaltoLogo`, ícone do app em `docs/brand/`. Regras em `docs/marca.md`. "Hard Rock" só em conteúdo do empreendimento. Botões em dourado sólido.
2. **Navegação com 5 abas**: Início, Benefícios, Campanhas, Empreendimentos, Perfil. As abas antigas de Viagem (Produtos, Pacotes, Wallet) saem da barra; Ofertas virou Campanhas.
3. **Sessão fixa**: depois do login o app não desloga sozinho.
4. **Telas novas com dados de demonstração fixos** (sem backend ainda): Início, Viagens (certificados com status, protocolo e validade), Benefícios (destaques + parceiros + Unity em WebView), Campanhas (filtros dinâmicos e CTA rastreável), Página do empreendimento (hub com Financeiro, Galeria, Vídeos, Documentos e redes sociais), Perfil com perfil de viagem e alteração de dados, Cartão digital com QR Code.
5. **Telas existentes mantidas com o visual novo**: Login, Financeiro (card sem foto de fundo), Extrato/boletos, Informe de rendimentos, Avisos/Notícias.
6. **"Acessar demonstração"** no login (só em debug, `AppConfig.showDemoLogin`): entra sem API com o usuário José R. Castro (membro 8150, Founder, desde 2026).
7. **Fora da V1 (não implementar):** Milhas, Collection, chat de IA, telas de Viagem com dados mock antigas, evolução percentual da obra, cadastro de não-cliente, brinde por QR, 2FA, The Orb.

## Contexto e prazo

- **Meta: iOS submetido à App Store até 30/11/2026** (Build 1 em 18/10, Build 2 em 01/11, code freeze 15/11, submissão 18/11). Android publicado na mesma data.
- Equipe: Rodrigo Silva (gerente da área, arquiteto/dev sênior/DevOps, revisa tudo), agente Claude no Windows (Android), você (iOS), Orion (dev pleno, testes, a partir de 12/10). Backend pela equipe interna.
- Repositório Android: `Mundo-Planalto/AplicativoMobileV2` (privado). Este repositório: código e documentação do iOS.

## Fonte da verdade

1. `docs/revisao-ceo-01-10.md`: o que mudou em 01/10 e por quê; ordem de aplicação; impacto no backend; o que ficou de fora.
2. `docs/telas.md`: especificação por tela, navegação e dados de demonstração. Textos e valores devem ser idênticos ao Android.
3. `docs/marca.md`: símbolo, área de proteção, ícone do app, paleta de dourados oficial e componentes de marca. Vale sobre o design system.
4. `docs/design-system.md`: tipografia, formas e componentes (`HrCard`, `HrGoldButton`, `HrHeader`...). Crie os componentes SwiftUI com esses nomes.
5. `docs/api-existente.md`: API do portal que o app já consome (login, financeiro, empreendimentos, perfil) e ambientes.
6. `docs/openapi-hardrock.yaml`: API nova. **Precisa ser atualizado** conforme a seção 3 de `revisao-ceo-01-10.md` (certificados por cliente, campanhas, perfil de viagem com próxima viagem, alteração de dados, redes sociais do empreendimento; remover milhas e collection). Até lá, repositórios `Mock`.
7. `docs/backend-implementacao.md`: ordem em que os endpoints novos chegam em homologação (também a atualizar).
8. Assets: `docs/brand/` (SVG do símbolo, ícone 1024, vetor Android). A logo horizontal oficial ainda virá; `docs/ic_hr_foreground.xml` (estrela) deixa de ser usado.

## Regras técnicas

- Manter a arquitetura do app existente; se for UIKit, migrar as telas novas para SwiftUI é aceitável, mas sem reescrever o que funciona. iOS mínimo: o atual do projeto (não abaixo de 15).
- Camada de dados por protocolo (`CertificatesRepository`, `PartnersRepository`, `CampaignsRepository`, `VenturesRepository`, `MemberRepository`, `TravelProfileRepository`, `ChangeRequestsRepository`) com implementação `Mock` e `Remote`, escolhida por `AppConfig.useMockData` (padrão `true` até o backend existir).
- Token JWT no Keychain; nunca armazenar senha. Sessão fixa: só limpar o token em "Sair" ou 401 persistente. Sem segredos no repositório (`Config.plist` e `GoogleService-Info.plist` ignorados; commitar `Config.example.plist`).
- Links externos sempre no navegador interno (`SFSafariViewController` ou `WKWebView` em sheet com "Fechar"); `wa.me`, Instagram e YouTube podem abrir o app nativo.
- QR Code com `CoreImage.CIQRCodeGenerator`, imagens remotas com `AsyncImage` sobre placeholder em gradiente escuro/dourado, YouTube/PDF em `WKWebView`.
- Sem dependências novas além do Firebase já usado para push.
- Commits pequenos em português (`feat: tela Viagens com certificados mock`), terminando com `Co-Authored-By: Claude <noreply@anthropic.com>`. Antes de cada commit o build no simulador iPhone 15 deve passar.
- Não invente endpoints: o que não está em `api-existente.md` nem em `openapi-hardrock.yaml` fica mock e vai para `docs/PENDENCIAS.md`.

## Ordem de trabalho (um commit por etapa)

Se o projeto ainda está no estado de 28/09 (ou antes), siga esta ordem; se as etapas 1 a 5 já foram feitas, aplique a seção 7 de `docs/revisao-ceo-01-10.md` como diff.

1. Design system com a paleta de `docs/marca.md` + `MundoPlanaltoSymbol` + `MundoPlanaltoLogo` + ícone do app (`docs/brand/app-icon-1024-escuro.png`) + nome do app.
2. Splash e Login (com "Acessar demonstração" só em debug) e sessão fixa.
3. Tab bar com as 5 abas (Início, Benefícios, Campanhas, Empreendimentos, Perfil) e rotas, incluindo o navegador interno.
4. Modelos e repositórios `Mock`: certificados, parceiros (com `featured`), campanhas, empreendimento (com redes sociais), perfil de viagem, alteração de dados, cartão.
5. Início, Viagens, Benefícios, Campanhas, Empreendimentos + Página do empreendimento, Financeiro, Perfil + Perfil de viagem + Alteração de dados, Cartão digital: tudo conforme `docs/telas.md`.
6. Telas herdadas re-estilizadas (Extrato, Informe, Avisos, Galeria, Vídeos).
7. Atualizar `docs/openapi-hardrock.yaml`, `docs/backend-implementacao.md` e `docs/PENDENCIAS.md`.
8. Build de TestFlight para a diretoria (Build 1 do cronograma, 18/10).
9. Camada `Remote` da API nova conforme os endpoints entrarem em homologação.
