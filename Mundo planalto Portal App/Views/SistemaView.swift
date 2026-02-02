//
//  SistemaView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct SistemaView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showThemeDialog = false
    @State private var showChatIA = false
    @State private var navigateToSupport = false

    let menuItems: [SistemaMenuItem] = [
        SistemaMenuItem(
            title: "Tema",
            subtitle: "Claro ou escuro",
            iconName: "moon.fill",
            action: .theme
        ),
        SistemaMenuItem(
            title: "Termos de Uso",
            subtitle: "Leia nossos termos",
            iconName: "doc.text.fill",
            action: .terms
        ),
        SistemaMenuItem(
            title: "Política de Privacidade",
            subtitle: "Como protegemos seus dados",
            iconName: "hand.raised.fill",
            action: .privacy
        ),
        SistemaMenuItem(
            title: "Atendimento com IA",
            subtitle: "Converse com nosso assistente",
            iconName: "message.circle.fill",
            action: .chatIA
        )
    ]

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopAppBar
                ZStack {
                    AppColors.backgroundPrimary
                        .ignoresSafeArea()

                    HStack {
                        Button(action: {
                            // Voltar será tratado pela NavigationStack
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }

                        Spacer()

                        Text("Sistema")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 60)

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(menuItems) { item in
                            SistemaMenuItemView(item: item) {
                                handleMenuAction(item.action)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                }
            }
        }
        .confirmationDialog("Tema do App", isPresented: $showThemeDialog) {
            Button("Claro") {
                appState.setThemeMode(false)
                print("Tema claro selecionado")
            }
            Button("Escuro") {
                appState.setThemeMode(true)
                print("Tema escuro selecionado")
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Escolha o tema do aplicativo")
        }
        .sheet(isPresented: $showChatIA) {
            ChatAIScreen()
        }
        .navigationDestination(isPresented: $navigateToSupport) {
            CriarTicketView()
        }
    }

    private func handleMenuAction(_ action: SistemaMenuAction) {
        switch action {
        case .theme:
            showThemeDialog = true
        case .terms:
            // TODO: Navegar para termos de uso
            print("Termos de uso")
        case .privacy:
            // TODO: Navegar para política de privacidade
            print("Política de privacidade")
        case .chatIA:
            navigateToSupport = true
        }
    }
}

struct SistemaMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let action: SistemaMenuAction
}

enum SistemaMenuAction {
    case theme
    case terms
    case privacy
    case chatIA
}

struct SistemaMenuItemView: View {
    let item: SistemaMenuItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: item.iconName)
                    .font(.title2)
                    .foregroundColor(AppColors.accentCyan)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(item.subtitle)
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
        SistemaView()
            .environmentObject(AppState.shared)
    }
}