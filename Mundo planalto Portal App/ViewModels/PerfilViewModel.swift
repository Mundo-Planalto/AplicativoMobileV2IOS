//
//  PerfilViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PerfilViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userCPF: String = ""
    @Published var userPhone: String = ""
    @Published var isLoading = false
    @Published var error: String?

    let menuOptions: [ProfileMenuOption] = [
        ProfileMenuOption(title: "Sistema",
                          subtitle: "Tema e configurações",
                          iconName: "gear",
                          action: .sistema),
        ProfileMenuOption(title: "Atendimento com IA",
                          subtitle: "Converse com nosso assistente",
                          iconName: "message.circle.fill",
                          action: .chatIA),
        ProfileMenuOption(title: "Sair",
                          subtitle: "Encerrar sessão",
                          iconName: "arrow.right.square",
                          action: .logout)
    ]

    init() {
        Task {
            await loadUserData()
        }
    }

    func loadUserData() async {
        isLoading = true
        error = nil

        do {
            // Simular carregamento de dados da API - em produção seria PreferencesManager + API
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo

            // Dados mockados conforme documentação
            userName = "João Silva"
            userCPF = "123.456.789-00"
            userPhone = "Não possui" // Conforme documentação

        } catch {
            self.error = "Erro ao carregar dados do perfil"
        }

        isLoading = false
    }

    func performAction(_ action: ProfileAction) {
        switch action {
        case .sistema:
            // Navegação será tratada pela view
            print("Navegar para sistema")
        case .chatIA:
            // Navegação será tratada pela view
            print("Abrir chat IA")
        case .logout:
            logout()
        }
    }

    private func logout() {
        // Limpar dados do usuário conforme documentação
        UserDefaults.standard.removeObject(forKey: "auth_token")
        AppState.shared.logout()
        print("Usuário deslogado")
    }
}

struct ProfileMenuOption: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let action: ProfileAction
}

enum ProfileAction {
    case sistema
    case chatIA
    case logout
}