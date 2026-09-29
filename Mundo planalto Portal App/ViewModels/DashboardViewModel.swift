//
//  DashboardViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var clientInfo: ClientInfo?
    @Published var financialSummary: FinancialSummary?
    @Published var isLoadingFinancial = false
    @Published var mainVenture: Venture?
    @Published var notices: [Notice] = []
    @Published var isLoading = false
    @Published var error: String?

    private let menuItems: [MenuItem] = [
        MenuItem(title: "Meus Empreendimentos",
                subtitle: "Acompanhe suas obras",
                iconName: "building.2.fill",
                destination: .ventures),
        MenuItem(title: "Extrato Financeiro",
                subtitle: "Veja seu histórico",
                iconName: "doc.text.fill",
                destination: .financial),
        MenuItem(title: "Avisos e Notícias",
                subtitle: "Fique informado",
                iconName: "bell.fill",
                destination: .notices),
        MenuItem(title: "Meu Perfil",
                subtitle: "Gerencie seus dados",
                iconName: "person.fill",
                destination: .profile)
    ]

    var greeting: String {
        guard let name = clientInfo?.name else { return "Olá!" }
        return "Olá, \(name)"
    }

    var menuItemsList: [MenuItem] {
        menuItems
    }

    /// Carrega dashboard e resumo financeiro (await para pull-to-refresh).
    func loadDashboardData(forceRefresh: Bool = false) async {
        error = nil
        if clientInfo == nil, let name = PreferencesManager.shared.getUserName() {
            clientInfo = ClientInfo(name: name, totalVentures: 0)
        }
        if forceRefresh {
            await refreshFinancialOverview()
            await loadCustomerDashboard()
        } else {
            async let dashboard: Void = loadCustomerDashboard()
            await loadFinancialSummary(forceRefresh: false)
            await dashboard
        }
    }

    /// Chamado pelo pull-to-refresh do dashboard — atualiza só o resumo financeiro com loading visível.
    func refreshFinancialOverview() async {
        await loadFinancialSummary(forceRefresh: true)
    }

    private func loadCustomerDashboard() async {
        do {
            let result = try await DashboardService.shared.getCustomerDashboard()
            clientInfo = result.clientInfo
            notices = result.notices
            mainVenture = nil
        } catch {
            self.error = AppErrorMapper.userMessage(
                for: error,
                fallback: "Erro ao carregar dados do dashboard"
            )
            loadDashboardFallback()
        }
    }

    /// Carrega o resumo financeiro da rota /api/financial/resumo.
    func loadFinancialSummary(forceRefresh: Bool = false) async {
        if isLoadingFinancial && !forceRefresh { return }
        isLoadingFinancial = true
        let started = Date()
        do {
            let summary = try await ExtratoService.shared.getFinancialSummary(
                useCache: !forceRefresh,
                forceRefresh: forceRefresh,
                cacheTTL: 5 * 60
            )
            financialSummary = summary
            await AppState.shared.refreshUnreadBoletoCounts()
        } catch {
            if financialSummary == nil {
                financialSummary = FinancialSummary(
                    overdueAmount: 0,
                    upcomingAmount: 0,
                    overdueInstallments: 0,
                    totalAmount: 0,
                    nextDueDate: nil,
                    nextDueValue: 0
                )
            }
        }
        if forceRefresh {
            let elapsed = Date().timeIntervalSince(started)
            let minimumVisible: TimeInterval = 0.4
            if elapsed < minimumVisible {
                try? await Task.sleep(nanoseconds: UInt64((minimumVisible - elapsed) * 1_000_000_000))
            }
        }
        isLoadingFinancial = false
    }

    private func loadDashboardFallback() {
        clientInfo = ClientInfo(name: PreferencesManager.shared.getUserName() ?? "Cliente", totalVentures: 0)
        financialSummary = FinancialSummary(
            overdueAmount: 0,
            upcomingAmount: 0,
            overdueInstallments: 0,
            totalAmount: 0,
            nextDueDate: nil,
            nextDueValue: 0
        )
        mainVenture = nil
        notices = []
    }
}