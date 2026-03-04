//
//  SistemaView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct SistemaView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showThemeDialog = false
    @State private var showChatIA = false

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    private let configItems: [SistemaMenuItem] = [
        SistemaMenuItem(
            title: "Atendimento com IA",
            subtitle: "Converse com nosso assistente virtual",
            iconName: "bubble.left.and.bubble.right.fill",
            action: .chatIA
        ),
        SistemaMenuItem(
            title: "Tema",
            subtitle: "Alterar aparência do aplicativo",
            iconName: "gearshape.fill",
            action: .theme
        )
    ]

    private let legalItems: [SistemaMenuItem] = [
        SistemaMenuItem(
            title: "Termos de Uso",
            subtitle: "Leia nossos termos e condições",
            iconName: "doc.text.fill",
            action: .terms
        ),
        SistemaMenuItem(
            title: "Política de Privacidade",
            subtitle: "Como tratamos seus dados pessoais",
            iconName: "shield.fill",
            action: .privacy
        )
    ]

    var body: some View {
        ZStack {
            bg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra superior: voltar + título
                HStack(spacing: 16) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(textP)
                    }
                    Spacer()
                    Text("Sistema")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(textP)
                    Spacer()
                    Color.clear
                        .frame(width: 32, height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(bg)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Configurações
                        Text("Configurações")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(textP)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            ForEach(configItems) { item in
                                SistemaMenuItemView(item: item, isDark: isDark) {
                                    handleMenuAction(item.action)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Legal
                        Text("Legal")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(textP)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            ForEach(legalItems) { item in
                                SistemaMenuItemView(item: item, isDark: isDark) {
                                    handleMenuAction(item.action)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Text("Versão 1.0.0")
                            .font(.caption)
                            .foregroundColor(textS)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                            .padding(.bottom, 32)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .confirmationDialog("Tema do App", isPresented: $showThemeDialog) {
            Button("Claro") { appState.setThemeMode(false) }
            Button("Escuro") { appState.setThemeMode(true) }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Escolha o tema do aplicativo")
        }
        .sheet(isPresented: $showChatIA) {
            ChatAIScreen()
        }
        .navigationBarBackButtonHidden(true)
    }

    private func handleMenuAction(_ action: SistemaMenuAction) {
        switch action {
        case .theme:
            showThemeDialog = true
        case .terms:
            break
        case .privacy:
            break
        case .chatIA:
            showChatIA = true
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
    var isDark: Bool = true
    let action: () -> Void

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: item.iconName)
                    .font(.title3)
                    .foregroundColor(AppColors.accentBlue)
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(textP)
                    Text(item.subtitle)
                        .font(.subheadline)
                        .foregroundColor(textS)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(textS)
            }
            .padding()
            .background(cardBg)
            .cornerRadius(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 8)
    }
}

#Preview {
    NavigationStack {
        SistemaView()
            .environmentObject(AppState.shared)
    }
}
