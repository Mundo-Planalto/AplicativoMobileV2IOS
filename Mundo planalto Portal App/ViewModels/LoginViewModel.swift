//
//  LoginViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

enum LoginState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var cpf: String = ""
    @Published var password: String = ""
    @Published var state: LoginState = .idle

    private let authService = AuthService.shared
    private var appState: AppState = AppState.shared
    
    var isFormValid: Bool {
        !cpf.isEmpty && !password.isEmpty && CPFMask.unformat(cpf).count == 11
    }
    
    func login() {
        // Prevent multiple simultaneous login attempts
        guard case .idle = state else {
            return
        }

        guard isFormValid else {
            state = .error("Por favor, preencha todos os campos corretamente")
            return
        }

        state = .loading

        Task {
            do {
                let response = try await authService.login(document: cpf, password: password)

                if response.success {
                    if let token = response.token {
                        PreferencesManager.shared.saveAuthToken(token)
                        PreferencesManager.shared.saveUserCpfCnpj(response.user?.document ?? CPFMask.unformat(cpf))
                    }
                    if let user = response.user {
                        PreferencesManager.shared.saveUserId("\(user.id)")
                        if let name = user.name { PreferencesManager.shared.saveUserName(name) }
                    }
                    appState.login()
                    state = .idle
                    print("[LoginViewModel] ✅ Login realizado com sucesso.")
                } else {
                    let msg = response.message ?? "Usuário ou senha incorreta."
                    print("[LoginViewModel] ❌ Login falhou (API): \(msg)")
                    state = .error(msg)
                }
            } catch AuthError.invalidCredentials {
                print("[LoginViewModel] ❌ Credenciais inválidas.")
                state = .error("Usuário ou senha incorreta.")
            } catch {
                print("[LoginViewModel] ❌ Erro ao fazer login: \(error)")
                print("[LoginViewModel]    Tipo: \(type(of: error)), descrição: \(error.localizedDescription)")
                state = .error("Erro ao fazer login. Verifique sua conexão e tente novamente.")
            }
        }
    }
    
    func formatCPF(_ text: String) -> String {
        // Remove formatação existente antes de aplicar nova formatação
        let unformatted = CPFMask.unformat(text)
        // Limita a 11 dígitos
        let limited = String(unformatted.prefix(11))
        return CPFMask.format(limited)
    }
}
