# Política de Privacidade do aplicativo Mundo Planalto (RASCUNHO para revisão do jurídico)

> Rascunho preparado pelo time do app em 08/10/2026 para o jurídico revisar, completar os dados da empresa e publicar
> em uma URL pública (ex.: `https://portal.mundoplanalto.com.br/privacidade`). O texto descreve o que o app faz hoje;
> itens entre colchetes precisam ser preenchidos ou confirmados. A mesma URL vai no App Store Connect e no Google Play.

**Última atualização:** [dd/mm/aaaa]

## 1. Quem somos

Este aplicativo é oferecido por **[Razão social da Mundo Planalto]**, CNPJ **[00.000.000/0001-00]**, com sede em
**[endereço]**, Goiânia/GO ("Mundo Planalto", "nós"). Dúvidas sobre esta política e pedidos relacionados aos seus dados
podem ser enviados ao Encarregado de Dados (DPO) pelo e-mail **[privacidade@mundoplanalto.com.br]**.

## 2. A quem se destina o aplicativo

O aplicativo é de uso exclusivo de clientes da Mundo Planalto com contrato ativo. Não há cadastro aberto ao público: o
"Primeiro acesso" apenas cria a senha de um cliente já existente, identificado pelo CPF/CNPJ do contrato.

## 3. Quais dados tratamos e para quê

| Dados | Origem | Finalidade | Base legal (LGPD) |
|---|---|---|---|
| CPF/CNPJ e senha de acesso | Informados por você no login | Autenticar o cliente. A senha nunca é armazenada no aparelho; usamos um token de sessão guardado em área protegida do sistema | Execução de contrato (art. 7º, V) |
| Nome, e-mail, telefone e endereço | Cadastro do contrato | Exibir seu perfil, permitir pedidos de alteração cadastral e contato da Central de Contratos | Execução de contrato |
| Dados financeiros do contrato (parcelas, boletos, saldo, informe de rendimentos) | Sistemas da Mundo Planalto | Exibir seu extrato, gerar segunda via de boleto e informe | Execução de contrato; obrigação legal (art. 7º, II) para o informe |
| Dados do empreendimento (fotos, vídeos, atualizações de obra) | Mundo Planalto | Acompanhamento do seu investimento | Execução de contrato |
| Identificador de notificações (token de push) | Gerado pelo aparelho/Firebase | Enviar avisos sobre seu contrato, obra e campanhas, conforme suas preferências | Legítimo interesse (art. 7º, IX); campanhas dependem do seu consentimento nas Preferências |
| Dados de uso do aplicativo (telas acessadas, eventos, falhas), identificador de instalação | Firebase (Google) | Medir uso, corrigir erros e melhorar o aplicativo | Legítimo interesse |
| Perfil de viagem (cidade, destinos preferidos, próxima viagem) **[quando a função for ativada]** | Informado por você | Personalizar campanhas e ofertas do clube | Consentimento (art. 7º, I) |
| Certificados de viagem, cupons de parceiros e cartão do membro **[quando ativados]** | Mundo Planalto e parceiros | Entregar os benefícios do clube | Execução de contrato |

Não coletamos localização, contatos, fotos, microfone ou câmera. **[Confirmar: não há uso de câmera no app atual.]**
Não vendemos dados pessoais e não usamos seus dados para publicidade de terceiros.

## 4. Com quem compartilhamos

- **Google Firebase** (Google LLC): envio de notificações e estatísticas de uso. Os dados podem ser processados fora do
  Brasil, com as salvaguardas contratuais do Google. Política: https://firebase.google.com/support/privacy
- **Apple** e **Google Play**: distribuição do aplicativo e, se você permitir, notificações.
- **Parceiros de benefícios** **[quando ativados]**: apenas a validação do seu cartão do membro (ativo ou inativo e número
  de usos), nunca seus dados financeiros.
- **Prestadores de serviço da Mundo Planalto** (hospedagem, sistemas de gestão) sob contrato de confidencialidade.
- Autoridades, quando exigido por lei.

## 5. Por quanto tempo guardamos

- Dados de sessão no aparelho: até você sair da conta ou excluir o aplicativo.
- Dados de uso (Firebase): **[14 meses, padrão do Google Analytics; confirmar]**.
- Dados do contrato e financeiros: pelo prazo do contrato e pelos prazos legais (civil, fiscal e consumerista), mesmo
  após a exclusão da conta no aplicativo.

## 6. Seus direitos

Você pode, a qualquer momento: confirmar a existência de tratamento, acessar, corrigir, pedir anonimização ou
eliminação dos dados desnecessários, pedir portabilidade, revogar consentimentos e obter informações sobre
compartilhamentos. No aplicativo: **Perfil > Preferências** (comunicações), **Perfil > Dados pessoais > Solicitar
alteração** e **Perfil > Segurança > Excluir conta**. Pelo canal do DPO para os demais pedidos. Respondemos em até
**15 dias** **[confirmar prazo interno]**.

## 7. Exclusão da conta

Em **Perfil > Segurança > Excluir conta** você pede o encerramento do seu acesso. A Central de Contratos confirma o
pedido, desativa o login no aplicativo e no Portal do Cliente e apaga os dados de uso do aplicativo. Os dados do
contrato e do financeiro são mantidos pelos prazos legais da seção 5.

## 8. Segurança

Comunicação criptografada (HTTPS), token de sessão guardado no Keychain do iOS / Keystore do Android, senha nunca
armazenada no aparelho, acesso aos sistemas restrito por perfil. Nenhum sistema é totalmente seguro; se identificarmos
incidente que afete seus dados, comunicaremos você e a ANPD conforme a lei.

## 9. Crianças e adolescentes

O aplicativo destina-se a titulares de contrato, maiores de 18 anos. Não tratamos intencionalmente dados de menores.

## 10. Alterações desta política

Avisaremos no aplicativo quando houver mudança relevante. A data da última atualização está no topo.

## 11. Contato

Encarregado de Dados (DPO): **[nome]**, **[e-mail]**, **[telefone]**. Mundo Planalto, **[endereço completo]**.

---

### Notas para o jurídico (não publicar)

- Termos de uso: pode-se usar o EULA padrão da Apple para iOS; para Android é preciso um texto próprio ou um termo
  único para os dois. Se houver termo único, publicar em `.../termos` e informar as duas URLs ao time do app.
- O app declara à Apple, no manifesto de privacidade, exatamente as categorias da seção 3 (nome, e-mail, telefone,
  endereço, ID do usuário, ID do dispositivo, outras informações financeiras, interação com o produto, dados de
  diagnóstico), todas vinculadas ao usuário e sem rastreamento. Qualquer mudança aqui precisa refletir lá.
- Quando certificados, cupons, cartão e perfil de viagem forem ativados no app, confirmar as linhas marcadas.
