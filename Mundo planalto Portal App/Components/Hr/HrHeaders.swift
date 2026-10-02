//
//  HrHeaders.swift
//  Mundo Planalto
//
//  HrHeader (abas) e HrBackHeader (telas empilhadas).
//

import SwiftUI

/// MundoPlanaltoSymbol(18) dourado + "Olá, {primeiro nome}" + sino à direita; título 30 bold; subtítulo muted.
struct HrHeader: View {
    let nome: String?
    let titulo: String
    let subtitulo: String?
    var onNotificacoes: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                MundoPlanaltoSymbol(18)
                Text(greeting)
                    .font(HrFont.body)
                    .foregroundColor(.hrTextMuted)
                Spacer()
                if let onNotificacoes {
                    Button(action: onNotificacoes) {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.hrGoldLight)
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                                    .fill(Color.hrSurfaceElevated)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                                    .stroke(Color.hrGoldBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(HrPressStyle())
                    .accessibilityLabel("Avisos e notícias")
                }
            }
            Text(titulo)
                .font(HrFont.screenTitle)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitulo, !subtitulo.isEmpty {
                Text(subtitulo)
                    .font(HrFont.body)
                    .foregroundColor(.hrTextMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 8)
    }

    private var greeting: String {
        let first = HrNames.firstName(from: nome)
        return first.isEmpty ? "Olá" : "Olá, \(first)"
    }
}

/// Seta chevron.left dourada + título 22 bold + subtítulo.
struct HrBackHeader: View {
    @Environment(\.dismiss) private var dismiss
    let titulo: String
    var subtitulo: String? = nil
    var onBack: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                if let onBack { onBack() } else { dismiss() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.hrGold)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                            .fill(Color.hrSurfaceElevated)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                            .stroke(Color.hrGoldBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(HrPressStyle())
            .accessibilityLabel("Voltar")

            VStack(alignment: .leading, spacing: 4) {
                Text(titulo)
                    .font(HrFont.backTitle)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitulo, !subtitulo.isEmpty {
                    Text(subtitulo)
                        .font(HrFont.caption)
                        .foregroundColor(.hrTextMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 6)
            Spacer(minLength: 0)
        }
        .padding(.top, 8)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 32) {
        HrHeader(nome: "ROBSON SILVA", titulo: "Seus benefícios", subtitulo: "Experiências que valorizam sua jornada", onNotificacoes: {})
        HrBackHeader(titulo: "Certificados de viagem", subtitulo: "Escolha uma experiência para solicitar")
    }
    .padding(HrMetrics.screenMargin)
    .hrScreen()
}
