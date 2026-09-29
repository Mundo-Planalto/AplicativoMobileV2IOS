# Design system Hard Rock Hotel & Vacation Club (iOS)

Visual preto e dourado, sempre em tema escuro (não há tema claro). Implementação de referência no Android: `ui/hardrock/HardRockDesign.kt` e `ui/theme/Color.kt` do repositório `Mundo-Planalto/AplicativoMobileV2`.

## Cores (`Color` extension `Hr`)

| Nome | Hex | Uso |
|---|---|---|
| `hrBlack` | `#0A0A0A` | Fundo de todas as telas e da tab bar |
| `hrSurface` | `#161616` | Cards |
| `hrSurfaceElevated` | `#1F1F1F` | Cards em destaque, campos de texto, chips não selecionados |
| `hrGold` | `#D4AF37` | Ações principais, ícones ativos, bordas fortes |
| `hrGoldLight` | `#F3D77A` | Destaques, links, texto sobre dourado escuro |
| `hrGoldDark` | `#9C7C1E` | Fim do gradiente dourado, sombras |
| `hrGoldBorder` | `#D4AF37` a 40% | Borda padrão dos cards |
| `hrTextMuted` | `#A6A6A6` | Texto secundário |
| `hrSuccess` | `#7CCB6A` | "Em dia", "Disponível", "Ativo" |
| `hrWarning` | `#E0A72E` | "Solicitado", "A vencer" |
| `hrError` | `#E05252` | Vencido, erro, "Sair" |
| Texto principal | `#FFFFFF` | |

Gradientes:
- `hrGoldGradient`: horizontal `hrGoldLight → hrGold → hrGoldDark` (botões principais).
- `hrCardGradient`: vertical `hrSurfaceElevated → hrSurface` (card em destaque).
- Fotos: por trás de toda `AsyncImage`, um `LinearGradient(hrSurfaceElevated, hrGoldDark, hrBlack)`; por cima da metade inferior, gradiente `clear → black 85%` para o texto ficar legível.

## Tipografia (SF Pro, sistema)

| Papel | Tamanho / peso |
|---|---|
| Título de tela (ex.: "Seus benefícios") | 30 bold |
| Título de card hero ("Gramado te espera") | 24 bold |
| Título de seção | 16 bold |
| Título de item de lista | 14 semibold |
| Corpo | 14 regular |
| Subtítulo / legenda | 11–12 regular, `hrTextMuted` |
| Tag | 9 bold, uppercase, letter spacing 1 |
| Valor monetário em destaque | 34 bold, dourado |
| Wordmark "HARD ROCK" | 34 black, letter spacing 3, `hrGold`; "HOTEL & VACATION CLUB" 12 semibold, spacing 2, `hrGoldLight`; versão compacta 22/9 |

## Formas e espaçamento

- Cards: raio 16, borda 1pt `hrGoldBorder` (ou `hrGold` quando em destaque), padding interno 16.
- Botão principal: altura 46, raio 12, `hrGoldGradient`, texto preto bold 14 + chevron.
- Botão secundário: altura 42, raio 12, borda 1pt `hrGold`, texto `hrGoldLight` semibold 13.
- Chips: raio 20, padding 14x7; selecionado = fundo `hrGold` e texto preto; não selecionado = fundo `hrSurfaceElevated`, borda `hrGoldBorder`, texto `hrGoldLight`.
- Caixa de ícone (`HrIconBox`): 38x38, raio 10, fundo `hrGold` 12%, borda `hrGoldBorder`, ícone `hrGoldLight` a 50% do tamanho.
- Margem lateral das telas: 20. Espaço entre cards: 12. Espaço final da rolagem: 24 + safe area da tab bar.
- Tab bar: fundo `hrBlack`, cantos superiores arredondados 24, item selecionado com ícone dourado sobre "pastilha" 40x40 raio 12 em `hrGold` 18%; não selecionado `hrTextMuted`. Rótulos de 9pt.

## Componentes (nomes a manter em SwiftUI)

| Componente | Conteúdo |
|---|---|
| `HrHeader(nome, titulo, subtitulo, onNotificacoes)` | Estrela dourada + "Olá, {primeiro nome}" + sino à direita; título 30 bold; subtítulo muted |
| `HrBackHeader(titulo, subtitulo, onBack)` | Seta `chevron.left` dourada + título 22 bold + subtítulo |
| `HrCard(highlighted:, onTap:)` | Container padrão |
| `HrGoldButton(text, trailingArrow: true)` | Botão principal |
| `HrOutlineButton(text)` | Botão secundário |
| `HrSectionTitle(titulo, subtitulo?, acao?, onAcao?)` | Título de seção com link "Ver todas" à direita em `hrGoldLight` |
| `HrTag(text, filled:, color:)` | Etiqueta uppercase |
| `HrChip(text, selected)` | Filtro |
| `HrListRow(icon, titulo, subtitulo, trailing?)` | Linha de lista com `HrIconBox` e chevron dourado |
| `HrStatPill(icon, valor, rotulo)` | Estatística pequena (valor dourado 14 bold, rótulo 10 muted) |
| `HrShortcut(icon, titulo, subtitulo)` | Atalho de grade 2 colunas |
| `HrStatusDot(text, color)` | Ponto 8pt + texto 12 semibold na mesma cor |
| `HrWordmark(compact:)` | Marca em texto |
| `CartaoDigitalCard(nome, nivel, numeroMembro, desde)` | Cartão 1.6:1, ver `docs/telas.md` |

Ícones: usar SF Symbols equivalentes aos Material Icons do Android (ex.: `Checkroom` → `tshirt.fill`, `Flight` → `airplane`, `LocalOffer` → `tag.fill`, `CardGiftcard` → `gift.fill`, `Apartment` → `building.2.fill`, `QrCode2` → `qrcode`, `Public` → `globe`, `MusicNote` → `music.note`, `Star` → `star.fill`, `Lock` → `lock.fill`, `CalendarMonth` → `calendar`, `Receipt` → `doc.text.fill`).
