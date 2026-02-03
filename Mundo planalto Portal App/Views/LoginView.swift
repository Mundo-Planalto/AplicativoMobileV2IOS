//
//  LoginView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var navigateToRegister = false
    
    private var isLoading: Bool {
        if case .loading = viewModel.state {
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                // Conteúdo centralizado
                VStack(spacing: 16) {
                    // Logo ou título do app (opcional)
                    Text("Mundo Planalto")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 32)

                    // Campo CPF
                    CustomTextField(
                        title: "CPF",
                        icon: "person.text.rectangle",
                        text: $viewModel.cpf,
                        isNumeric: true,
                        onTextChange: { newValue in
                            return viewModel.formatCPF(newValue)
                        }
                    )
                    .padding(.horizontal, 16)

                    // Campo Senha
                    CustomTextField(
                        title: "Senha",
                        icon: "lock.fill",
                        text: $viewModel.password,
                        isSecure: true
                    )
                    .padding(.horizontal, 16)

                    // Botão Entrar
                    GradientButton(
                        title: "Entrar",
                        action: {
                            viewModel.login()
                        },
                        isLoading: isLoading,
                        isEnabled: viewModel.isFormValid
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Link Primeiro Acesso
                    Button(action: {
                        navigateToRegister = true
                    }) {
                        Text("Primeiro Acesso")
                            .foregroundColor(.white)
                            .underline()
                            .font(.subheadline)
                    }
                    .padding(.top, 16)

                    // Mensagem de erro
                    if case .error(let message) = viewModel.state {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 8)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 32)

                Spacer()
            }
            .background(
                // Gradiente de fundo vertical (AccentBlue → AccentCyan)
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.accentBlue, AppColors.accentCyan]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationDestination(isPresented: $navigateToRegister) {
                PrimeiroAcessoView()
            }
        }
    }
}

#Preview {
    LoginView()
}
