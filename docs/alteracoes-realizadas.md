# Alterações realizadas no app iOS Mundo Planalto

Registro de tudo o que foi feito no projeto `Mundo-Planalto-Portal-App-IOS` entre 29/09 e 06/10/2026,
a partir do app "Mundo Planalto Portal" que existia (último commit anterior: `1ae7c5a`, de 04/03/2026).
No total: 44 commits, 137 arquivos alterados. **Nenhum commit foi enviado ao GitHub ainda** (o repositório
remoto é `Mundo-Planalto/AplicativoMobileV2IOS`); tudo está só neste Mac até o "Push origin".

## 1. Resumo em uma página

| Área | Antes | Agora |
|---|---|---|
| Marca | "Mundo Planalto Portal", azul | **Mundo Planalto Vacation Club**, preto e dourado, símbolo e ícone oficiais do brandbook |
| Navegação | Abas Início, Empreendimentos, Financeiro, Perfil | 5 abas: **Início, Benefícios, Campanhas, Empreendimentos, Perfil** |
| Sessão | Caía ao abrir o app | **Fixa**: só sai em "Sair" ou com 401 confirmado duas vezes |
| Telas novas | Não existiam | Início, Viagens (certificados), Benefícios, Campanhas, página do empreendimento (hub), Galeria, Vídeos da obra, Documentos, Cartão digital com QR, Perfil de viagem, Alteração de dados, Configurações |
| Telas mantidas | Login, Financeiro, Extrato, Informe, Avisos | Mesmas telas no visual novo; Financeiro com card sem foto de fundo |
| Dados | Portal (financeiro, empreendimentos, avisos) | Portal para o que já existe; **dados de exemplo (mock)** para o que depende da API nova, com aviso na tela e ações travadas |
| Demonstração | Não existia | "Acessar demonstração" só em build de teste, com faixa fixa "DEMONSTRAÇÃO"; não existe em Release |
| Push | Permissão nunca era pedida; só tópico `announcements` | Permissão pedida, tópicos `announcements` + `user_{id}`, toque abre a tela certa mesmo com o app fechado; **entrega validada em iPad e iPhone reais** |
| Segurança | IP de rede interna fixo no app | IP e serviços removidos; token no Keychain; senha nunca gravada; segredos fora do git |

## 2. Linha do tempo

### 29/09: base nova sobre o app existente
- `5e248cf` URL da API passa a vir do `xcconfig` (`API_BASE_URL`), em vez de `localhost` fixo. Debug aponta para produção por autorização do TI, porque a homologação está fora do ar.
- `dfb9327` Design system preto e dourado (`HrTheme`, componentes `Hr*`), nome e ícone do app.
- `751e570` Splash e Login novos, com "Acessar demonstração".
- `ac51adf` Tab bar com 5 abas e sistema de rotas (`AppRouter`, `AppRoute`, `RouteView`).
- `d32d9bd` Primeiras telas novas com dados de exemplo.
- `e07a67b` Telas herdadas re-estilizadas; remoção do chat de IA e da Início antiga; sem percentual de obra.
- `49ff50f` Sessão real nunca mostra o nome do usuário de demonstração (nome vem de `auth/me`).
- `1c4affd` Histórico do repositório de documentação incorporado (`docs/`).

### 30/09: ajustes pedidos pelo TI
- `a633fa7` "Mundo Planalto" antes do login (não "Hard Rock", que é só um empreendimento).
- `4a199b0`, `0d16fd0` Botão "Sair" do Perfil deixava de ficar escondido atrás da barra de abas.

### 02/10: revisão do CEO de 01/10 aplicada por inteiro
- `2507111` Documentos da revisão e da marca (`docs/revisao-ceo-01-10.md`, `docs/marca.md`, `docs/telas.md`...).
- `d8ff3e2` Marca Mundo Planalto oficial: símbolo SVG, `MundoPlanaltoSymbol`, `MundoPlanaltoLogo`, paleta de dourados, ícone escuro.
- `8e6cac5` Fora da V1 removido: Milhas, Collection, The Orb, tela Unity e Milhas.
- `78c7587` Sessão fixa; demonstração só em debug.
- `08b4c36` Modelos e repositórios por protocolo (`Certificates`, `Partners`, `Campaigns`, `Ventures`, `Member`, `TravelProfile`, `ChangeRequests`), cada um com `Mock` e `Remote`, escolhidos por `AppConfig.useMockData`.
- `711540a` Viagens: certificados com status, protocolo e validade; navegador interno (`SFSafariViewController`).
- `0cea0f4` Benefícios: destaques com foto, parceiros, Unity no navegador interno.
- `bcb76b8` Campanhas (antiga Ofertas): filtros dinâmicos por categoria e CTA por tipo.
- `4e1afd9` Página do empreendimento (hub): capa, Financeiro, Galeria, Vídeos, Documentos, redes sociais e última atualização.
- `5852e9b` Perfil: cartão, perfil de viagem, alteração de dados (endereço usa o endpoint que já existe), preferências, troca de senha.
- `b50aea2` `openapi-hardrock.yaml`, `backend-implementacao.md` e `PENDENCIAS.md` atualizados.
- `553a5ad` Acompanhamento de obra com os dados do portal: atualizações (`ventureupdates`) da mais recente para a mais antiga e vídeos do book do empreendimento; erro de rede deixa de parecer lista vazia.
- `23d3ebb` "Indique um amigo" abre `https://hrh.vacation.mundoplanalto.com.br/` no navegador interno.

### 05/10: pendências do gerente (Rodrigo)
- `9cc71a7` Faixa fixa "DEMONSTRAÇÃO • dados de exemplo"; ativar certificado, usar código, interesse em campanha, salvar perfil de viagem e cupom travados com "Disponível em breve" (demonstração e login real); mocks sem sucesso inventado; aviso "Conteúdo de exemplo" nas telas sem backend.
- `a7d0ce1` `PDFService` e `SystemService` removidos, junto com a exceção de rede para o IP interno `10.35.0.55`.
- `45180bc` Demonstração não compila em Release; token de demonstração é descartado em build de loja.
- `51b0221` Rótulo "Disponível em breve" legível sobre fotos claras.
- `173462c` Push: tópico `user_{id}` depois do login (sai ao deslogar), toque na notificação com o app fechado, destino por chave `screen` do payload, diagnóstico de push em Configurações (só build de teste).
- `2cb8620` **Correção crítica:** o app nunca pedia permissão de notificação (cast de `UIApplication.shared.delegate` falhava com o adaptor do SwiftUI).
- `604ab11` Documentos: contrato de API pendente, guia de aparelho real e roteiro de push, bloqueadores da App Store, iPad e telas pequenas.

### 06/10: teste de push em aparelhos reais
- `49cc338` Inscrição nos tópicos refeita depois do token da Apple (antes falhava com "No APNS token specified").
- `ef49d8d` Resultado do teste registrado nos documentos.
- Fora do código: acesso da conta do TI ao projeto Firebase correto (`mundo-planalto-portal`, nº 907146044474), chave APNs `558BV2MC26` enviada também no campo de desenvolvimento, app iOS cadastrado por engano no projeto 23373676291 removido. **Push entregue e toque validado no iPad Air 5 e no iPhone 14 Plus do marketing.**

## 3. Estrutura do código criada

- `Theme/HrTheme.swift`: cores (`hrGold #9E8033`, `hrBlack`...), gradientes, fontes, métricas.
- `Components/Hr/`: `HrHeader`, `HrBackHeader`, `HrCard`, `HrPhoto`, `HrGoldButton`, `HrOutlineButton`, `HrTag`, `HrChip`, `HrListRow`, `HrTabBar`, `HrTextField`, `HrBrowser`, `HrDemo` (faixa e avisos), `MundoPlanaltoBrand`, `CartaoDigitalCard`, QR Code com CoreImage, player do YouTube em `WKWebView`.
- `Navigation/`: `AppRouter` (abas, pilhas, navegador interno, atalhos de teste `-hrTab`, `-hrRoute`, `-hrDemo`, `-hrResetSession`).
- `Repositories/`: modelos (`HardRockModels`, `ClubModels`), `HrApiClient`, repositórios `Mock`/`Remote`, `RepositoryProvider`.
- `Services/PushService.swift`: tópicos e destino do toque na notificação.
- `Views/HardRock/`: telas novas; `Views/`: telas herdadas re-estilizadas.
- `docs/`: `CLAUDE.md` (instruções), `revisao-ceo-01-10.md`, `telas.md`, `marca.md`, `design-system.md`, `api-existente.md`, `openapi-hardrock.yaml`, `backend-implementacao.md`, `PENDENCIAS.md`, `contrato-api-pendente.md`, `teste-aparelho-real.md`, `app-store-bloqueadores.md`, `ipad-telas-pequenas.md`, `brand/`.

## 4. Decisões tomadas no caminho

| Decisão | Quem | Quando |
|---|---|---|
| Debug aponta para a API de produção enquanto a homologação não responde | TI | 29/09 |
| Marca de lançamento é Mundo Planalto; "Hard Rock" só em conteúdo do empreendimento | CEO/Rodrigo | 01/10 |
| Ícone escuro vai para as lojas | Rodrigo | 05/10 |
| Link do "Indique um amigo" igual no Android | Rodrigo | 05/10 |
| Demonstração não vai para a App Store | Rodrigo | 05/10 |
| Projeto Firebase definitivo é o `mundo-planalto-portal` (907146044474) | TI | 06/10 |

## 5. O que ainda não está feito

Detalhado em `docs/app-store-bloqueadores.md` e `docs/PENDENCIAS.md`. Em resumo:

- Camada `Remote` da API nova: depende dos endpoints de `docs/contrato-api-pendente.md` entrarem em homologação.
- Decisões do Rodrigo: iPad (recomendada coluna central), remoção do Firebase Analytics/AI do projeto, telas de exemplo no build de loja.
- App Store: exclusão de conta no app, política de privacidade e termos, rótulos de privacidade, manifesto de privacidade, conta de teste para o revisor, capturas e textos.
- Build 1 no TestFlight em 18/10; submissão em 18/11; publicação em 30/11.
- Teste de aviso publicado pelo portal (caminho do backend) ainda não executado.
- Enviar os 44 commits ao GitHub ("Push origin" no GitHub Desktop).
