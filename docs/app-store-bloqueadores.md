# O que falta para submeter à App Store em 18/11

Levantado em 05/10/2026 a partir do projeto e do binário de Release. "Bloqueante" é o que impede o envio
ou tem alta chance de reprovação na revisão; "desejável" melhora a chance de aprovar de primeira ou evita
perguntas. Onde escrevo "conferir", é porque depende do App Store Connect, a que não tenho acesso.

## Bloqueantes

| # | Item | Situação hoje | O que precisa | Quem |
|---|---|---|---|---|
| 1 | **Exclusão de conta dentro do app** | Não existe. O app tem "Primeiro acesso" (`POST auth/register`, tela "Crie sua Conta"), então a regra 5.1.1(v) da Apple se aplica | Opção em Perfil > Segurança que **inicia** a exclusão (pode virar um pedido para a Central, com protocolo), mais o endpoint. Mandar o cliente ligar ou enviar e-mail não é aceito. Tirar o "Primeiro acesso" do app evitaria a regra, mas piora a entrada do cliente | Backend (endpoint) e iOS (tela, cerca de meio dia) |
| 2 | **Política de privacidade** | A tela do app mostra "Em construção" e o link de Termos abre a mesma tela | URL pública definitiva. É campo obrigatório no App Store Connect e precisa abrir dentro do app | Jurídico/marketing (texto e URL); iOS liga em 1 hora |
| 3 | **Termos de uso** | Mesmo placeholder | URL pública, ou usar o contrato padrão da Apple (EULA) e remover a linha do app | Jurídico |
| 4 | **Telas com conteúdo de exemplo e "Disponível em breve"** | Com `AppConfig.useMockData = true`, o Release mostra certificados, parceiros, campanhas e cartão fictícios, com avisos de exemplo. A regra 2.1 reprova app com função incompleta ou conteúdo de teste | Até o congelamento de 15/11: ou os endpoints estão em produção e o app usa a camada `Remote`, ou as áreas sem backend saem do build de loja (ocultar aba/atalho). Decidir área por área com o cronograma do backend | Rodrigo (decisão), backend, iOS |
| 5 | **Conta de teste para o revisor** | A demonstração não existe em Release | Um cliente de teste em produção (CPF e senha) com financeiro, boleto, empreendimento com fotos e vídeos, avisos e, se entrarem, certificado e campanha. Informar em App Review Information, com uma nota explicando que o app é para clientes da Mundo Planalto e que o "Primeiro acesso" exige CPF de cliente | Backend/Central |
| 6 | **Rótulos de privacidade (App Privacy)** | Não preenchidos para esta versão (conferir) | Questionário do App Store Connect. Proposta na seção abaixo | Rodrigo, com a proposta abaixo |
| 7 | **Manifesto de privacidade do app** | **Feito em 08/10**: `PrivacyInfo.xcprivacy` com `UserDefaults` (`CA92.1`), sem rastreamento, e os dados coletados (contato, ID do usuário, ID do dispositivo, financeiro, interação com o produto e diagnóstico do Firebase) | Manter igual aos rótulos do App Store Connect | iOS |
| 8 | **Firebase Analytics e identificador de publicidade no binário** | **Decisão de 08/10: manter e declarar.** O manifesto já declara interação com o produto e ID do dispositivo para análise, sem rastreamento | Preencher os rótulos do App Store Connect conforme a seção abaixo (versão "com Analytics"). Se a Apple questionar o IDFA (`GoogleAppMeasurementIdentitySupport`), remover só esse produto do projeto | Rodrigo (rótulos); iOS |
| 9 | **Número de versão** | 1.0.9 (build 11) | Versão maior que a última enviada ao App Store Connect. Sugestão: 2.0.0 (1), por ser app novo para o cliente (conferir o histórico) | iOS |
| 10 | **Capturas de tela e textos da loja** | Não preparados | Capturas de iPhone 6,9" (obrigatório) e de iPad 13" se o iPad continuar suportado; nome, subtítulo, descrição, palavras-chave, URL de suporte, categoria e classificação etária | Marketing; eu gero as capturas |

## Desejáveis

| # | Item | Situação hoje | Por quê |
|---|---|---|---|
| 11 | Comprovação de uso da marca Hard Rock | O app mostra "Hard Rock Hotel Gramado" e o card "Hard Rock Unity" | A Apple pode pedir prova de autorização de marca de terceiro (regra 5.2.1). Ter a carta ou o contrato de licença em mãos e citar na nota ao revisor |
| 12 | iPad | **Decisão de 08/10: fica como está** (layout de telefone esticado) até a V2 | Ainda obrigatório: capturas de tela de iPad 13" na loja e conferir que nada quebra na revisão em iPad |
| 13 | Orientação | iPhone aceita paisagem; o layout é só retrato | Travar em retrato evita tela quebrada na revisão |
| 14 | Plataformas | O projeto está marcado também para Mac e Vision Pro | Desmarcar, ou o app aparece para aparelhos em que nunca foi testado |
| 15 | Requisitos de aparelho | O Info.plist exige `gps` e `location-services`, e o app não usa localização | Remover (afrouxar requisito é permitido em atualização) |
| 16 | Criptografia | Falta `ITSAppUsesNonExemptEncryption = NO` | Sem a chave, o App Store Connect faz a pergunta a cada build enviado |
| 17 | Exceção de rede | O Info.plist ainda permite HTTP sem criptografia para `portal.mundoplanalto.com.br` | O app só usa HTTPS; remover depois de confirmar que nenhuma imagem vem por HTTP |
| 18 | Entitlement de push | O arquivo tem uma chave duplicada que não existe (`com.apple.developer.aps-environment`) | Não atrapalhou os builds de teste, mas pode dar erro ao exportar para a loja. Limpar e testar um arquivamento antes de 18/10 |
| 19 | Sessão de 7 dias | O JWT expira em 7 dias e não há renovação | Não reprova, mas o revisor e o cliente voltam ao Login. Depende de `auth/refresh` |
| 20 | Código sem uso | `RegisterView`, `CriarTicketView`, `SolicitarAtendimentoModal`, `IncomeTaxReportView`, `PdfViewerView` não são abertos por nenhuma tela | Limpeza; reduz risco de texto antigo aparecer |
| 21 | Preferência "Notificações push" | Só grava no aparelho | Fazer o interruptor cancelar a inscrição nos tópicos |

## Proposta de rótulos de privacidade

Válida **se** o Analytics e o identificador de publicidade forem removidos (item 8). Todos os dados são
"vinculados ao usuário" e usados para "funcionalidade do app"; nenhum é usado para rastreamento.

| Categoria da Apple | Dado | Por que o app coleta |
|---|---|---|
| Informações de contato | Nome, e-mail, telefone, endereço | Perfil do cliente e pedidos de alteração de dados |
| Identificadores | ID do usuário (CPF/CNPJ usado no login); ID do dispositivo (token de push) | Login e envio de notificações |
| Informações financeiras | Outras informações financeiras (parcelas, saldo, boletos) | Tela Financeiro e Extrato |
| Informações sensíveis | Avaliar com o jurídico se o CPF entra aqui ou só em Identificadores | Login |
| Conteúdo do usuário | Perfil de viagem (destinos, cidade), quando o endpoint existir | Personalizar campanhas |
| Diagnóstico | Nenhum, se o Analytics sair | |

Se o Analytics ficar: acrescentar "Dados de uso > Interação com o produto" e "Identificadores > ID do
dispositivo" para análise, e avaliar o pedido de permissão de rastreamento.

## Já resolvido nesta rodada

| Item | Commit |
|---|---|
| Demonstração não existe em Release (botão, atalho e função fora do binário; token de demonstração descartado) | `45180bc` |
| IP da rede interna `10.35.0.55` fora do app (serviços e exceção de rede) | `a7d0ce1` |
| Ações sem backend travadas com "Disponível em breve", sem sucesso inventado | `9cc71a7` |
| Pedido de permissão de notificação voltou a aparecer | `2cb8620` |

## Sugestão de calendário

| Até | O quê |
|---|---|
| 12/10 | Decisões dos itens 4, 8 e do iPad; pedido de texto/URL de política e termos; pedido da conta de teste |
| 18/10 (Build 1) | Primeiro arquivamento enviado ao TestFlight: valida assinatura de distribuição, entitlement de push e número de versão (itens 9, 16, 18) |
| 01/11 (Build 2) | Exclusão de conta, política e termos ligados, manifesto de privacidade, iPad resolvido |
| 15/11 (congelamento) | Item 4 fechado: nada de exemplo no build de loja |
| 18/11 | Submissão com rótulos, capturas, conta de teste e nota ao revisor |
