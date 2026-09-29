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

    func loadUserData() async {
        isLoading = true
        error = nil

        // Demonstração: sem API. Dados fictícios do membro José R. Castro (ver docs/PENDENCIAS.md).
        if AppState.shared.isDemoSession {
            userName = MemberInfo.demo.nome
            userDocument = "***.456.789-**"
            userEmail = "jose.castro@exemplo.com"
            userPhone = "(62) 98888-0000"
            userAddressLine1 = "Rua T-63, 1200 — Apto 1208"
            userAddressLine2 = "Setor Bueno — Goiânia/GO"
            userAddressCep = "CEP: 74230-100"
            isLoading = false
            return
        }

        do {
            let response = try await ProfileService.shared.getProfile()
            let p = response.profile
            userName = p.name
            userDocument = p.cpf
            userEmail = p.email ?? ""
            userPhone = p.phone ?? "Não informado"

            let z1 = p.addressLine1?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let z2 = p.addressLine2?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let z3 = p.addressZipLine?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if !z1.isEmpty || !z2.isEmpty || !z3.isEmpty {
                userAddressLine1 = z1.isEmpty ? "—" : z1
                userAddressLine2 = z2.isEmpty ? "—" : z2
                userAddressCep = z3.isEmpty ? "CEP: não informado" : z3
            } else if let addr = p.address, !addr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                userAddressLine1 = addr
                userAddressLine2 = "—"
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
            userPhone = "Não informado"
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
