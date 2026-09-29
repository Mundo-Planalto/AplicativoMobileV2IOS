//
//  HrTextField.swift
//  Hard Rock Hotel & Vacation Club
//
//  Campo de texto do Login: fundo hrSurface, borda hrGoldBorder (hrGold em foco),
//  ícone à esquerda e olho para mostrar/ocultar senha.
//

import SwiftUI

struct HrTextField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var onTextChange: ((String) -> String)? = nil

    @FocusState private var focused: Bool
    @State private var isPasswordVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(focused ? .hrGold : .hrGoldLight.opacity(0.8))
                .frame(width: 22)

            Group {
                if isSecure && !isPasswordVisible {
                    SecureField("", text: $text, prompt: Text(title).foregroundColor(.hrTextMuted))
                } else {
                    TextField("", text: $text, prompt: Text(title).foregroundColor(.hrTextMuted))
                }
            }
            .font(.system(size: 15))
            .foregroundColor(.white)
            .tint(.hrGold)
            .keyboardType(keyboard)
            .textContentType(contentType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focused)
            .onChange(of: text) { _, newValue in
                if let onTextChange {
                    let formatted = onTextChange(newValue)
                    if formatted != newValue { text = formatted }
                }
            }
            .accessibilityLabel(title)

            if isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.hrTextMuted)
                }
                .accessibilityLabel(isPasswordVisible ? "Ocultar senha" : "Mostrar senha")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                .fill(Color.hrSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                .stroke(focused ? Color.hrGold : Color.hrGoldBorder, lineWidth: 1)
        )
        .animation(.easeOut(duration: 0.15), value: focused)
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
    }
}

#Preview {
    VStack(spacing: 12) {
        HrTextField(title: "CPF/CNPJ", icon: "doc.text", text: .constant("123.456.789-00"), keyboard: .numberPad)
        HrTextField(title: "Senha", icon: "lock", text: .constant("segredo"), isSecure: true)
    }
    .padding(HrMetrics.screenMargin)
    .hrScreen()
}
