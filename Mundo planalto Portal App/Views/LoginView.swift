//
//  LoginView.swift
//  Mundo Planalto
//
//  Login: CPF/CNPJ e senha contra a API do portal, "Esqueci minha senha",
//  "Primeiro acesso" e "Acessar demonstração" (usuário fictício, sem API).
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = LoginViewModel()
    @State private var navigateToRegister = false

    private var isLoading: Bool {
        if case .loading = viewModel.state { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrBlack.ignoresSafeArea()
                RadialGradient(colors: [Color.hrGold.opacity(0.10), .clear], center: .top, startRadius: 0, endRadius: 320)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        MundoPlanaltoLogo()
                            .padding(.top, 48)
                            .padding(.bottom, 36)

                        Text("Bem-vindo ao seu clube")
                            .font(HrFont.screenTitle)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Acesse com seu CPF/CNPJ e senha")
                            .font(HrFont.body)
                            .foregroundColor(.hrTextMuted)
                            .padding(.top, 6)
                            .padding(.bottom, 28)

                        VStack(spacing: 12) {
                            HrTextField(
                                title: "CPF/CNPJ",
                                icon: "doc.text",
                                text: $viewModel.cpf,
                                keyboard: .numberPad,
                                contentType: .username,
                                onTextChange: { viewModel.formatDocument($0) }
                            )
                            HrTextField(
                                title: "Senha",
                                icon: "lock",
                                text: $viewModel.password,
                                isSecure: true,
                                contentType: .password
                            )
                        }

                        if case .error(let message) = viewModel.state {
                            errorCard(message)
                                .padding(.top, 12)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        } else if let expired = appState.sessionExpiredMessage {
                            errorCard(expired)
                                .padding(.top, 12)
                        }

                        HrGoldButton(
                            text: "Entrar",
                            isLoading: isLoading,
                            isEnabled: viewModel.isFormValid
                        ) {
                            viewModel.login()
                        }
                        .padding(.top, 20)

                        VStack(spacing: 14) {
                            if let url = URL(string: AppConfig.forgotPasswordURL) {
                                Link("Esqueci minha senha", destination: url)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.hrGoldLight)
                            }

                            Rectangle()
                                .fill(Color.hrGoldBorder)
                                .frame(width: 60, height: 1)

                            Button {
                                navigateToRegister = true
                            } label: {
                                Text("Primeiro acesso")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.hrGoldLight)
                            }

                            if AppConfig.showDemoLogin {
                                Button {
                                    viewModel.loginDemo()
                                } label: {
                                    Text("Acessar demonstração")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.hrTextMuted)
                                        .underline()
                                }
                                .disabled(isLoading)
                            }
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, HrMetrics.screenMargin)
                    .animation(.easeOut(duration: 0.2), value: viewModel.state)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToRegister) {
                PrimeiroAcessoView()
            }
        }
    }

    /// Erro em card vermelho translúcido.
    private func errorCard(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.hrError)
            Text(message)
                .font(HrFont.caption)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                .fill(Color.hrError.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous)
                .stroke(Color.hrError.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState.shared)
}
