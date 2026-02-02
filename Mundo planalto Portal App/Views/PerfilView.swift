//
//  PerfilView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct PerfilView: View {
    @StateObject private var viewModel = PerfilViewModel()
    @State private var navigateToSistema = false
    @State private var showChatIA = false

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentCyan))
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Button("Tentar Novamente") {
                            Task {
                                await viewModel.loadUserData()
                            }
                        }
                        .foregroundColor(AppColors.accentCyan)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Avatar do usuário - Circle 80dp, ícone person
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentCyan.opacity(0.2))
                                        .frame(width: 80, height: 80)

                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppColors.accentCyan)
                                }
                            }
                            .padding(.vertical, 24)

                            // Informações pessoais - nome, CPF, telefone
                            VStack(spacing: 16) {
                                InfoRow(icon: "person.fill", title: "Nome", value: viewModel.userName)
                                InfoRow(icon: "creditcard.fill", title: "CPF", value: viewModel.userCPF)
                                InfoRow(icon: "phone.fill", title: "Telefone", value: viewModel.userPhone)
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)

                            // Menu opções - Sistema, Atendimento IA, Logout
                            VStack(spacing: 8) {
                                ForEach(viewModel.menuOptions) { option in
                                    ProfileMenuRow(option: option) {
                                        handleMenuAction(option.action)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToSistema) {
            SistemaView()
        }
        .sheet(isPresented: $showChatIA) {
            ChatAIScreen()
        }
        .onAppear {
            Task {
                await viewModel.loadUserData()
            }
        }
    }

    private func handleMenuAction(_ action: ProfileAction) {
        switch action {
        case .sistema:
            navigateToSistema = true
        case .chatIA:
            showChatIA = true
        case .logout:
            viewModel.performAction(.logout)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.accentCyan)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }

            Spacer()
        }
    }
}

struct ProfileMenuRow: View {
    let option: ProfileMenuOption
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: option.iconName)
                    .font(.title2)
                    .foregroundColor(AppColors.accentCyan)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(option.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        PerfilView()
    }
}