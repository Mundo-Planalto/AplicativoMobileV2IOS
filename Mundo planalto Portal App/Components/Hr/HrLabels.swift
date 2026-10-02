//
//  HrLabels.swift
//  Hard Rock Hotel & Vacation Club
//
//  HrTag, HrChip, HrStatusDot, HrSectionTitle, HrWordmark.
//

import SwiftUI

/// Etiqueta uppercase: 9 bold, letter spacing 1.
struct HrTag: View {
    let text: String
    var filled: Bool = false
    var color: Color = .hrGold

    var body: some View {
        Text(text.uppercased())
            .font(HrFont.tag)
            .tracking(1)
            .foregroundColor(filled ? .black : color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                // Fundo escuro por baixo para a etiqueta continuar legível sobre fotos.
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(filled ? color : Color.black.opacity(0.55))
            )
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(filled ? Color.clear : color.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(filled ? Color.clear : color.opacity(0.6), lineWidth: 1)
            )
    }
}

/// Filtro: raio 20, padding 14x7; selecionado = fundo hrGold e texto preto.
struct HrChip: View {
    let text: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .fixedSize()
                .foregroundColor(selected ? .black : .hrGoldLight)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: HrMetrics.chipRadius, style: .continuous)
                        .fill(selected ? Color.hrGold : Color.hrSurfaceElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: HrMetrics.chipRadius, style: .continuous)
                        .stroke(selected ? Color.clear : Color.hrGoldBorder, lineWidth: 1)
                )
        }
        .buttonStyle(HrPressStyle())
    }
}

/// Linha de chips com rolagem horizontal.
struct HrChipRow: View {
    let options: [String]
    @Binding var selected: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    HrChip(text: option, selected: option == selected) {
                        selected = option
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
        }
        .padding(.horizontal, -HrMetrics.screenMargin)
    }
}

/// Ponto 8pt + texto 12 semibold na mesma cor.
struct HrStatusDot: View {
    let text: String
    var color: Color = .hrSuccess

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

/// Título de seção 16 bold com subtítulo opcional e link de ação à direita em hrGoldLight.
struct HrSectionTitle: View {
    let titulo: String
    var subtitulo: String? = nil
    var acao: String? = nil
    var onAcao: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(HrFont.sectionTitle)
                    .foregroundColor(.white)
                if let subtitulo, !subtitulo.isEmpty {
                    Text(subtitulo)
                        .font(HrFont.caption)
                        .foregroundColor(.hrTextMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 8)
            if let acao {
                Button {
                    onAcao?()
                } label: {
                    HStack(spacing: 2) {
                        Text(acao)
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.hrGoldLight)
                }
                .buttonStyle(HrPressStyle())
            }
        }
    }
}

/// Marca em texto: "HARD ROCK" 34 black spacing 3 hrGold; "HOTEL & VACATION CLUB" 12 semibold spacing 2 hrGoldLight.
/// Versão compacta: 22/9.
struct HrWordmark: View {
    var compact: Bool = false
    var alignment: HorizontalAlignment = .center

    var body: some View {
        VStack(alignment: alignment, spacing: compact ? 1 : 4) {
            Text("HARD ROCK")
                .font(.system(size: compact ? 22 : 34, weight: .black))
                .tracking(3)
                .foregroundColor(.hrGold)
            Text("HOTEL & VACATION CLUB")
                .font(.system(size: compact ? 9 : 12, weight: .semibold))
                .tracking(2)
                .foregroundColor(.hrGoldLight)
        }
        .fixedSize()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hard Rock Hotel & Vacation Club")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        HrWordmark()
        HrWordmark(compact: true)
        HStack { HrTag(text: "Certificado de viagem"); HrTag(text: "Founder", filled: true); HrTag(text: "A vencer", color: .hrWarning) }
        HStack { HrChip(text: "Todos", selected: true) {}; HrChip(text: "Viagens", selected: false) {} }
        HStack(spacing: 16) { HrStatusDot(text: "Em dia"); HrStatusDot(text: "Solicitado", color: .hrWarning); HrStatusDot(text: "Vencido", color: .hrError) }
        HrSectionTitle(titulo: "Próximas parcelas", subtitulo: "Mínimo de 10% de desconto", acao: "Ver todas") {}
    }
    .padding(HrMetrics.screenMargin)
    .hrScreen()
}
