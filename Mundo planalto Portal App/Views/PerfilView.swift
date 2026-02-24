//
//  PerfilView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct PerfilView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = PerfilViewModel()
    @State private var navigateToSistema = false
    @State private var showAlterarSenha = false
    @State private var showEnderecos = false
    @State private var showSolicitarAlteracaoEndereco = false

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        ZStack {
            bg
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentBlue))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let err = viewModel.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text(err)
                        .foregroundColor(textP)
                        .multilineTextAlignment(.center)
                    Button("Tentar Novamente") {
                        Task { await viewModel.loadUserData() }
                    }
                    .foregroundColor(AppColors.accentBlue)
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Perfil")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(textP)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        // Card: avatar + nome + documento + email + telefone
                        VStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 60)
                                    .fill(cardBg)
                                    .frame(height: 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 60)
                                            .stroke(textS.opacity(0.3), lineWidth: 1)
                                    )
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 56))
                                    .foregroundColor(textS.opacity(0.6))
                            }
                            .padding(.top, 8)

                            Text(viewModel.userName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(textP)
                                .multilineTextAlignment(.center)

                            Text(viewModel.userDocument)
                                .font(.subheadline)
                                .foregroundColor(textP)

                            HStack(spacing: 8) {
                                Image(systemName: "envelope.fill")
                                    .font(.caption)
                                    .foregroundColor(textS)
                                Text(viewModel.userEmail.isEmpty ? "—" : viewModel.userEmail)
                                    .font(.subheadline)
                                    .foregroundColor(textP)
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "phone.fill")
                                    .font(.caption)
                                    .foregroundColor(textS)
                                Text(viewModel.userPhone)
                                    .font(.subheadline)
                                    .foregroundColor(textP)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(cardBg)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)

                        // Card: Endereço de Correspondência
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Endereço de Correspondência")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(textP)

                            Text(viewModel.userAddressLine1)
                                .font(.subheadline)
                                .foregroundColor(textP)
                            Text(viewModel.userAddressLine2)
                                .font(.subheadline)
                                .foregroundColor(textP)
                            Text(viewModel.userAddressCep)
                                .font(.subheadline)
                                .foregroundColor(textP)

                            Button("Solicitar Alteração") {
                                showSolicitarAlteracaoEndereco = true
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.accentBlue)
                            .cornerRadius(12)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(cardBg)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)

                        // Lista: Alterar Senha, Endereços, Sistema, Sair
                        VStack(spacing: 0) {
                            ForEach(viewModel.menuOptions) { option in
                                ProfileMenuRow(
                                    option: option,
                                    isDark: isDark,
                                    isLogout: option.action == .logout
                                ) {
                                    handleMenuAction(option.action)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToSistema) {
            SistemaView()
        }
        .sheet(isPresented: $showAlterarSenha) {
            // TODO: tela Alterar Senha
            Text("Alterar Senha")
        }
        .sheet(isPresented: $showEnderecos) {
            // TODO: tela Endereços
            Text("Endereços")
        }
        .sheet(isPresented: $showSolicitarAlteracaoEndereco) {
            SolicitarAlteracaoEnderecoView()
                .environmentObject(appState)
        }
        .onAppear {
            Task { await viewModel.loadUserData() }
        }
    }

    private func handleMenuAction(_ action: ProfileAction) {
        switch action {
        case .alterarSenha:
            showAlterarSenha = true
        case .enderecos:
            showEnderecos = true
        case .sistema:
            navigateToSistema = true
        case .logout:
            viewModel.performAction(.logout)
        }
    }
}

struct ProfileMenuRow: View {
    let option: ProfileMenuOption
    let isDark: Bool
    var isLogout: Bool = false
    let action: () -> Void

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: option.iconName)
                    .font(.title3)
                    .foregroundColor(isLogout ? AppColors.logoutRed : AppColors.accentBlue)
                    .frame(width: 28, height: 28)

                Text(option.title)
                    .font(.headline)
                    .foregroundColor(isLogout ? AppColors.logoutRed : textP)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(textS)
            }
            .padding()
            .background(cardBg)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        PerfilView()
            .environmentObject(AppState.shared)
    }
}
