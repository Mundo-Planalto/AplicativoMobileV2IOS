//
//  HrButtons.swift
//  Hard Rock Hotel & Vacation Club
//
//  HrGoldButton (principal) e HrOutlineButton (secundário).
//

import SwiftUI

/// Botão principal: altura 46, raio 12, gradiente dourado, texto preto bold 14 + chevron.
struct HrGoldButton: View {
    let text: String
    var trailingArrow: Bool = true
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                HStack(spacing: 6) {
                    Text(text)
                        .font(HrFont.buttonPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    if trailingArrow {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .foregroundColor(.black)
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: HrMetrics.primaryButtonHeight)
            .background(HrGradient.gold)
            .clipShape(RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous))
            .opacity(isEnabled ? 1 : 0.5)
        }
        .buttonStyle(HrPressStyle())
        .disabled(!isEnabled || isLoading)
    }
}

/// Botão secundário: altura 42, raio 12, borda 1pt hrGold, texto hrGoldLight semibold 13.
struct HrOutlineButton: View {
    let text: String
    var icon: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(text)
                    .font(HrFont.buttonSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundColor(isEnabled ? .hrGoldLight : .hrTextMuted)
            .frame(maxWidth: .infinity)
            .frame(height: HrMetrics.secondaryButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                    .stroke(isEnabled ? Color.hrGold : Color.hrGoldBorder, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous))
        }
        .buttonStyle(HrPressStyle())
        .disabled(!isEnabled)
    }
}

/// Botão quadrado com ícone (ex.: QR Code no Perfil): 46pt, borda dourada.
struct HrIconSquareButton: View {
    let icon: String
    var size: CGFloat = 46
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(.hrGoldLight)
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                        .stroke(Color.hrGold, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(HrPressStyle())
    }
}

/// Feedback de toque padrão (leve escala e opacidade).
struct HrPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        HrGoldButton(text: "Entrar") {}
        HrGoldButton(text: "Carregando", isLoading: true) {}
        HrOutlineButton(text: "Editar perfil") {}
        HrOutlineButton(text: "Aguardando Pós-vendas", isEnabled: false) {}
        HrIconSquareButton(icon: "qrcode") {}
    }
    .padding()
    .hrScreen()
}
