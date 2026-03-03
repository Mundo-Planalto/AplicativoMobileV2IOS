//
//  PrimeiroAcessoView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct PrimeiroAcessoView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PrimeiroAcessoViewModel()
    @State private var step: Int = 1

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button {
                        if step == 1 {
                            dismiss()
                        } else {
                            step = 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(textP)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 24) {
                        Text("Crie sua Conta")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textP)
                            .padding(.top, 24)

                        if step == 1 {
                            CustomTextField(
                                title: "CPF/CNPJ",
                                icon: "doc.text",
                                text: $viewModel.cpf,
                                isNumeric: true,
                                onTextChange: { viewModel.formatCPF($0) },
                                useLightInputStyle: !isDark
                            )
                            .padding(.horizontal, 20)

                            Button {
                                step = 2
                            } label: {
                                Text("Continuar")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(AppColors.accentBlue)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .disabled(viewModel.cpf.trimmingCharacters(in: .whitespaces).isEmpty)
                            .opacity(viewModel.cpf.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
                        } else {
                            CustomTextField(
                                title: "Senha",
                                icon: "lock.fill",
                                text: $viewModel.password,
                                isSecure: true,
                                useLightInputStyle: !isDark
                            )
                            .padding(.horizontal, 20)

                            CustomTextField(
                                title: "Confirmar Senha",
                                icon: "lock.fill",
                                text: $viewModel.confirmPassword,
                                isSecure: true,
                                useLightInputStyle: !isDark
                            )
                            .padding(.horizontal, 20)

                            Button {
                                Task { await viewModel.register() }
                            } label: {
                                Group {
                                    if viewModel.state == .loading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Criar Conta")
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.accentBlue)
                                .cornerRadius(12)
                            }
                            .disabled(!viewModel.isFormValid || viewModel.state == .loading)
                            .opacity(viewModel.isFormValid && viewModel.state != .loading ? 1 : 0.6)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        }

                        if case .error(let message) = viewModel.state {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        PrimeiroAcessoView()
            .environmentObject(AppState.shared)
    }
}
