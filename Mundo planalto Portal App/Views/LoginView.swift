//
//  LoginView.swift
//  Mundo planalto Portal App
//
//  Tela de login: CPF/CNPJ, senha, Esqueceu senha, Primeiro Acesso.
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

                            Button {
                                viewModel.login()
                            } label: {
                                Group {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Entrar")
                                            .fontWeight(.bold)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.accentBlue)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .disabled(!viewModel.isFormValid || isLoading)

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
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.accentBlue)
                            }
                            .padding(.top, 8)

                            if case .error(let message) = viewModel.state {
                                Text(message)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                            }
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

#Preview {
    LoginView()
        .environmentObject(AppState.shared)
}
