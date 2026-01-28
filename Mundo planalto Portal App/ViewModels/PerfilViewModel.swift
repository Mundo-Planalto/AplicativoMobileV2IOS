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
    @Published var userEmail: String = ""
    @Published var userCPF: String = ""
    @Published var isDarkTheme: Bool = true
    @Published var showThemeDialog = false

    let menuOptions: [ProfileMenuOption] = [
        ProfileMenuOption(title: "Informações Pessoais",
                         subtitle: "Gerencie seus dados",
                         iconName: "person.fill",
                         action: .personalInfo),
        ProfileMenuOption(title: "Tema do App",
                         subtitle: "Claro ou escuro",
                         iconName: "moon.fill",
                         action: .theme),
        ProfileMenuOption(title: "Notificações",
                         subtitle: "Configurar alertas",
                         iconName: "bell.fill",
                         action: .notifications),
        ProfileMenuOption(title: "Contato e Suporte",
                         subtitle: "Fale conosco",
                         iconName: "phone.fill",
                         action: .support),
        ProfileMenuOption(title: "Sair",
                         subtitle: "Encerrar sessão",
                         iconName: "arrow.right.square",
                         action: .logout)
    ]

    init() {
        loadUserData()
    }

    private func loadUserData() {
        // Dados mockados - em produção viriam da API
        userName = "João Silva"
        userEmail = "joao.silva@email.com"
        userCPF = "123.456.789-00"
        isDarkTheme = true
    }

    func toggleTheme() {
        isDarkTheme.toggle()
        // TODO: Salvar preferência no UserDefaults
        print("Tema alterado para: \(isDarkTheme ? "escuro" : "claro")")
    }

    func performAction(_ action: ProfileAction) {
        switch action {
        case .personalInfo:
            // TODO: Navegar para edição de dados pessoais
            print("Editar informações pessoais")
        case .theme:
            showThemeDialog = true
        case .notifications:
            // TODO: Navegar para configurações de notificações
            print("Configurar notificações")
        case .support:
            // TODO: Navegar para tela de suporte
            print("Contato e suporte")
        case .logout:
            logout()
        }
    }

    private func logout() {
        // Limpar dados do usuário
        UserDefaults.standard.removeObject(forKey: "auth_token")
        // TODO: Navegar para tela de login
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
    case personalInfo
    case theme
    case notifications
    case support
    case logout
}