//
//  PrimeiroAcessoView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct PrimeiroAcessoView: View {
    @StateObject private var viewModel = PrimeiroAcessoViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                    VStack(spacing: 16) {
                        Spacer()

                        // Logo/Título
                        VStack(spacing: 8) {
                            Text("Primeiro Acesso")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Crie sua conta para acessar o portal")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 32)

                        // Campos do formulário
                        VStack(spacing: 16) {
                            // CPF/CNPJ
                            CustomTextField(
                                title: "CPF/CNPJ",
                                icon: "person.text.rectangle",
                                text: $viewModel.cpf,
                                isNumeric: true,
                                onTextChange: { newValue in
                                    return viewModel.formatCPF(newValue)
                                }
                            )

                            // Senha
                            CustomTextField(
                                title: "Senha",
                                icon: "lock.fill",
                                text: $viewModel.password,
                                isSecure: true
                            )

                            // Confirmar Senha
                            CustomTextField(
                                title: "Confirmar Senha",
                                icon: "lock.fill",
                                text: $viewModel.confirmPassword,
                                isSecure: true
                            )
                        }
                        .padding(.horizontal)

                        // Botão de cadastro
                        GradientButton(
                            title: "Criar Conta",
                            action: {
                                Task {
                                    await viewModel.register()
                                }
                            },
                            isLoading: viewModel.state == .loading,
                            isEnabled: viewModel.isFormValid
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Mensagem de erro
                        if case .error(let message) = viewModel.state {
                            Text(message)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 32)
                }
            }
            .background(
                // Gradiente de fundo azul-ciano
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.accentBlue, AppColors.accentCyan]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }


#Preview {
    PrimeiroAcessoView()
}
