# Paridade iOS ↔ Android (para o agente do Android, `Mundo-Planalto/AplicativoMobileV2`)

Decisões e mudanças feitas no iOS entre 05/10 e 08/10 que o Android precisa espelhar. Fonte dos textos: `docs/telas.md`.

| Item | O que o iOS faz | Android |
|---|---|---|
| Faixa de demonstração | Faixa fixa "DEMONSTRAÇÃO • dados de exemplo" em todas as telas da sessão demo; demo só em build de debug | Igual |
| Ações sem backend | "Disponível em breve" (botão desabilitado + aviso) em ativar certificado, usar código, interesse em campanha (`online`/`postsales`), salvar perfil de viagem, cupom e exclusão de conta; mocks não devolvem sucesso inventado | Igual |
| Aviso de conteúdo de exemplo | No login real, Viagens, Benefícios, Campanhas e Cartão mostram "Conteúdo de exemplo: esta tela ainda não recebe os seus dados do servidor" | Igual |
| Chaves de recurso | `Features.viagens/beneficios/campanhas/cartao/perfilViagem` tiram a área do build de loja | Criar equivalente (BuildConfig) |
| Indique um amigo | CTA tipo `link` abrindo `https://hrh.vacation.mundoplanalto.com.br/` no navegador interno | Igual |
| Push | Tópicos `announcements` e `user_{id}` (assina após login, cancela no logout); toque abre tela pela chave `data.screen` (`avisos` padrão, `ventures`, `certificates`, `campaigns`, `financial`), inclusive com app fechado | Conferir assinatura dos dois tópicos e o roteamento por `screen` |
| Projeto Firebase | `mundo-planalto-portal` (nº 907146044474). O `-e81bb` não é usado | Conferir o `google-services.json` do Android: tem que ser do 907146044474 |
| Exclusão de conta | Perfil > Segurança > Excluir conta; `POST customers/me/deletion-request`; encerra sessão ao receber protocolo | Obrigatório também no Google Play (política de exclusão de conta) |
| Política e termos | URLs em config; sem URL, tela "Texto oficial em breve" | Igual; Play exige a URL da política na ficha |
| Analytics | Firebase Analytics mantido e declarado nos rótulos de privacidade | Declarar na seção "Segurança dos dados" do Play |
| Versão | 2.0.0 (1) | Alinhar `versionName` 2.0.0 |
| iPad | Fica como está (layout de telefone) | n/a |
| Sessão | Fixa; só sai em "Sair" ou 401 confirmado duas vezes | Igual |
