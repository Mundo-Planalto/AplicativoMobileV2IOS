# Mensagem para o time do backend (08/10/2026)

Assunto: o que o app precisa do backend até 15/11 para a submissão às lojas em 18/11

Pessoal, o push já está fechado (correção implantada em 08/10, `portal_dev` enviou para `user_212` com sucesso). O que
falta do backend para a submissão está abaixo, em ordem de impacto. Contratos detalhados em
`docs/contrato-api-pendente.md` (repositório `Mundo-Planalto/AplicativoMobileV2IOS`) e no `docs/openapi-hardrock.yaml`.

## 1. Resposta que destrava decisões (até 12/10): quais destes endpoints ficam em produção até 15/11?

| Área do app | Endpoints | Se não vier até 15/11 |
|---|---|---|
| Viagens (certificados) | `GET members/me/certificates`, `POST certificates/{id}/request` | A área sai do build de loja |
| Benefícios (parceiros e cupons) | `GET partners`, `POST partners/{id}/coupon` | Aba sai do build de loja |
| Campanhas | `GET campaigns`, `POST campaigns/{id}/interest` | Aba sai do build de loja |
| Cartão do membro | `GET members/me/card`, `GET members/me/redemptions` | Cartão e QR saem do build |
| Perfil de viagem | `GET/PUT members/me/travel-profile` | Seção sai do Perfil |
| Preferências | `GET/PUT members/me/notification-preferences` | Ficam só no aparelho |
| Alteração de telefone/e-mail | `GET/POST customers/change-requests` | Só endereço (endpoint atual) |

Responda com data por linha; o app tem uma chave por área e ajusto o build de loja no mesmo dia.

## 2. Obrigatórios para a Apple aprovar (independem do item 1)

1. **`POST customers/me/deletion-request`** (exclusão de conta pelo app): tela já pronta no iOS; contrato na seção 10.
   Resposta `{ protocol, deadlineDays }`; depois, desativar login, invalidar JWT e remover token de push.
2. **Conta de cliente de teste em produção** para o revisor da Apple e do Google: CPF e senha de um cliente fictício
   com empreendimento (fotos e vídeos), financeiro com parcelas e boletos, e avisos. Precisa funcionar de 15/11 a 30/11.
3. **URLs públicas de Política de privacidade e Termos de uso** no portal (ex.: `/privacidade` e `/termos`). O
   rascunho da política está em `docs/politica-privacidade-rascunho.md`, aguardando o jurídico.

## 3. Sessão fixa

`Jwt:ExpirationDays` está em 7: o cliente volta ao Login a cada 7 dias. Subir para 180 (ou criar `POST auth/refresh`).

## 4. Push: próximos passos

- Primeiro aviso real em produção (vai para todos os clientes): combinar texto com a diretoria.
- Tópico por empreendimento (`venture_{id}`): hoje o filtro de empreendimento do aviso vale só para a lista; o push vai
  para todos. Quando existir, os apps assinam `venture_{id}` dos empreendimentos do cliente.
- Avisos duplicados por empreendimento ("Mês das Crianças" apareceu 10 vezes na lista): agrupar por cliente.
- `POST /devices` (token por aparelho) para envio direcionado sem depender de tópico.
- Chave `screen` no payload (`avisos`, `ventures`, `certificates`, `campaigns`, `financial`) já é lida pelo iOS.

## 5. Homologação

`api.portal.mundoplanalto.com.br` (porta 5083) agora responde pelo `portal_dev` novo. Confirmar o nginx e avisar; o app
de teste pode voltar a apontar para lá em vez de produção.
