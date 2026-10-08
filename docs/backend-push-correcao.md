# Push do portal não chega aos aparelhos: diagnóstico e correção para o backend

Documento para o time do backend do Portal Mundo Planalto (`MundoPlanaltoPortal`, .NET, servidor `srv-zapzap` /
`177.136.206.246`). Escrito em 07/10/2026 a partir dos testes com o app iOS em dois aparelhos reais e de
leituras **somente de leitura** no servidor de produção, feitas com autorização do TI.

## 1. Resumo executivo

- O caminho **Firebase → Apple → app** está funcionando: mensagens enviadas pelo console do Firebase
  (projeto `mundo-planalto-portal`, número **907146044474**) chegaram ao iPad Air e ao iPhone 14 Plus, com o
  app aberto, em segundo plano e fechado, e o toque abriu a tela certa.
- O caminho **portal → Firebase não funciona**: o aviso "Novidades" criado em 06/10 às 15:57 pelo admin do
  portal apareceu na lista de avisos do app (a API está certa), mas **nenhum push foi enviado**. O relatório do
  Firebase registra 1 único envio em 90 dias nesse projeto, e foi um teste manual nosso.
- Causa encontrada no servidor: **o backend não tem credencial do Firebase configurada** (nem arquivo de conta
  de serviço, nem variável de ambiente, nem seção no `appsettings.json`), e no minuto da criação do aviso o log
  mostra **erros de gravação no PostgreSQL** por `DateTime` sem fuso, provavelmente na etapa que registra o envio.
- Nada precisa mudar no app iOS. A correção é no backend: configurar a conta de serviço do projeto
  907146044474, corrigir o `DateTime` para UTC e garantir o formato da mensagem. Estimativa: 2 a 4 horas,
  mais o teste.

## 2. Como chegamos aqui (evidências)

### 2.1 Testes com o app

| Data | Teste | Resultado |
|---|---|---|
| 05/10 | iPad: permissão, registro APNs, token FCM, tópicos | OK (`announcements`, `user_212`) |
| 06/10 | Mensagem de teste pelo console do Firebase para o token do iPad | Chegou (app aberto e bloqueado); toque abriu Avisos |
| 06/10 | Mensagem de teste para o token do iPhone 14 Plus | Chegou (app aberto e bloqueado); toque abriu Avisos |
| 06/10 15:57 | Aviso "Novidades" criado no admin do portal, tipo Aviso, todos os empreendimentos | Apareceu em Avisos no app. **Nenhuma notificação** em nenhum dos dois aparelhos |

Detalhe que importa: até 06/10 a chave APNs do projeto estava só no campo de produção do Firebase; foi
adicionada também no campo de desenvolvimento. Isso resolveu os testes pelo console, mas **não** explica a
falha do portal, porque o Firebase não recebeu nada do portal.

### 2.2 O que está no servidor de produção

Serviço `portal.service`, usuário `dev`, executável `/opt/portal/app/MundoPlanaltoPortal`, porta 5082.

| Verificação | Resultado |
|---|---|
| `/opt/portal/app/appsettings.json` | Nenhuma seção `Firebase`, `Fcm`, `Google` ou `Push` |
| `/opt/portal/app/appsettings.Development.json` | Idem |
| Unidade systemd (`systemctl cat portal`) | Só `Environment=ASPNETCORE_URLS=http://0.0.0.0:5082`; sem `GOOGLE_APPLICATION_CREDENTIALS`, sem `EnvironmentFile` |
| Arquivo de conta de serviço (JSON com `private_key_id`) | Nenhum encontrado no disco (busca até 6 níveis de profundidade) |
| Bibliotecas em `/opt/portal/app` | `FirebaseAdmin.dll`, `Google.Apis.Auth.dll`, `Google.Api.Gax.*`: o código usa o SDK Admin (API HTTP v1), o que é correto |
| `journalctl -u portal` em 06/10 15:30–17:30, filtrado por firebase/fcm/push/announcement/error | **Zero** linhas de Firebase/FCM. Às 15:57:09, 15:57:17, 15:57:30 e 15:57:52: `DbUpdateException` → `System.ArgumentException: Cannot write DateTime with Kind=Unspecified to PostgreSQL type 'timestamp with time zone', only UTC is supported`. Às 15:57:20: `DbUpdateConcurrencyException: expected to affect 1 row(s), but actually affected 0 row(s)` |

### 2.3 No Firebase (projeto 907146044474)

- API Cloud Messaging **v1 ativada**; API legada **desativada** (padrão do Google desde 2024).
- App iOS `com.portal.MundoPlanalto` cadastrado; chave APNs `558BV2MC26` (time `L2AA5G4SRT`) nos dois ambientes.
- `timundoplanalto@gmail.com` tem papel de editor desde 06/10; serve para gerar a conta de serviço.
- Existe um **segundo projeto homônimo**, `mundo-planalto-portal-e81bb` (número 23373676291), que **não** deve
  ser usado: não tem o app iOS e o token dos aparelhos não pertence a ele.

## 3. Causas

1. **Sem credencial.** O SDK Admin precisa de uma conta de serviço do projeto. Sem `GOOGLE_APPLICATION_CREDENTIALS`,
   sem arquivo e sem configuração, `FirebaseApp.Create()` falha ou `FirebaseMessaging.DefaultInstance` lança
   exceção; se o código captura a exceção sem registrar, o envio simplesmente não acontece, que é o que o log
   mostra (silêncio total sobre Firebase).
2. **`DateTime` sem fuso ao gravar no PostgreSQL.** Com Npgsql 6 ou mais novo, colunas `timestamp with time zone`
   só aceitam `DateTime` com `Kind=Utc`. Algum `DateTime.Now` (ou data vinda do formulário) está sendo gravado
   nessa coluna no fluxo de criação/envio do aviso. Se a gravação do "envio" acontece antes da chamada ao
   Firebase, ela aborta o fluxo; se acontece depois, pelo menos o histórico fica errado.
3. **Possível:** o `DbUpdateConcurrencyException` às 15:57:20 sugere uma segunda tentativa de atualizar o mesmo
   registro já alterado (retry ou duplo clique). Vale conferir se o envio é idempotente.

## 4. Correção passo a passo

### 4.1 Gerar a conta de serviço (Firebase)

1. Firebase Console, projeto **Mundo Planalto Portal (907146044474)**: conferir o número em
   Configurações do projeto > Geral antes de qualquer coisa, porque há dois projetos com o mesmo nome.
2. Configurações do projeto > **Contas de serviço** > "Gerar nova chave privada". Baixa um JSON com
   `project_id: "mundo-planalto-portal"` e `client_email: firebase-adminsdk-...@mundo-planalto-portal.iam.gserviceaccount.com`.
3. Esse arquivo é uma **chave privada**: não entra no repositório, não vai por e-mail/WhatsApp aberto, não fica
   em pasta servida pelo nginx. Transferir por canal seguro (scp direto para o servidor).

### 4.2 Instalar no servidor

```bash
sudo mkdir -p /etc/portal
sudo mv /caminho/do/arquivo-baixado.json /etc/portal/firebase-sa.json
sudo chown dev:dev /etc/portal/firebase-sa.json
sudo chmod 600 /etc/portal/firebase-sa.json
```

Conferir, sem expor a chave:

```bash
grep -oE '"(project_id|client_email)": *"[^"]+"' /etc/portal/firebase-sa.json
```

Tem que mostrar `mundo-planalto-portal` (sem `-e81bb`).

### 4.3 Apontar o serviço para a credencial

Opção recomendada, sem mexer no código: variável de ambiente na unidade.

```bash
sudo systemctl edit portal
```

Conteúdo do override:

```ini
[Service]
Environment=GOOGLE_APPLICATION_CREDENTIALS=/etc/portal/firebase-sa.json
```

Depois:

```bash
sudo systemctl daemon-reload
sudo systemctl restart portal
systemctl show portal -p Environment
```

Se o código carrega a credencial por caminho em `appsettings.json` (ver 4.4), colocar o mesmo caminho lá.
Fazer o mesmo no `portal_dev.service` (`/bin/portal_dev`) para testar primeiro em desenvolvimento.

### 4.4 Inicialização no código (referência)

Como o `FirebaseApp` deve ser criado uma única vez, no startup, e falhar **de forma visível** se a credencial
não existir:

```csharp
// Program.cs (ou Startup)
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;

var credentialPath = Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS")
    ?? builder.Configuration["Firebase:CredentialsPath"];

if (string.IsNullOrWhiteSpace(credentialPath) || !File.Exists(credentialPath))
    throw new InvalidOperationException(
        "Credencial do Firebase não configurada (GOOGLE_APPLICATION_CREDENTIALS ou Firebase:CredentialsPath).");

if (FirebaseApp.DefaultInstance is null)
{
    FirebaseApp.Create(new AppOptions
    {
        Credential = GoogleCredential.FromFile(credentialPath),
        ProjectId = "mundo-planalto-portal"
    });
}
```

Se preferirem que o portal suba mesmo sem credencial (por exemplo em desenvolvimento), trocar o `throw` por um
`logger.LogCritical(...)` e fazer o `FirebaseService` registrar `LogError` em toda falha de envio. O ponto
central é: **falha de push nunca pode ser silenciosa**.

### 4.5 Formato da mensagem

O app iOS só exibe notificação quando existe o bloco `notification`; mensagens só com `data` não aparecem.
Para abrir a tela certa no toque, o app lê a chave `screen` em `data` (ausente = Avisos).

```csharp
using FirebaseAdmin.Messaging;

var message = new Message
{
    Topic = "announcements",            // ou $"user_{customerUserId}" para um cliente
    Notification = new Notification
    {
        Title = announcement.Title,
        Body  = PlainText(announcement.Content, maxLength: 180) // sem HTML
    },
    Data = new Dictionary<string, string>
    {
        ["screen"] = "avisos",
        ["announcementId"] = announcement.Id.ToString()
    },
    Apns = new ApnsConfig
    {
        Aps = new Aps { Sound = "default", Badge = 1 }
    },
    Android = new AndroidConfig
    {
        Priority = Priority.High,
        Notification = new AndroidNotification { Sound = "default", ChannelId = "avisos" }
    }
};

var messageId = await FirebaseMessaging.DefaultInstance.SendAsync(message);
logger.LogInformation("Push enviado: {MessageId} tópico {Topic}", messageId, message.Topic);
```

Valores aceitos em `data.screen` pelo app iOS: `avisos` (padrão), `ventures`, `certificates`, `campaigns`,
`financial`. Contrato completo em `docs/contrato-api-pendente.md`, seção 9.

Tópicos que o app iOS assina hoje: `announcements` (todos os aparelhos) e `user_{id}` (depois do login, onde
`id` é o id do usuário do cliente, por exemplo `user_212`). Avisos por empreendimento: enquanto não houver
tópico por empreendimento, enviar para `user_{id}` de cada cliente do empreendimento, ou criar o tópico
`venture_{id}` e combinar com os apps para assinarem.

### 4.6 `DateTime` em UTC

Procurar no fluxo de avisos e de notificações todo `DateTime.Now` e datas vindas de formulário que vão para
colunas `timestamp with time zone`, e trocar por UTC:

```csharp
entity.CreatedAt = DateTime.UtcNow;
entity.SentAt    = DateTime.UtcNow;
// data vinda de formulário (Kind=Unspecified):
entity.PublishAt = DateTime.SpecifyKind(dto.PublishAt, DateTimeKind.Local).ToUniversalTime();
```

Se houver muitos pontos, a alternativa rápida e conhecida é habilitar o comportamento antigo do Npgsql no
startup, mas é um paliativo e deve ser registrado como dívida:

```csharp
AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);
```

Onde olhar primeiro: o `DbUpdateException` ocorreu quatro vezes no mesmo minuto da criação do aviso
(15:57:09, :17, :30, :52), o que indica um loop (um registro por empreendimento ou por cliente) falhando a cada
iteração.

### 4.7 Idempotência

O `DbUpdateConcurrencyException` às 15:57:20 indica atualização de um registro já modificado. Garantir que o
envio de um aviso só aconteça uma vez (flag `PushSentAt` preenchida dentro da mesma transação ou um job
dedicado), para que um duplo clique no admin não dispare dois pushes.

## 5. Plano de teste

1. Aplicar 4.1 a 4.6 primeiro em **`portal_dev`** (`/bin/portal_dev`, `portal_dev.service`).
2. Criar um aviso **restrito a um empreendimento de teste** ou a um cliente de teste (cliente 212 tem o app no
   iPad e no iPhone do TI). Não usar "todos os empreendimentos" durante o teste.
3. Conferir no log: `journalctl -u portal_dev -f | grep -i push` deve mostrar o `MessageId` devolvido pelo Firebase.
4. Conferir nos aparelhos: notificação na tela bloqueada; toque abre Avisos.
5. Conferir no Firebase: Messaging > Relatórios passa a contar os envios (com atraso de algumas horas).
6. Só então publicar em produção (4.3 no `portal.service`) e repetir o teste com um aviso segmentado.

## 6. Checklist de segurança

- [ ] JSON da conta de serviço fora do repositório git e fora de qualquer pasta pública; permissão 600, dono `dev`.
- [ ] Credencial do projeto **907146044474**; nunca do `-e81bb`.
- [ ] Nenhuma chave antiga ("Server Key" da API legada) em uso; se existir, remover.
- [ ] Logs de erro de push com nível `Error` e sem imprimir a credencial.
- [ ] Revisar o que foi colado em chats durante o diagnóstico: a saída de `ps` incluiu chaves do Supabase e uma
      chave privada de certificado local; se forem de produção, trocar.

## 7. Observações vistas de passagem

- O aviso "Mês das Crianças" de 05/10 aparece dez vezes na lista do admin, uma por empreendimento do Terra Santa.
  Se cada registro gerar um push, clientes com mais de um empreendimento recebem a mesma notificação várias
  vezes. Vale agrupar por cliente.
- Homologação (`api.portal.mundoplanalto.com.br`, porta 5083) está fora do ar; o app de teste aponta para
  produção por falta dela. Subir a homologação ajuda os testes seguintes (certificados, campanhas, cartão).
- Endpoints novos que o app espera estão em `docs/contrato-api-pendente.md`; `POST /devices` permitirá push
  direcionado por aparelho sem depender de tópico.

## 8. Contatos e artefatos

- App iOS: repositório `Mundo-Planalto/AplicativoMobileV2IOS`, pasta `docs/`.
- Roteiro de teste de push nos aparelhos: `docs/teste-aparelho-real.md`.
- TI (acesso ao Firebase e aos aparelhos de teste): `timundoplanalto@gmail.com`.
