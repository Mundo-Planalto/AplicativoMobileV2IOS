# Implantação da correção de push do portal (branch `Ambiente-Orion`, commit `8164a7f`)

Roteiro de infraestrutura para levar a correção do repositório `Mundo-Planalto/MundoPlanaltoPortal` até o
servidor `srv-zapzap` (177.136.206.246) e validar nos aparelhos. Escrito em 07/10/2026 depois de ler o commit
`8164a7f` e a configuração atual do servidor. Complementa `docs/backend-push-correcao.md`.

## 0. O que o commit `8164a7f` muda (conferido no código)

| Arquivo | Mudança | Avaliação |
|---|---|---|
| `Services/FirebaseService.cs` | Lê a credencial de `GOOGLE_APPLICATION_CREDENTIALS` ou `Firebase:CredentialsPath`; `ProjectId = "mundo-planalto-portal"`; falha vira `LogCritical`; `data.screen` nas mensagens | Correto. **Antes, o código procurava o arquivo `mundo-planalto-portal-e81bb-firebase-adminsdk-….json` na pasta do app**, ou seja, estava apontado para o projeto errado (23373676291) e o arquivo nem existia no servidor. Isso explica o silêncio total no log. |
| `Pages/Admin/Announcements/Create.cshtml.cs` | Reserva atômica de `NotificationSent` com `ExecuteUpdateAsync` (evita duplo envio); libera a reserva se o envio falhar | Correto; resolve o `DbUpdateConcurrencyException` |
| `Data/ApplicationDbContext.cs` | Conversor global de `DateTime` para UTC (`ConfigureConventions`) | Correto; resolve o `Cannot write DateTime with Kind=Unspecified` |

**Atenção, antes de testar:** o método `SendNewAnnouncementNotificationAsync` envia **sempre para o tópico
`announcements`**, com fallback para `news` e `all`. O filtro de empreendimento do formulário vale só para a
lista de avisos; **o push vai para todos os aparelhos**, inclusive se o aviso for criado no ambiente de
desenvolvimento, porque o tópico é do projeto Firebase, que é único. Por isso o item 5 propõe um tópico de
teste configurável.

## 1. Pré-requisitos já confirmados no servidor

- .NET SDK **10.0.112** e 8.0.131 instalados em `/usr/lib/dotnet` (o projeto é `net10.0`).
- Produção: `portal.service`, usuário `dev`, `WorkingDirectory=/opt/portal/app`, porta 5082, publicação
  dependente de framework (executável `MundoPlanaltoPortal` + DLLs).
- Desenvolvimento: processo `/bin/portal_dev/MundoPlanaltoPortal`, unidade transitória `portal_dev`
  (sem arquivo `.service`), porta 5083 (é o que `api.portal.mundoplanalto.com.br` tenta alcançar).
- `appsettings.json` **não está no repositório** (ignorado); o de produção fica em `/opt/portal/app` e deve
  ser preservado em cada publicação.
- Os scripts `project/*.nu` do repositório descrevem a convenção (`deploy_dir: /opt/portal/app/`), mas a
  função de deploy está vazia; a publicação é manual.

## 2. Credencial do Firebase: FEITO em 07/10 às 17:51

Chave gerada no projeto 907146044474 (conta `firebase-adminsdk-fbsvc@mundo-planalto-portal.iam.gserviceaccount.com`)
e instalada em **`/home/dev/.config/portal/firebase-sa.json`** (dono `dev`, permissão 600, pasta 700). O serviço
roda como `dev`, então lê o arquivo sem `root`. A cópia baixada no Mac do TI foi apagada. Se preferirem o caminho
`/etc/portal`, basta mover como `root` e ajustar a variável; o conteúdo abaixo fica como referência.

### 2.1 Como foi feito (referência)

1. Firebase Console > projeto **Mundo Planalto Portal, número 907146044474** (conferir o número; existe um
   homônimo `-e81bb`).
2. Configurações do projeto > **Contas de serviço** > **Gerar nova chave privada**. Salva um `.json`.
3. Do computador onde baixou, enviar ao servidor (exemplo a partir do Mac do TI, que já tem chave para o `dev`):

```bash
scp -i ~/.ssh/planalto_portal ~/Downloads/mundo-planalto-portal-firebase-adminsdk-*.json dev@177.136.206.246:/tmp/firebase-sa.json
```

4. No servidor, como `root`:

```bash
mkdir -p /etc/portal && mv /tmp/firebase-sa.json /home/dev/.config/portal/firebase-sa.json && chown dev:dev /home/dev/.config/portal/firebase-sa.json && chmod 600 /home/dev/.config/portal/firebase-sa.json && grep -oE '"(project_id|client_email)": *"[^"]+"' /home/dev/.config/portal/firebase-sa.json
```

Precisa mostrar `"project_id": "mundo-planalto-portal"` (sem `-e81bb`). Depois apagar a cópia do computador
de origem; o arquivo não deve ficar em Downloads nem entrar em repositório.

## 3. Publicar o build (no servidor, como `dev`)

```bash
sudo -iu dev
mkdir -p ~/src && cd ~/src
git clone --branch Ambiente-Orion https://github.com/Mundo-Planalto/MundoPlanaltoPortal.git portal-orion 2>/dev/null || (cd portal-orion && git fetch && git checkout Ambiente-Orion && git pull)
cd ~/src/portal-orion
git log --oneline -1          # deve mostrar 8164a7f
dotnet publish MundoPlanaltoPortal/MundoPlanaltoPortal.csproj -c Release -o /tmp/portal-publish
```

Se o `git clone` pedir usuário e senha (repositório privado), usar um token de acesso pessoal com permissão
`repo` no lugar da senha, ou uma deploy key do servidor cadastrada no repositório.

Conferir a saída: `/tmp/portal-publish/MundoPlanaltoPortal` deve existir e **não** deve haver `appsettings*.json`
com dados de produção dentro dela (o repositório não os tem; se houver, vêm da sua cópia local).

## 4. Desenvolvimento primeiro (`portal_dev`, porta 5083)

```bash
# como root
systemctl stop portal_dev 2>/dev/null; pkill -f /bin/portal_dev/MundoPlanaltoPortal
cp -a /bin/portal_dev /bin/portal_dev.bak-$(date +%Y%m%d-%H%M)
rsync -a --exclude 'appsettings*.json' /tmp/portal-publish/ /bin/portal_dev/
chown -R dev:dev /bin/portal_dev
systemd-run --unit=portal_dev --uid=dev --gid=dev \
  -p WorkingDirectory=/bin/portal_dev \
  -E ASPNETCORE_URLS=http://0.0.0.0:5083 \
  -E ASPNETCORE_ENVIRONMENT=Development \
  -E GOOGLE_APPLICATION_CREDENTIALS=/home/dev/.config/portal/firebase-sa.json \
  /bin/portal_dev/MundoPlanaltoPortal
journalctl -u portal_dev -n 40 --no-pager | grep -iE "firebase|credencia|project|Now listening"
```

Esperado no log: `Arquivo de credenciais: Encontrado ✅ (/home/dev/.config/portal/firebase-sa.json)` e
`Firebase Admin SDK inicializado (projeto mundo-planalto-portal)`. Se aparecer `LogCritical … Credencial do
Firebase não encontrada`, a variável não chegou ao processo.

Se o `portal_dev` normalmente sobe de outro jeito (script do desenvolvedor, VS Code), basta garantir que o
processo receba `GOOGLE_APPLICATION_CREDENTIALS`; o essencial é a variável no ambiente do processo.

## 5. Teste sem atingir os clientes

Como o envio vai para `announcements` (todos os aparelhos), há duas formas de testar o `portal_dev` sem
disparar para a base:

**Opção A (recomendada, 10 linhas no backend): tópico configurável.** Em `FirebaseService`, trocar a constante
por configuração, com o padrão atual:

```csharp
// antes
const string TOPIC_ANNOUNCEMENTS = "announcements";
// depois
var TOPIC_ANNOUNCEMENTS = _configuration["Firebase:AnnouncementsTopic"] ?? "announcements";
```

e, **só no `appsettings` do `portal_dev`** (ou via `-E Firebase__AnnouncementsTopic=user_212` no `systemd-run`),
apontar para `user_212`, que é o tópico do cliente de teste presente no iPad e no iPhone do TI. Produção
continua com `announcements`. Isso também prepara o terreno para o envio por empreendimento (`venture_{id}`)
previsto em `docs/contrato-api-pendente.md`.

**Opção B (sem mudar código):** aceitar que o teste em `portal_dev` dispare para todos e usar um texto que a
empresa queira comunicar de verdade. Precisa de ok da diretoria.

Roteiro do teste (opção A):

1. iPad e iPhone do TI desbloqueados e com o app aberto (ou bloqueados, para validar a tela bloqueada).
2. No admin do ambiente de desenvolvimento, criar um aviso "Teste push dev" para qualquer empreendimento.
3. No servidor: `journalctl -u portal_dev -f | grep -iE "firebase|push|tópico|SUCESSO|Erro"` deve mostrar
   `✅ SUCESSO! Notificação enviada para o tópico 'user_212'` e o `MessageId`.
4. Nos aparelhos: notificação chega; toque abre Avisos.
5. Firebase Console > Messaging > Relatórios: o envio aparece em algumas horas.

## 6. Produção (`portal.service`)

Só depois do item 5 passar.

```bash
# como root
systemctl edit portal
```

Conteúdo do override (salvar e fechar):

```ini
[Service]
Environment=GOOGLE_APPLICATION_CREDENTIALS=/home/dev/.config/portal/firebase-sa.json
```

```bash
systemctl stop portal
cp -a /opt/portal/app /opt/portal/app.bak-$(date +%Y%m%d-%H%M)
rsync -a --exclude 'appsettings*.json' /tmp/portal-publish/ /opt/portal/app/
chown -R dev:dev /opt/portal/app
systemctl daemon-reload && systemctl start portal
systemctl show portal -p Environment
journalctl -u portal -n 40 --no-pager | grep -iE "firebase|credencia|project|Now listening"
curl -s -o /dev/null -w "%{http_code}\n" https://portal.mundoplanalto.com.br/
```

Esperado: `Environment=ASPNETCORE_URLS=… GOOGLE_APPLICATION_CREDENTIALS=/home/dev/.config/portal/firebase-sa.json`,
log com `Firebase Admin SDK inicializado (projeto mundo-planalto-portal)` e o portal respondendo `200`.

Reversão, se algo der errado: `systemctl stop portal && rsync -a --delete /opt/portal/app.bak-…/ /opt/portal/app/ && systemctl start portal`.

## 7. Primeiro envio real

Com produção no ar, o primeiro aviso publicado pelo admin vai para **todos** os clientes. Combinar com a
diretoria um texto útil (não "teste") e publicar uma única vez. Acompanhar com
`journalctl -u portal -f | grep -iE "firebase|SUCESSO|Erro"` e confirmar nos aparelhos do TI.

## 8. Depois

- Fazer o merge de `Ambiente-Orion` na branch de produção do repositório, para o próximo deploy não perder a correção.
- Registrar em `docs/contrato-api-pendente.md` o tópico por empreendimento quando for implementado.
- Remover a chave SSH temporária do Mac do TI do `authorized_keys` do `dev` (`claude-ti-mac-planalto-portal`).
