//
//  LoginView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

private let forgotPasswordURL = "https://portal.mundoplanalto.com.br/Account/ForgotPassword"

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = LoginViewModel()
    @State private var navigateToRegister = false

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }

    private var isLoading: Bool {
        if case .loading = viewModel.state { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        LogoMundoPlanaltoImageView(isDark: isDark, size: 64)
                            .padding(.top, 40)
                        Text("Mundo Planalto Portal")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textP)
                        Text("Bem-vindo de volta")
                            .font(.subheadline)
                            .foregroundColor(textS)

                        VStack(spacing: 16) {
                            CustomTextField(
                                title: "CPF/CNPJ",
                                icon: "doc.text",
                                text: $viewModel.cpf,
                                isNumeric: true,
                                onTextChange: { viewModel.formatCPF($0) },
                                useLightInputStyle: !isDark
                            )
                            .padding(.horizontal, 20)

                            CustomTextField(
                                title: "Senha",
                                icon: "lock.fill",
                                text: $viewModel.password,
                                isSecure: true,
                                useLightInputStyle: !isDark
                            )
                            .padding(.horizontal, 20)

                            PrimaryButton(
                                title: "Entrar",
                                action: { viewModel.login() },
                                isLoading: isLoading,
                                isEnabled: viewModel.isFormValid,
                                isDark: isDark
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                            if let url = URL(string: forgotPasswordURL) {
                                Link("Esqueceu sua senha?", destination: url)
                                    .font(.subheadline)
                                    .foregroundColor(textS)
                            }

                            Button {
                                navigateToRegister = true
                            } label: {
                                Text("Primeiro Acesso? Cadastre-se")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.accentBlue)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 24)

                        if case .error(let message) = viewModel.state {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                PrimeiroAcessoView()
            }
        }
    }
}

/// Botão primário azul (tema: fundo claro ou escuro)
private struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isEnabled: Bool = true
    var isDark: Bool = true

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.accentBlue)
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled && !isLoading ? 1 : 0.6)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState.shared)
}
