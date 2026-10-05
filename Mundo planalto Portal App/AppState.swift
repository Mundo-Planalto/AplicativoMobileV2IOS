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
    /// Preenchido quando a sessão foi encerrada por token inválido; o Login mostra e limpa.
    @Published var sessionExpiredMessage: String?
    @Published var unreadNoticeCount = 0
    @Published var unreadUpcomingBoletoCount = 0
    @Published var unreadOverdueBoletoCount = 0

    var unreadBoletoCount: Int { unreadUpcomingBoletoCount + unreadOverdueBoletoCount }

    static let shared = AppState()
    private let preferencesManager = PreferencesManager.shared

    private init() {
        // Inicializa sem verificar para evitar problemas
        isLoggedIn = false
    }

    func checkInitialLoginState() {
        #if !DEBUG
        // Um token de demonstração deixado por um build de teste no mesmo aparelho não vale em Release.
        if preferencesManager.getAuthToken() == AppConfig.demoToken { preferencesManager.clearAllData() }
        #endif
        // Verificar se há token válido salvo
        isLoggedIn = preferencesManager.hasValidSession()
        if isLoggedIn {
            Task {
                await refreshUserNameIfNeeded()
                await refreshAllUnreadBadges()
            }
        }
    }

    func login() {
        // Token e CPF já foram salvos pelo LoginViewModel após login com sucesso na API
        sessionExpiredMessage = nil
        isLoggedIn = true
        Task {
            await refreshUserNameIfNeeded()
            await refreshAllUnreadBadges()
        }
    }

    /// Nome exibido nos headers e no cartão. Se o login não trouxe `user.name`,
    /// busca em GET auth/me + customers/data. Nunca usa o nome do usuário de demonstração.
    @MainActor
    func refreshUserNameIfNeeded() async {
        guard isLoggedIn, !isDemoSession else { return }
        let saved = preferencesManager.getUserName()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if saved.isEmpty || saved == MemberInfo.demo.nome {
            preferencesManager.saveUserName("")
            if let profile = try? await ProfileService.shared.getProfile().profile,
               !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                preferencesManager.saveUserName(profile.name)
                objectWillChange.send()
            }
        }
    }

    #if DEBUG
    /// "Acessar demonstração": grava o token DEMO-HRVC e o usuário fictício, sem chamar a API.
    /// Só existe em builds Debug; em Release o código nem é compilado.
    func loginDemo() {
        let demo = MemberInfo.demo
        preferencesManager.saveAuthToken(AppConfig.demoToken)
        preferencesManager.saveUserId("demo")
        preferencesManager.saveUserName(demo.nome)
        preferencesManager.saveUserCpfCnpj("")
        sessionExpiredMessage = nil
        isLoggedIn = true
    }
    #endif

    /// Sessão de demonstração (token DEMO-HRVC no Keychain). Em Release é sempre `false`.
    var isDemoSession: Bool {
        #if DEBUG
        return preferencesManager.getAuthToken() == AppConfig.demoToken
        #else
        return false
        #endif
    }

    /// Dados do membro para cartão e headers. Sem a API nova (GET members/me/card),
    /// usa o usuário de demonstração ou o nome salvo no login real.
    var currentMember: MemberInfo {
        if isDemoSession { return MemberInfo.demo }
        let demo = MemberInfo.demo
        let savedName = preferencesManager.getUserName() ?? ""
        return MemberInfo(
            nome: savedName == demo.nome ? "" : savedName,
            numeroMembro: demo.numeroMembro,
            nivel: demo.nivel,
            desde: demo.desde,
            verifyUrl: demo.verifyUrl
        )
    }

    /// Primeiro nome para os headers ("ROBSON SILVA" → "Robson").
    var firstName: String {
        HrNames.firstName(from: preferencesManager.getUserName())
    }

    func logout() async {
        if !isDemoSession {
            do {
                _ = try await AuthService.shared.logout()
            } catch {
                // Mesmo se falhar, continua com o logout local
                print("Erro ao fazer logout remoto: \(error)")
            }
        }
        clearLocalSession()
    }

    /// Token confirmado como inválido pela API (401 persistente): encerra a sessão e avisa no Login.
    /// É o único caminho, além de "Sair", que leva de volta ao Login.
    func handleSessionExpired() {
        guard isLoggedIn, !isDemoSession else { return }
        clearLocalSession()
        sessionExpiredMessage = AppConfig.sessionExpiredMessage
    }

    private func clearLocalSession() {
        preferencesManager.clearAllData()
        unreadNoticeCount = 0
        unreadUpcomingBoletoCount = 0
        unreadOverdueBoletoCount = 0
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
        objectWillChange.send()
    }

    // MARK: - Badge de avisos não lidos (tab Notícias)
    func refreshUnreadNoticeCount() async {
        guard isLoggedIn else {
            unreadNoticeCount = 0
            return
        }
        do {
            let notices = try await NewsService.shared.getAnnouncements()
            let ids = notices.map(\.id)
            preferencesManager.establishNoticeReadBaselineIfNeeded(noticeIds: ids)
            let readIds = preferencesManager.getReadNoticeIds()
            unreadNoticeCount = notices.filter { !readIds.contains($0.id) }.count
        } catch {
            #if DEBUG
            print("[AppState] Falha ao atualizar badge de notícias: \(error.localizedDescription)")
            #endif
        }
    }

    func markNoticeAsRead(_ noticeId: String) {
        guard !noticeId.isEmpty else { return }
        let wasUnread = !preferencesManager.isNoticeRead(noticeId)
        preferencesManager.markNoticeAsRead(noticeId)
        if wasUnread {
            unreadNoticeCount = max(0, unreadNoticeCount - 1)
        }
    }

    func isNoticeUnread(_ noticeId: String) -> Bool {
        !preferencesManager.isNoticeRead(noticeId)
    }

    func refreshAllUnreadBadges() async {
        await refreshUnreadNoticeCount()
        await refreshUnreadBoletoCounts()
    }

    // MARK: - Badge de boletos não vistos (Segunda Via)
    func refreshUnreadBoletoCounts(from items: [FinancialStatementItem]? = nil) async {
        guard isLoggedIn else {
            unreadUpcomingBoletoCount = 0
            unreadOverdueBoletoCount = 0
            return
        }
        let list: [FinancialStatementItem]
        if let items {
            list = items
        } else {
            do {
                list = try await ExtratoService.shared.getExtrato(
                    showPaid: true,
                    showOverdue: true,
                    showDue: true,
                    useCache: true,
                    forceRefresh: false
                )
            } catch {
                #if DEBUG
                print("[AppState] Falha ao atualizar badge de boletos: \(error.localizedDescription)")
                #endif
                return
            }
        }
        let upcoming = Self.upcomingBoletoItems(from: list)
        let overdue = Self.overdueBoletoItems(from: list)
        let eligibleIds = (upcoming + overdue).map(\.id)
        preferencesManager.establishBoletoReadBaselineIfNeeded(boletoIds: eligibleIds)
        updateBoletoUnreadCounts(from: list)
    }

    func markBoletoAsRead(_ item: FinancialStatementItem) {
        let wasUpcoming = item.status == .upcoming && item.generatedBillet == true
        let wasOverdue = item.status == .overdue
        guard wasUpcoming || wasOverdue else { return }
        let wasUnread = !preferencesManager.isBoletoRead(item.id)
        preferencesManager.markBoletoAsRead(item.id)
        guard wasUnread else { return }
        if wasUpcoming {
            unreadUpcomingBoletoCount = max(0, unreadUpcomingBoletoCount - 1)
        }
        if wasOverdue {
            unreadOverdueBoletoCount = max(0, unreadOverdueBoletoCount - 1)
        }
    }

    func markBoletoTabAsSeen(_ filter: ExtratoFilter, items: [FinancialStatementItem]) {
        let ids: [String]
        switch filter {
        case .aVencer:
            ids = Self.upcomingBoletoItems(from: items).map(\.id)
        case .vencidas:
            ids = Self.overdueBoletoItems(from: items).map(\.id)
        default:
            return
        }
        guard !ids.isEmpty else { return }
        preferencesManager.markBoletosAsRead(ids)
        updateBoletoUnreadCounts(from: items)
    }

    func isBoletoUnread(_ boletoId: String) -> Bool {
        !preferencesManager.isBoletoRead(boletoId)
    }

    func unreadBoletoCount(for filter: ExtratoFilter) -> Int {
        switch filter {
        case .aVencer: return unreadUpcomingBoletoCount
        case .vencidas: return unreadOverdueBoletoCount
        default: return 0
        }
    }

    private func updateBoletoUnreadCounts(from items: [FinancialStatementItem]) {
        let readIds = preferencesManager.getReadBoletoIds()
        unreadUpcomingBoletoCount = Self.upcomingBoletoItems(from: items)
            .filter { !readIds.contains($0.id) }
            .count
        unreadOverdueBoletoCount = Self.overdueBoletoItems(from: items)
            .filter { !readIds.contains($0.id) }
            .count
    }

    private static func upcomingBoletoItems(from items: [FinancialStatementItem]) -> [FinancialStatementItem] {
        items.filter { $0.status == .upcoming && $0.generatedBillet == true }
    }

    private static func overdueBoletoItems(from items: [FinancialStatementItem]) -> [FinancialStatementItem] {
        items.filter { $0.status == .overdue }
    }
}

extension Notification.Name {
    static let noticeUnreadCountShouldRefresh = Notification.Name("NoticeUnreadCountShouldRefresh")
}