//
//  CustomTextField.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct CustomTextField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var isSecure: Bool = false
    var isNumeric: Bool = false
    var onTextChange: ((String) -> String)? = nil

    @State private var isPasswordVisible: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.accentBlue)
                .frame(width: 20)

            ZStack {
                if isSecure && !isPasswordVisible {
                    SecureField(title, text: $text)
                        .accessibilityLabel(title)
                        .accessibilityHint(LocalizedStringKey("Campo de senha com botão para mostrar/ocultar"))
                        .onChange(of: text) { newValue in
                            if let onTextChange = onTextChange {
                                let formatted = onTextChange(newValue)
                                if formatted != text {
                                    text = formatted
                                }
                            }
                        }
                } else {
                    TextField(title, text: $text)
                        .accessibilityLabel(title)
                        .accessibilityHint(isSecure ? LocalizedStringKey("Campo de senha com botão para mostrar/ocultar") : LocalizedStringKey(""))
                        .onChange(of: text) { newValue in
                            if let onTextChange = onTextChange {
                                let formatted = onTextChange(newValue)
                                if formatted != text {
                                    text = formatted
                                }
                            }
                        }
                }
            }

            if isSecure {
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(AppColors.accentBlue)
                }
                .accessibilityLabel(isPasswordVisible ? "Ocultar senha" : "Mostrar senha")
            }
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .cornerRadius(16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Campo de entrada: \(title)")
    }
}