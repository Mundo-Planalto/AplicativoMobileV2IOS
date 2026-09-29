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
        // Verificar se há token válido salvo
        isLoggedIn = preferencesManager.hasValidSession()
        if isLoggedIn {
            Task { await refreshAllUnreadBadges() }
        }
    }

    func login() {
        // Token e CPF já foram salvos pelo LoginViewModel após login com sucesso na API
        isLoggedIn = true
        Task { await refreshAllUnreadBadges() }
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