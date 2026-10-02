# Marca Mundo Planalto no app (brandbook Set/2026)

O Marketing entregou a **versão em ícone** da nova marca Mundo Planalto (brandbook, página "Assinatura da marca → Versão em ícone"). É ela que substitui a estrela dourada e o wordmark "HARD ROCK" em todo o app. A logo horizontal completa ainda não chegou; quando chegar, só o componente `MundoPlanaltoLogo` muda.

## O símbolo

- Arquivo-fonte: `docs/brand/simbolo-mundo-planalto.svg` (viewBox 1080x1080, dois caminhos: asterisco de 8 pontas e um ponto no quadrante superior direito).
- Cor oficial: **`#9E8033`** (dourado do brandbook). É a única cor do símbolo; nunca aplicar gradiente, sombra, contorno ou outra cor. Sobre fundo escuro, usar `#9E8033`; sobre fundo claro, também `#9E8033` (o brandbook mostra o ícone sobre creme `#F2F1EA`).
- Uso: ícones digitais, favicon, avatar, splash, cabeçalho, cartão do membro, marca d'água. Não deformar, não rotacionar, não recortar.
- **Área de proteção = X = diâmetro do ponto** em todos os lados, em qualquer tamanho. No SVG o ponto tem diâmetro 244,88 de 1080, ou seja, **margem mínima de 22,7% da largura do símbolo** em cada lado. Regra prática: num quadrado de lado L, o símbolo ocupa no máximo 0,69 L centralizado.

## Assets (gravar em `docs/brand/` a partir dos blocos da seção "Arquivos para gravar" no fim deste documento)

| Arquivo | Para quê |
|---|---|
| `simbolo-mundo-planalto.svg` | Fonte vetorial. iOS: importar no `Assets.xcassets` como `MundoPlanaltoSymbol` (Preserve Vector Data, Render As: Template para poder tingir) |
| `simbolo-1080.png` | Fallback raster do símbolo |
| `ic_launcher_foreground.xml` | Android: foreground do adaptive icon (símbolo dentro da zona segura de 66dp) |
| `app-icon-1024-escuro.png` / `.svg` | Ícone 1024x1024: símbolo `#9E8033` sobre `#0A0A0A`, área de proteção respeitada (**padrão do app, tema escuro**) |
| `app-icon-1024-claro.png` / `.svg` | Alternativa: símbolo sobre creme `#F2F1EA`, como no mockup do brandbook. Rodrigo decide qual vai para as lojas |

## Ícone do app

- **iOS**: `AppIcon` 1024x1024 a partir de `app-icon-1024-escuro.png` (ou claro, se decidido). Sem transparência, sem cantos arredondados (o iOS aplica).
- **Android**: adaptive icon com `ic_launcher_foreground.xml` e `ic_launcher_background` = `#0A0A0A` (ou `#F2F1EA` na variante clara). Gerar também o ícone legado 512x512 para a Play Console a partir do PNG. Ícone monocromático (Android 13+): o mesmo vetor em `#FFFFFF`.
- Nome exibido sob o ícone: **Mundo Planalto**.

## Componentes de marca

| Componente | Conteúdo | Onde |
|---|---|---|
| `MundoPlanaltoSymbol(size, color = hrGold)` | O símbolo vetorial, tingível | Splash, header (no lugar da estrela), cartão, placeholders de imagem, marca d'água |
| `MundoPlanaltoLogo(compact: Bool)` | Símbolo à esquerda + wordmark em texto "MUNDO PLANALTO" (Inter/SF black, spacing 3) e, abaixo, "VACATION CLUB" (12 semibold, spacing 2, `hrGoldLight`). Compacto: símbolo 24pt + "MUNDO PLANALTO" 14 bold. Quando a logo horizontal oficial chegar, o componente passa a mostrar a imagem sem mudar os chamadores | Splash, Login, cartão (compact) |
| `HrWordmark` ("HARD ROCK / HOTEL & VACATION CLUB") | **Deixa de ser usado.** Apagar as chamadas; pode ficar no código só para conteúdo específico do empreendimento Hard Rock, se algum dia precisar | — |

Regras no app:
- Header de cada aba: `MundoPlanaltoSymbol(18)` dourado antes de "Olá, {nome}" (hoje é `star.fill` / `Icons.Star`).
- Splash: `MundoPlanaltoLogo` centralizado, animação de opacidade 0.5↔1, linha dourada de 60pt abaixo. Fundo `hrBlack`. O símbolo respeita a área de proteção em relação às bordas e ao texto.
- Login: `MundoPlanaltoLogo` no topo; o resto conforme `docs/telas.md`.
- Cartão do membro: `MundoPlanaltoLogo(compact)` no canto superior esquerdo; marca d'água opcional `MundoPlanaltoSymbol(140, color = hrGold.opacity(0.12))` à direita (substitui o `music.note`).
- Placeholder de imagens remotas: gradiente escuro + `MundoPlanaltoSymbol` a 20% no centro.
- Tab bar e demais ícones continuam SF Symbols / Material Icons; o símbolo não substitui ícones de função.

## Paleta atualizada (substitui a tabela de cores de `design-system.md`)

O CEO reclamou do dourado anterior (`#D4AF37`, "cor de burro fugido", com sombra). O dourado oficial do brandbook é mais fechado; a paleta passa a ser:

| Nome | Hex | Uso |
|---|---|---|
| `hrBlack` | `#0A0A0A` | Fundo de todas as telas e da tab bar |
| `hrSurface` | `#161616` | Cards |
| `hrSurfaceElevated` | `#1F1F1F` | Cards em destaque, campos, chips não selecionados |
| `hrGold` | **`#9E8033`** | Símbolo, botões principais, ícones ativos, bordas fortes (era `#D4AF37`) |
| `hrGoldLight` | **`#C9A84C`** | Links, texto dourado sobre fundo escuro, chips selecionados em texto (era `#F3D77A`) |
| `hrGoldDark` | **`#6E5A22`** | Fim de gradientes sutis, linhas (era `#9C7C1E`) |
| `hrGoldBorder` | `#9E8033` a 40% | Borda padrão dos cards |
| `hrCream` | `#F2F1EA` | Só para a variante clara do ícone e materiais impressos; não usar em telas |
| `hrTextMuted` | `#A6A6A6` | Texto secundário |
| `hrSuccess` / `hrWarning` / `hrError` | `#7CCB6A` / `#E0A72E` / `#E05252` | Status |
| Texto principal | `#FFFFFF` | |

- `HrGoldButton`: fundo `hrGold` sólido, texto preto bold 14. Sem `hrGoldGradient`, sem sombra.
- `hrGoldGradient` (`hrGoldLight → hrGold → hrGoldDark`) fica só para a linha do splash e o brilho diagonal do cartão.
- Contraste: `#9E8033` sobre `#0A0A0A` ≈ 5,5:1 e texto preto sobre `#9E8033` ≈ 5,5:1, ambos acima de 4,5:1 (WCAG AA). `hrGoldLight` sobre `hrBlack` ≈ 8,5:1 para texto pequeno.
- Os nomes `hr*` permanecem para não quebrar código; só os valores mudam.

## Nomes dos componentes que mudam

| Antes | Depois |
|---|---|
| `HrWordmark` | `MundoPlanaltoLogo` |
| `star.fill` / `Icons.Star` no header | `MundoPlanaltoSymbol` |
| Estrela `ic_hr_foreground.xml` | `ic_launcher_foreground.xml` com o símbolo |
| `music.note` no cartão | `MundoPlanaltoSymbol` como marca d'água |
