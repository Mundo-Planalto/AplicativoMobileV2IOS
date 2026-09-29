<!-- Cópia de https://github.com/rodrigoasilva1/AplicativoMobileV2IOS (clone local em ~/projetos/AplicativoMobileV2IOS). Os arquivos docs/*.md citados abaixo estão nesse repositório de documentação. -->

# App iOS Hard Rock Hotel & Vacation Club

Você é o agente que transforma o app iOS existente do **Mundo Planalto Portal** (Swift, Xcode) no app **Hard Rock Hotel & Vacation Club**, exatamente como foi feito na versão Android em 28/09/2026. O app é do clube de férias operado pela Mundo Planalto (Goiânia/GO). Responda e escreva textos de interface em **português do Brasil**.

## O que foi feito no Android (e você replica no iOS)

1. **Nova marca em todo o app**: tema único preto e dourado, nome "Hard Rock Vacation Club", ícone (estrela dourada sobre preto), splash e login novos com wordmark em texto. Ver `docs/design-system.md`.
2. **Navegação nova com 5 abas**: Início, Benefícios, Ofertas, Empreendimentos, Perfil. As abas antigas de Viagem (Produtos, Pacotes, Wallet) saem da barra.
3. **Telas novas com dados de demonstração fixos** (sem backend ainda): Início, Financeiro, Benefícios, Ofertas, Certificados de viagem, Unity e Milhas, Cartão digital com QR Code. Ver `docs/telas.md`, que traz os textos e valores exatos.
4. **Telas existentes mantidas com o visual novo**: Login, Extrato/boletos, Informe de rendimentos, Empreendimentos e Detalhes (sem "evolução da obra", só vídeos/fotos), Perfil (ganha o cartão do membro no topo), Avisos/Notícias.
5. **"Acessar demonstração"** no login: entra sem API com o usuário José R. Castro (membro 8150, Founder, desde 2026), para navegar as telas mock. O login real continua funcionando contra a API do portal.
6. Removido/desligado: chat com agente de IA, telas de Viagem com dados mock, evolução percentual da obra.

## Contexto e prazo

- **Meta: iOS submetido à App Store até 30/11/2026** (code freeze 15/11, submissão 18/11). Android publicado na mesma data.
- Equipe: Rodrigo Silva (gerente da área, arquiteto/dev sênior/DevOps, revisa tudo), agente Claude no Windows (Android), você (iOS), Orion (dev pleno, testes, a partir de 12/10). Backend pela equipe interna.
- Repositório Android: `Mundo-Planalto/AplicativoMobileV2` (privado). Este repositório: documentação do iOS.

## Fonte da verdade

1. `docs/telas.md`: especificação por tela, navegação e dados de demonstração. Textos e valores devem ser idênticos ao Android.
2. `docs/design-system.md`: cores, tipografia, componentes (`HrCard`, `HrGoldButton`, `HrHeader`...). Crie os componentes SwiftUI com esses nomes.
3. `docs/api-existente.md`: API do portal que o app já consome (login, financeiro, empreendimentos, perfil) e ambientes.
4. `docs/openapi-hardrock.yaml`: API nova (cartão/QR, parceiros, certificados, ofertas, milhas, collection, dispositivos). O backend ainda está implementando; até lá, repositórios `Mock`.
5. `docs/backend-implementacao.md`: ordem em que os endpoints novos chegam em homologação.
6. Ícone: `docs/ic_hr_foreground.xml` (vetor Android da estrela; recriar como asset iOS 1024x1024, estrela `#D4AF37` sobre `#0A0A0A`). Logo oficial em PNG virá depois; até lá, wordmark em texto.

## Regras técnicas

- Manter a arquitetura do app existente; se for UIKit, migrar as telas novas para SwiftUI é aceitável, mas sem reescrever o que funciona. iOS mínimo: o atual do projeto (não abaixo de 15).
- Camada de dados por protocolo (`BeneficiosRepository` etc.) com implementação `Mock` e `Remote`, escolhida por `AppConfig.useMockData` (padrão `true` até o backend existir).
- Token JWT no Keychain; nunca armazenar senha. Sem segredos no repositório (`Config.plist` e `GoogleService-Info.plist` ignorados; commitar `Config.example.plist`).
- QR Code com `CoreImage.CIQRCodeGenerator`, imagens remotas com `AsyncImage` sobre placeholder em gradiente escuro/dourado, YouTube/PDF em `WKWebView`.
- Sem dependências novas além do Firebase já usado para push.
- Commits pequenos em português (`feat: tela de Benefícios com dados mock`), terminando com `Co-Authored-By: Claude <noreply@anthropic.com>`. Antes de cada commit o build no simulador iPhone 15 deve passar.
- Não invente endpoints: o que não está em `api-existente.md` nem em `openapi-hardrock.yaml` fica mock e vai para `docs/PENDENCIAS.md`.

## Ordem de trabalho (um commit por etapa)

1. Design system + tema global + ícone + nome do app.
2. Splash e Login (com "Acessar demonstração").
3. Tab bar com as 5 abas e rotas.
4. Início, Financeiro, Benefícios, Ofertas, Certificados, Unity e Milhas, Cartão digital, Perfil com cartão: tudo com `Mock` conforme `docs/telas.md`.
5. Telas herdadas re-estilizadas (Extrato, Informe, Empreendimentos sem evolução da obra, Avisos).
6. Build de TestFlight para a diretoria (Build 1 do cronograma, 18/10).
7. Camada `Remote` da API nova conforme os endpoints entrarem em homologação.
