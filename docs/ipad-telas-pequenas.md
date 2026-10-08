# iPad e telas pequenas: verificação e recomendação

Verificado em 05/10/2026 no simulador: iPhone SE 3ª geração (375 x 667 pt), iPhone 16e (390 pt),
iPhone 17 (393 pt) e iPad A16 (820 x 1180 pt), na sessão de demonstração.

## Tela de 375 pt (iPhone SE): não quebra

Conferi Login, Início, Benefícios, Campanhas, Empreendimentos, página do empreendimento, Perfil, Cartão,
Financeiro, Extrato, Viagens, Perfil de viagem e Alteração de dados. O logo do Login cabe em uma linha.

Pontos apertados, nenhum bloqueante:

| Tela | O que acontece em 375 pt |
|---|---|
| Barra de abas | "Empreendimentos" fica em letra bem pequena (cabe, sem cortar) |
| Financeiro | No cartão "Saldo do contrato" o valor `R$ 172.480,00` encolhe muito; em "Próximas parcelas" a data aparece cortada ("15 OUT 20...") |
| Extrato | O botão "Filtros" passa da borda e só aparece rolando a linha de filtros para o lado |
| Campanhas | O quarto filtro aparece cortado na borda (a linha rola, é o comportamento esperado) |

Ajuste sugerido para o Build 2: data curta ("15/10") nas próximas parcelas e valor do saldo em duas linhas.
Custo: cerca de 2 horas.

## iPad: funciona, mas é o layout de telefone esticado

O app abre e todas as telas funcionam. Problemas visíveis:

- Tudo ocupa a largura inteira: o cartão do membro fica com mais de 800 pt de largura e quase vazio, as
  fotos dos destaques cortam muito, os botões ficam com a largura da tela.
- Sobra uma faixa vazia no topo das cinco abas principais.
- No iPadOS 26 o app pode abrir em janela, e os controles da janela ficam por cima do canto superior
  esquerdo (da faixa de demonstração e do botão voltar).
- Não testei em paisagem; o projeto declara suporte a paisagem em iPhone e iPad, e o layout foi desenhado
  só para retrato.

## As opções

| Opção | O que é | Custo | Risco |
|---|---|---|---|
| A. iPhone apenas até a V2 | Tirar o iPad da lista de aparelhos do projeto | 10 minutos no projeto | **Pode não ser permitido.** A Apple não deixa remover o suporte a iPad de um app que já foi publicado com ele, e este projeto sempre foi configurado como iPhone + iPad. Precisa conferir no App Store Connect se alguma versão do `com.portal.MundoPlanalto` já foi aprovada. Além disso, app só de iPhone continua rodando no iPad em modo ampliado, e o revisor da Apple pode testar assim |
| B. Coluna central no iPad | Manter iPhone + iPad, mas limitar o conteúdo a uma coluna de uns 600 pt centralizada, com fundo preto nas laterais, e travar retrato no iPhone | 1 dia, mais meio dia de conferência tela a tela | Baixo. Visual de "app de telefone no meio da tela", mas correto e sem nada esticado |
| C. Layout próprio de iPad | Duas colunas, barra lateral no lugar das abas, grades de 3 ou 4 cartões | 1 a 2 semanas, mais desenho | Não cabe até o congelamento de 15/11 sem tirar tempo da camada de API |

## Decisão (08/10)

O TI decidiu **não investir mais no layout de iPad agora**: o app continua universal, com o layout de telefone esticado no iPad, até a V2. Consequências que permanecem: capturas de iPad 13" obrigatórias na loja e teste rápido de que nada quebra no iPad antes de cada envio.

## Recomendação original (para a V2)

**Opção B agora, opção C na V2.** Ela resolve o que o revisor e a diretoria veriam (conteúdo esticado),
não depende de saber se a Apple deixa remover o iPad e custa um dia e meio. Junto com ela:

1. Travar a orientação em retrato no iPhone (o layout não foi pensado para paisagem).
2. Tirar Mac e Vision Pro das plataformas do projeto (hoje estão marcados e o app apareceria para esses aparelhos).

Se a decisão for a opção A mesmo assim, o primeiro passo é conferir no App Store Connect o histórico de
versões do app; se já houve versão publicada com iPad, a opção A não existe.

Mantendo o iPad (opções B ou C), a loja exige também capturas de tela de iPad de 13 polegadas.
