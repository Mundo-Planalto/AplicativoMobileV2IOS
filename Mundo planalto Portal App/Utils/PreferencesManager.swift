//
//  PreferencesManager.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

class PreferencesManager {
    static let shared = PreferencesManager()

    private let userDefaults = UserDefaults.standard

    // Keys
    private let authTokenKey = "auth_token"
    private let themeModeKey = "theme_mode"
    private let userIdKey = "user_id"
    private let userNameKey = "user_name"
    private let userCpfCnpjKey = "user_cpf_cnpj"
    private let notificationsEnabledKey = "notifications_enabled"

    private init() {}

    // MARK: - Authentication Token
    func saveAuthToken(_ token: String) {
        userDefaults.set(token, forKey: authTokenKey)
        userDefaults.synchronize()
    }

    func getAuthToken() -> String? {
        return userDefaults.string(forKey: authTokenKey)
    }

    func clearAuthToken() {
        userDefaults.removeObject(forKey: authTokenKey)
        userDefaults.synchronize()
    }

    // MARK: - Theme Mode
    func saveThemeMode(_ isDark: Bool) {
        userDefaults.set(isDark, forKey: themeModeKey)
        userDefaults.synchronize()
    }

    func getThemeMode() -> Bool {
        return userDefaults.bool(forKey: themeModeKey)
    }

    // MARK: - User Data
    func saveUserId(_ userId: String) {
        userDefaults.set(userId, forKey: userIdKey)
        userDefaults.synchronize()
    }

    func getUserId() -> String? {
        return userDefaults.string(forKey: userIdKey)
    }

    func saveUserName(_ name: String) {
        userDefaults.set(name, forKey: userNameKey)
        userDefaults.synchronize()
    }

    func getUserName() -> String? {
        return userDefaults.string(forKey: userNameKey)
    }

    func saveUserCpfCnpj(_ cpfCnpj: String) {
        userDefaults.set(cpfCnpj, forKey: userCpfCnpjKey)
        userDefaults.synchronize()
    }

    func getUserCpfCnpj() -> String? {
        return userDefaults.string(forKey: userCpfCnpjKey)
    }

    // MARK: - Notifications
    func saveNotificationsEnabled(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: notificationsEnabledKey)
        userDefaults.synchronize()
    }

    func getNotificationsEnabled() -> Bool {
        // Default true se não estiver definido
        return userDefaults.object(forKey: notificationsEnabledKey) != nil ?
               userDefaults.bool(forKey: notificationsEnabledKey) : true
    }

    // MARK: - Utility Methods
    func clearAllData() {
        let keys = [authTokenKey, themeModeKey, userIdKey, userNameKey, userCpfCnpjKey, notificationsEnabledKey]
        keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
    }

    func hasValidSession() -> Bool {
        return getAuthToken() != nil
    }
}