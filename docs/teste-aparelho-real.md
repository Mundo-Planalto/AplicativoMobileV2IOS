# Teste em iPhone real e roteiro de push

Guia para instalar o app no iPhone emprestado do marketing e validar as notificações de ponta a ponta.
Escrito em 05/10/2026 com base no projeto como está no commit desta data.

## 1. Requisitos do aparelho

| Item | Valor |
|---|---|
| Versão mínima de iOS do app | **17.6** (configuração `IPHONEOS_DEPLOYMENT_TARGET`) |
| Versão que o aparelho precisa ter | iOS 17.6 ou mais novo. Conferir em Ajustes > Geral > Sobre |
| Limite pelo lado do Mac | O Xcode desta máquina é o 26.3 (SDK iOS 26.2). Se o iPhone estiver em um iOS mais novo que o Xcode conhece, o Xcode pede atualização antes de instalar |
| Identificador do app no aparelho | `com.portal.MundoPlanalto` (time `L2AA5G4SRT`, PLANALTO SOLUCOES IMOBILIARIAS LTDA) |
| Cabo | USB-C ou Lightning de dados, ligado ao Mac do TI |

## 2. Dois caminhos de instalação

| | Direto pelo Xcode (cabo) | TestFlight |
|---|---|---|
| Precisa registrar o UDID | **Sim** (automático, ver abaixo) | Não |
| Precisa do Modo de Desenvolvedor | **Sim** | Não |
| Perfil de provisionamento | "iOS Team Provisioning Profile: com.portal.MundoPlanalto" (desenvolvimento, assinatura automática; vale até 30/09/2027) | Perfil de distribuição da App Store, criado pelo Xcode ao exportar |
| Tipo de build | Debug: tem "Acessar demonstração" e o **Diagnóstico de push** em Configurações | Release: sem demonstração e sem diagnóstico |
| Ambiente de push da Apple | Desenvolvimento (sandbox) | Produção |
| O que exige | Aparelho na mão, cabo, 10 minutos | Subir um build ao App Store Connect, esperar o processamento (10 a 30 min) e convidar o Apple ID de quem vai testar como testador interno; a pessoa instala o app TestFlight |
| Validade | 1 ano (conta paga) | 90 dias por build |

**Recomendação:** instalar **pelo Xcode** para o teste de push desta semana, porque é o único caminho que
mostra o token e o diagnóstico na tela e os registros no console. O TestFlight entra no Build 1 de 18/10,
para a diretoria, e aí repetimos os casos 4 a 7 do roteiro, porque o TestFlight usa o ambiente de produção
da Apple, que é o mesmo da loja.

## 3. Passo a passo pelo Xcode

1. **Desbloquear o iPhone e ligar no Mac.** No aparelho, tocar em "Confiar" e digitar o código.
2. **Registrar o UDID.** Não é preciso copiar o UDID nem entrar no site da Apple: na primeira instalação
   o Xcode registra o aparelho no time e renova o perfil sozinho (foi assim com o iPad e com o iPhone do
   Artur). Se falhar com "device not registered", o caminho manual é developer.apple.com > Account >
   Certificates, IDs & Profiles > Devices > "+", com o UDID que aparece em Xcode > Window > Devices and
   Simulators. Hoje o perfil tem 3 aparelhos; o limite é 100 iPhones por ano de assinatura.
3. **Ligar o Modo de Desenvolvedor** (o iOS só mostra a opção depois que o aparelho foi ligado ao Xcode):
   Ajustes > Privacidade e Segurança > Modo de Desenvolvedor > ligar > Reiniciar. Depois de reiniciar,
   desbloquear e tocar em "Ativar" no aviso, com o código do aparelho.
4. **Instalar.** Com o aparelho conectado e desbloqueado, me avise "conectei" que eu compilo e instalo
   daqui (mesmo processo do iPhone do Artur). Pelo Xcode na mão: escolher o aparelho no topo e Product > Run.
5. **Primeira abertura.** Se aparecer "Desenvolvedor não confiável": Ajustes > Geral > VPN e Gerenciamento
   de Dispositivo > confiar no time. Com conta paga isso normalmente não aparece.
6. **Ao devolver o aparelho:** apagar o app, desligar o Modo de Desenvolvedor e, se quiser liberar a vaga,
   desativar o aparelho na lista de Devices (a vaga só volta na renovação anual).

Se o aviso do contrato da Apple (PLA) voltar a aparecer, o titular da conta precisa aceitar em
developer.apple.com, como em 29/09.

## 4. O que precisa estar configurado para o push

### Já conferido no projeto (por mim)

| Item | Situação |
|---|---|
| Bundle id do app no aparelho igual ao do Firebase | Sim: `com.portal.MundoPlanalto` nos dois (projeto Firebase `mundo-planalto-portal`) |
| Capability Push Notifications no App ID | Sim: o perfil de provisionamento traz `aps-environment` |
| Entitlement `aps-environment` no app | Sim (`development`; o Xcode troca para `production` ao exportar para TestFlight/loja) |
| Background Modes > Remote notifications | Sim (`UIBackgroundModes: remote-notification`) |
| Token da Apple repassado ao Firebase | Sim, manualmente (`FirebaseAppDelegateProxyEnabled = false` e `Messaging.apnsToken`) |
| Pedido de permissão ao usuário | **Corrigido em 05/10.** Antes o app nunca mostrava o pedido de permissão (commit `2cb8620`) |
| Tópicos | `announcements` para todos; `user_{id}` depois do login, saindo do tópico ao deslogar (novo em 05/10) |
| Toque na notificação com o app fechado | **Corrigido em 05/10.** Antes o toque se perdia quando o app não estava aberto |

### Conferido no Firebase em 06/10

| Item | Situação |
|---|---|
| Projeto do Firebase | `mundo-planalto-portal` (número **907146044474**). O projeto `mundo-planalto-portal-e81bb` (23373676291), que também se chama "Mundo Planalto Portal", não é usado pelo app nem pelo backend; o cadastro iOS feito lá por engano foi removido |
| Acesso | `timundoplanalto@gmail.com` é editor do projeto certo desde 06/10 |
| Chave APNs | `558BV2MC26` (time `L2AA5G4SRT`) nos **dois** campos, desenvolvimento e produção. Até 06/10 só estava em produção, e por isso o build instalado pelo cabo não recebia nada |
| Resultado | Mensagem de teste pelo console chegou no iPad Air e no iPhone 14 Plus (app aberto e bloqueado; toque abriu Avisos). **Backend:** depois da correção implantada em 08/10, o `portal_dev` enviou o aviso nº 1 para o tópico `user_212` às 10:22 com `SUCESSO` no log (caminho portal → Firebase validado). Falta o primeiro aviso real em produção |

### Precisa ser conferido por alguém com acesso

| Onde | O que conferir |
|---|---|
| Firebase Console > Configurações do projeto > Cloud Messaging > app iOS | **Chave de autenticação APNs (.p8)** enviada, com o Key ID e o Team ID `L2AA5G4SRT`. Uma chave .p8 serve para sandbox e produção. Se no lugar houver certificados .p12, conferir se o de desenvolvimento e o de produção estão válidos |
| developer.apple.com > Keys | A chave APNs existe e não foi revogada |
| Firebase Console > app iOS | O app iOS cadastrado é o `com.portal.MundoPlanalto` |
| Backend | Para qual tópico ou token ele envia hoje, e se manda o bloco `notification` (título e corpo). Mensagem só com `data` não aparece na tela do iOS |

Nota: no simulador o bundle id é outro (`Mundo-planalto-Portal-App.Mundo-planalto-Portal-App`) e o Firebase
não entrega push para ele. Push só se valida em aparelho real.

## 5. Roteiro de teste ponta a ponta

Preparação: instalar pelo Xcode, deixar o Mac com o console aberto (ou só usar a tela de diagnóstico),
entrar com um cliente real e abrir Perfil > Configurações > **Diagnóstico de push**.

| # | Caso | Como fazer | Resultado esperado |
|---|---|---|---|
| 1 | Permissão | Instalar do zero e abrir o app. Poucos segundos depois da abertura aparece o aviso do iOS | Aviso "Mundo Planalto deseja enviar notificações". Tocar em Permitir. No diagnóstico: Permissão "Concedida" |
| 2 | Registro na Apple | Olhar o diagnóstico | "Registro na Apple (APNs): Registrado". No console: `[Push] APNs token registrado` |
| 3 | Token do Firebase | Olhar o diagnóstico e tocar em "Copiar token de push" | "Token do Firebase: Recebido"; tópicos `announcements, user_{id}`. No console: `[FCM] Inscrito no tópico ...` |
| 4 | App aberto | Firebase Console > Messaging > Nova campanha > Notificações > "Enviar mensagem de teste", colando o token | Banner no topo com som, com o app na frente. O contador do sino atualiza |
| 5 | App em segundo plano | Ir para a tela de início do iPhone (sem fechar o app) e enviar de novo | Notificação na tela bloqueada e na central |
| 6 | App fechado | Fechar o app pelo seletor de apps (arrastar para cima) e enviar de novo | Notificação chega do mesmo jeito |
| 7 | Toque abre a tela certa | Tocar na notificação em cada um dos três estados (4, 5 e 6) | Abre **Avisos**. No caso 6 o app abre do zero e vai para Avisos depois do carregamento |
| 8 | Destino por tipo | Enviar com dado personalizado `screen` = `ventures`, depois `certificates`, `campaigns`, `financial` (Firebase: Opções adicionais > Dados personalizados) | Abre Empreendimentos, Viagens, Campanhas e Financeiro, respectivamente |
| 9 | Envio por tópico | Enviar para o tópico `announcements` e depois para `user_{id}` do cliente logado | Os dois chegam. A inscrição em tópico pode levar alguns minutos na primeira vez |
| 10 | Sair da conta | Perfil > Sair e enviar para `user_{id}` | Não chega mais. `announcements` continua chegando |
| 11 | Envio real pelo backend | Publicar um aviso pelo portal (fluxo que já existe) | Chega no aparelho e o toque abre Avisos com o aviso na lista |
| 12 | Permissão negada | Ajustes > Notificações > Mundo Planalto > desligar; abrir o app | Diagnóstico mostra "Negada (ative em Ajustes)". Nada chega. Religar e conferir que volta |

Se o caso 4 falhar com o token "Recebido": o problema quase sempre é a chave APNs no Firebase (seção 4).
Se o token nem chegar: conferir a permissão e se o aparelho tem internet.

## 6. O que eu não consigo validar sozinho

- A chegada da notificação em si: depende de aparelho real, da chave APNs no Firebase e de alguém tocar na tela.
- A configuração do Firebase Console e do portal da Apple (não tenho acesso a nenhum dos dois).
- O envio pelo backend e o formato do payload que ele manda hoje.
- O comportamento no ambiente de **produção** da Apple, que só existe em build de TestFlight ou loja.

O que já validei no simulador: o pedido de permissão aparece, o app compila em Debug e Release, e a
navegação por destino está ligada à tela principal. O toque na notificação não é automatizável daqui.

## 7. Pendências de push que continuam abertas

- `POST /devices` (registro do token por aparelho) ainda não existe no backend; por isso o envio direcionado
  depende do tópico `user_{id}`.
- O interruptor "Notificações push" em Configurações só grava a preferência no aparelho; não cancela a
  inscrição nos tópicos.
- O backend ainda não envia a chave `screen`; até lá, todo toque abre Avisos.
