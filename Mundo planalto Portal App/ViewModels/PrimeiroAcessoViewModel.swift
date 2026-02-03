//
//  PrimeiroAcessoViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PrimeiroAcessoViewModel: ObservableObject {
    @Published var cpf: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var state: RegistrationState = .idle

    private let authService = AuthService.shared
    private var appState: AppState = AppState.shared

    enum RegistrationState: Equatable {
        case idle
        case loading
        case success
        case error(String)
    }

    var isFormValid: Bool {
        !cpf.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        CPFMask.unformat(cpf).count == 11 &&
        password.count >= 6
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func formatCPF(_ text: String) -> String {
        let unformatted = CPFMask.unformat(text)
        let limited = String(unformatted.prefix(11))
        return CPFMask.format(limited)
    }

    func register() async {
        guard isFormValid else {
            state = .error("Por favor, preencha todos os campos corretamente")
            return
        }

        state = .loading

        Task {
            do {
                let response = try await authService.primeiroAcesso(cpf: cpf, password: password, confirmPassword: confirmPassword)

                if response.success {
                    // Salvar token se fornecido
                    if let token = response.token {
                        PreferencesManager.shared.saveAuthToken(token)
                        PreferencesManager.shared.saveUserCpfCnpj(CPFMask.unformat(cpf))
                    }

                    state = .success
                    appState.login()
                } else {
                    state = .error(response.message ?? "Erro ao criar conta. Tente novamente.")
                }

            } catch {
                state = .error("Erro ao criar conta. Tente novamente.")
            }
        }
    }
}
