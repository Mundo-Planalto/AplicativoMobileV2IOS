//
//  LoginViewModel.swift
//  Mundo Planalto
//
//  Login real (POST auth/login) e entrada em modo demonstração (sem API).
//  Apenas o token JWT é persistido (Keychain); a senha nunca é armazenada.
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

    /// CPF (11) ou CNPJ (14) e senha com pelo menos 6 caracteres.
    var isFormValid: Bool {
        CPFMask.isValidDocumentLength(cpf) && password.count >= 6
    }

    func login() {
        if case .loading = state { return }
        guard isFormValid else {
            state = .error("Informe um CPF/CNPJ válido e uma senha com pelo menos 6 caracteres.")
            return
        }
        state = .loading
        Task {
            do {
                let response = try await authService.login(document: cpf, password: password)

                if response.success, let token = response.token, !token.isEmpty {
                    PreferencesManager.shared.saveAuthToken(token)
                    PreferencesManager.shared.saveUserCpfCnpj(response.user?.document ?? CPFMask.unformat(cpf))
                    if let user = response.user {
                        PreferencesManager.shared.saveUserId("\(user.id)")
                        if let name = user.name { PreferencesManager.shared.saveUserName(name) }
                    }
                    password = ""
                    appState.login()
                    state = .idle
                } else {
                    let msg = response.message ?? "Usuário ou senha incorreta."
                    state = .error(msg)
                }
            } catch AuthError.invalidCredentials {
                state = .error("Usuário ou senha incorreta.")
            } catch {
                state = .error(
                    AppErrorMapper.userMessage(
                        for: error,
                        fallback: "Erro ao fazer login. Tente novamente."
                    )
                )
            }
        }
    }

    #if DEBUG
    /// Entra com o usuário fictício José R. Castro, sem chamar a API.
    func loginDemo() {
        if case .loading = state { return }
        password = ""
        state = .idle
        appState.loginDemo()
    }
    #endif

    func formatDocument(_ text: String) -> String {
        CPFMask.format(text)
    }
}
