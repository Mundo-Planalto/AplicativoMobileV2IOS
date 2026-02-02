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
    @Published var errorMessage: String = ""

    private let authService = AuthService.shared
    private var appState: AppState = AppState.shared
    
    var isFormValid: Bool {
        !cpf.isEmpty && !password.isEmpty && CPFMask.unformat(cpf).count == 11
    }
    
    func login() {
        guard isFormValid else {
            state = .error("Por favor, preencha todos os campos corretamente")
            return
        }
        
        state = .loading
        errorMessage = ""
        
        Task {
            do {
                // Simular chamada de API (remover em produção)
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo para simular delay

                // Simular sucesso para desenvolvimento
                state = .success
                appState.login()
            } catch {
                state = .error("Erro ao fazer login. Tente novamente.")
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
