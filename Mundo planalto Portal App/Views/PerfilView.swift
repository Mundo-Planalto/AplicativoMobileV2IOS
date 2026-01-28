//
//  PerfilView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct PerfilView: View {
    @StateObject private var viewModel = PerfilViewModel()

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Avatar do usuário
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.accentCyan.opacity(0.2))
                                .frame(width: 80, height: 80)

                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.accentCyan)
                        }

                        VStack(spacing: 4) {
                            Text(viewModel.userName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text(viewModel.userEmail)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 24)

                    // Itens de menu
                    VStack(spacing: 8) {
                        ForEach(viewModel.menuOptions) { option in
                            ProfileMenuItem(option: option) {
                                viewModel.performAction(option.action)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .confirmationDialog("Tema do App", isPresented: $viewModel.showThemeDialog) {
            Button("Claro") {
                if !viewModel.isDarkTheme {
                    viewModel.toggleTheme()
                }
            }
            Button("Escuro") {
                if viewModel.isDarkTheme {
                    viewModel.toggleTheme()
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Escolha o tema do aplicativo")
        }
    }
}

struct ProfileMenuItem: View {
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