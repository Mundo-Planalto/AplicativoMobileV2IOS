//
//  AppState.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isLoggedIn = false

    static let shared = AppState()
    private let preferencesManager = PreferencesManager.shared

    private init() {
        // Inicializa sem verificar para evitar problemas
        isLoggedIn = false
    }

    func checkInitialLoginState() {
        // Verificar se há token válido salvo
        isLoggedIn = preferencesManager.hasValidSession()
    }

    func login() {
        // Salvar token mockado
        preferencesManager.saveAuthToken("mock_token")
        // Salvar dados do usuário mockados
        preferencesManager.saveUserId("user123")
        preferencesManager.saveUserCpfCnpj("12345678900")
        isLoggedIn = true
    }

    func logout() async {
        do {
            // Tentar fazer logout na API
            let authService = AuthService.shared
            _ = try await authService.logout()
        } catch {
            // Mesmo se falhar, continua com o logout local
            print("Erro ao fazer logout remoto: \(error)")
        }

        // Limpar todos os dados locais
        preferencesManager.clearAllData()
        isLoggedIn = false
    }

    // MARK: - User Data Access
    var userId: String? {
        return preferencesManager.getUserId()
    }

    var userCpfCnpj: String? {
        return preferencesManager.getUserCpfCnpj()
    }

    var isDarkTheme: Bool {
        return preferencesManager.getThemeMode()
    }

    func setThemeMode(_ isDark: Bool) {
        preferencesManager.saveThemeMode(isDark)
    }

    var notificationsEnabled: Bool {
        return preferencesManager.getNotificationsEnabled()
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        preferencesManager.saveNotificationsEnabled(enabled)
    }
}