//
//  HrRows.swift
//  Hard Rock Hotel & Vacation Club
//
//  HrIconBox, HrListRow, HrStatPill, HrShortcut.
//

import SwiftUI

/// Caixa de ícone 38x38, raio 10, fundo hrGold 12%, borda hrGoldBorder, ícone hrGoldLight a 50% do tamanho.
struct HrIconBox: View {
    let icon: String
    var size: CGFloat = HrMetrics.iconBoxSize
    var color: Color = .hrGoldLight

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.5, weight: .semibold))
            .foregroundColor(color)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: HrMetrics.iconBoxRadius, style: .continuous)
                    .fill(Color.hrGold.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: HrMetrics.iconBoxRadius, style: .continuous)
                    .stroke(Color.hrGoldBorder, lineWidth: 1)
            )
    }
}

/// Linha de lista com HrIconBox, título 14 semibold, subtítulo 11 muted e chevron dourado (ou trailing custom).
struct HrListRow<Trailing: View>: View {
    let icon: String
    let titulo: String
    var subtitulo: String? = nil
    var iconColor: Color = .hrGoldLight
    var titleColor: Color = .white
    var onTap: (() -> Void)? = nil
    @ViewBuilder var trailing: () -> Trailing

    init(
        icon: String,
        titulo: String,
        subtitulo: String? = nil,
        iconColor: Color = .hrGoldLight,
        titleColor: Color = .white,
        onTap: (() -> Void)? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.icon = icon
        self.titulo = titulo
        self.subtitulo = subtitulo
        self.iconColor = iconColor
        self.titleColor = titleColor
        self.onTap = onTap
        self.trailing = trailing
    }

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) { row }
                    .buttonStyle(HrPressStyle())
            } else {
                row
            }
        }
    }

    private var row: some View {
        HStack(spacing: 12) {
            HrIconBox(icon: icon, color: iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(HrFont.itemTitle)
                    .foregroundColor(titleColor)
                    .multilineTextAlignment(.leading)
                if let subtitulo, !subtitulo.isEmpty {
                    Text(subtitulo)
                        .font(HrFont.captionSmall)
                        .foregroundColor(.hrTextMuted)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer(minLength: 8)
            trailing()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.hrSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.hrGoldBorder, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

extension HrListRow where Trailing == HrChevron {
    init(icon: String, titulo: String, subtitulo: String? = nil, iconColor: Color = .hrGoldLight, titleColor: Color = .white, onTap: (() -> Void)? = nil) {
        self.init(icon: icon, titulo: titulo, subtitulo: subtitulo, iconColor: iconColor, titleColor: titleColor, onTap: onTap) { HrChevron() }
    }
}

/// Chevron dourado padrão das linhas.
struct HrChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.hrGold)
    }
}

/// Estatística pequena: valor dourado 14 bold, rótulo 10 muted.
struct HrStatPill: View {
    var icon: String? = nil
    let valor: String
    let rotulo: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.hrGoldLight)
                }
                Text(valor)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.hrGold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(rotulo)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.hrTextMuted)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.hrSurfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.hrGoldBorder, lineWidth: 1)
        )
    }
}

/// Atalho de grade 2 colunas: ícone, título 14 semibold, subtítulo 11 muted.
struct HrShortcut: View {
    let icon: String
    let titulo: String
    let subtitulo: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HrIconBox(icon: icon)
                VStack(alignment: .leading, spacing: 2) {
                    Text(titulo)
                        .font(HrFont.itemTitle)
                        .foregroundColor(.white)
                    Text(subtitulo)
                        .font(HrFont.captionSmall)
                        .foregroundColor(.hrTextMuted)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous)
                    .fill(Color.hrSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous)
                    .stroke(Color.hrGoldBorder, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous))
        }
        .buttonStyle(HrPressStyle())
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            HrListRow(icon: "doc.text.fill", titulo: "Segunda via de boleto", subtitulo: "Emita a segunda via da sua parcela") {}
            HrListRow(icon: "rectangle.portrait.and.arrow.right", titulo: "Sair", subtitulo: "Encerrar a sessão neste dispositivo", iconColor: .hrError, titleColor: .hrError) {}
            HStack(spacing: 8) {
                HrStatPill(icon: "creditcard", valor: "R$ 172.480,00", rotulo: "Saldo do contrato")
                HrStatPill(icon: "checkmark.circle", valor: "28 de 48", rotulo: "Parcelas pagas")
                HrStatPill(icon: "calendar", valor: "20 de 48", rotulo: "Parcelas restantes")
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                HrShortcut(icon: "airplane", titulo: "Viagens", subtitulo: "Experiências exclusivas") {}
                HrShortcut(icon: "tag.fill", titulo: "Descontos", subtitulo: "Em parceiros selecionados") {}
            }
        }
        .padding(HrMetrics.screenMargin)
    }
    .hrScreen()
}
