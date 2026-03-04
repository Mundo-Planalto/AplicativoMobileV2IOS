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
    @Published var userDocument: String = ""
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    @Published var userAddressLine1: String = ""
    @Published var userAddressLine2: String = ""
    @Published var userAddressCep: String = ""
    @Published var isLoading = false
    @Published var error: String?

    var userCPF: String { userDocument }

    let menuOptions: [ProfileMenuOption] = [
        // ProfileMenuOption(title: "Alterar Senha", subtitle: "Alterar sua senha de acesso", iconName: "lock.fill", action: .alterarSenha),
        // ProfileMenuOption(title: "Endereços", subtitle: "Gerenciar endereços", iconName: "mappin.circle.fill", action: .enderecos),
        ProfileMenuOption(title: "Sistema",
                          subtitle: "Tema e configurações",
                          iconName: "gearshape.fill",
                          action: .sistema),
        ProfileMenuOption(title: "Sair",
                          subtitle: "Encerrar sessão",
                          iconName: "rectangle.portrait.and.arrow.right",
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
            let response = try await ProfileService.shared.getProfile()
            let p = response.profile
            userName = p.name
            userDocument = p.cpf
            userEmail = p.email ?? ""
            userPhone = p.phone ?? "Não possui"
            if let addr = p.address, !addr.isEmpty {
                userAddressLine1 = addr
                userAddressLine2 = addr
                userAddressCep = ""
            } else {
                userAddressLine1 = "Sem Informação, Sem Informação"
                userAddressLine2 = "Sem Informação - Sem Informação"
                userAddressCep = "CEP: Sem Informação"
            }
        } catch {
            userName = "Usuário"
            userDocument = PreferencesManager.shared.getUserCpfCnpj() ?? ""
            userEmail = ""
            userPhone = "Não possui"
            userAddressLine1 = "Sem Informação, Sem Informação"
            userAddressLine2 = "Sem Informação - Sem Informação"
            userAddressCep = "CEP: Sem Informação"
            self.error = nil
        }

        isLoading = false
    }

    func performAction(_ action: ProfileAction) {
        switch action {
        case .alterarSenha, .enderecos, .sistema:
            break
        case .logout:
            logout()
        }
    }

    private func logout() {
        // Limpar dados do usuário conforme documentação
        UserDefaults.standard.removeObject(forKey: "auth_token")
        Task {
            await AppState.shared.logout()
        }
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
    case alterarSenha
    case enderecos
    case sistema
    case logout
}
