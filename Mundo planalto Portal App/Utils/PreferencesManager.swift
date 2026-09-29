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

    /// Token no Keychain: permanece entre sessões do app até logout explícito.
    private var keychainService: String {
        Bundle.main.bundleIdentifier ?? "com.portal.MundoPlanalto.auth"
    }

    private let keychainTokenAccount = "auth_access_token"
    private let keychainLoginDocumentAccount = "auth_login_document"
    private let keychainLoginPasswordAccount = "auth_login_password"

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
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        _ = KeychainHelper.save(service: keychainService, account: keychainTokenAccount, value: trimmed)
        userDefaults.set(trimmed, forKey: authTokenKey)
        userDefaults.synchronize()
    }

    func getAuthToken() -> String? {
        if let keychainToken = KeychainHelper.load(service: keychainService, account: keychainTokenAccount),
           !keychainToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return keychainToken
        }

        if let legacy = userDefaults.string(forKey: authTokenKey)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !legacy.isEmpty {
            _ = KeychainHelper.save(service: keychainService, account: keychainTokenAccount, value: legacy)
            return legacy
        }

        return nil
    }

    func clearAuthToken() {
        KeychainHelper.delete(service: keychainService, account: keychainTokenAccount)
        userDefaults.removeObject(forKey: authTokenKey)
        userDefaults.synchronize()
    }

    // MARK: - Credenciais legadas
    /// Versões anteriores guardavam documento e senha no Keychain para relogin automático.
    /// A senha nunca mais é persistida; este método só remove o que ficou de instalações antigas.
    func clearLoginCredentials() {
        KeychainHelper.delete(service: keychainService, account: keychainLoginDocumentAccount)
        KeychainHelper.delete(service: keychainService, account: keychainLoginPasswordAccount)
    }

    // MARK: - Theme Mode
    func saveThemeMode(_ isDark: Bool) {
        userDefaults.set(isDark, forKey: themeModeKey)
        userDefaults.synchronize()
    }

    /// O app Hard Rock tem tema único (escuro). A preferência antiga é ignorada.
    func getThemeMode() -> Bool {
        true
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
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            userDefaults.removeObject(forKey: userNameKey)
        } else {
            userDefaults.set(trimmed, forKey: userNameKey)
        }
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

    // MARK: - Avisos / Notícias lidos
    private func readNoticeIdsKey(for userId: String) -> String {
        "read_notice_ids_\(userId)"
    }

    private func noticeReadBaselineKey(for userId: String) -> String {
        "notice_read_baseline_\(userId)"
    }

    func getReadNoticeIds() -> Set<String> {
        guard let userId = getUserId() else { return [] }
        let stored = userDefaults.stringArray(forKey: readNoticeIdsKey(for: userId)) ?? []
        return Set(stored)
    }

    func isNoticeRead(_ noticeId: String) -> Bool {
        getReadNoticeIds().contains(noticeId)
    }

    func markNoticeAsRead(_ noticeId: String) {
        guard let userId = getUserId(), !noticeId.isEmpty else { return }
        var ids = getReadNoticeIds()
        guard ids.insert(noticeId).inserted else { return }
        userDefaults.set(Array(ids), forKey: readNoticeIdsKey(for: userId))
        userDefaults.synchronize()
    }

    func markNoticesAsRead(_ noticeIds: [String]) {
        guard let userId = getUserId(), !noticeIds.isEmpty else { return }
        var ids = getReadNoticeIds()
        noticeIds.forEach { ids.insert($0) }
        userDefaults.set(Array(ids), forKey: readNoticeIdsKey(for: userId))
        userDefaults.synchronize()
    }

    /// Na primeira sessão, marca o que já existe como lido para só contar novidades depois.
    func establishNoticeReadBaselineIfNeeded(noticeIds: [String]) {
        guard let userId = getUserId() else { return }
        let baselineKey = noticeReadBaselineKey(for: userId)
        guard !userDefaults.bool(forKey: baselineKey) else { return }
        markNoticesAsRead(noticeIds)
        userDefaults.set(true, forKey: baselineKey)
        userDefaults.synchronize()
    }

    func clearNoticeReadState() {
        guard let userId = getUserId() else { return }
        userDefaults.removeObject(forKey: readNoticeIdsKey(for: userId))
        userDefaults.removeObject(forKey: noticeReadBaselineKey(for: userId))
        userDefaults.synchronize()
    }

    // MARK: - Boletos vistos (Segunda Via — A Vencer / Vencidas)
    private func readBoletoIdsKey(for userId: String) -> String {
        "read_boleto_ids_\(userId)"
    }

    private func boletoReadBaselineKey(for userId: String) -> String {
        "boleto_read_baseline_\(userId)"
    }

    func getReadBoletoIds() -> Set<String> {
        guard let userId = getUserId() else { return [] }
        let stored = userDefaults.stringArray(forKey: readBoletoIdsKey(for: userId)) ?? []
        return Set(stored)
    }

    func isBoletoRead(_ boletoId: String) -> Bool {
        getReadBoletoIds().contains(boletoId)
    }

    func markBoletoAsRead(_ boletoId: String) {
        guard let userId = getUserId(), !boletoId.isEmpty else { return }
        var ids = getReadBoletoIds()
        guard ids.insert(boletoId).inserted else { return }
        userDefaults.set(Array(ids), forKey: readBoletoIdsKey(for: userId))
        userDefaults.synchronize()
    }

    func markBoletosAsRead(_ boletoIds: [String]) {
        guard let userId = getUserId(), !boletoIds.isEmpty else { return }
        var ids = getReadBoletoIds()
        boletoIds.forEach { ids.insert($0) }
        userDefaults.set(Array(ids), forKey: readBoletoIdsKey(for: userId))
        userDefaults.synchronize()
    }

    func establishBoletoReadBaselineIfNeeded(boletoIds: [String]) {
        guard let userId = getUserId() else { return }
        let baselineKey = boletoReadBaselineKey(for: userId)
        guard !userDefaults.bool(forKey: baselineKey) else { return }
        markBoletosAsRead(boletoIds)
        userDefaults.set(true, forKey: baselineKey)
        userDefaults.synchronize()
    }

    func clearBoletoReadState() {
        guard let userId = getUserId() else { return }
        userDefaults.removeObject(forKey: readBoletoIdsKey(for: userId))
        userDefaults.removeObject(forKey: boletoReadBaselineKey(for: userId))
        userDefaults.synchronize()
    }

    // MARK: - Utility Methods
    func clearAllData() {
        clearNoticeReadState()
        clearBoletoReadState()
        clearAuthToken()
        clearLoginCredentials()
        let keys = [themeModeKey, userIdKey, userNameKey, userCpfCnpjKey, notificationsEnabledKey]
        keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
    }

    func hasValidSession() -> Bool {
        guard let token = getAuthToken() else { return false }
        return !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}