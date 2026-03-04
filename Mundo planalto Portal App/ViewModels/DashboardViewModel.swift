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

    func loadDashboardData() async {
        isLoading = true
        error = nil
        do {
            let result = try await DashboardService.shared.getCustomerDashboard()
            clientInfo = result.clientInfo
            financialSummary = result.financialSummary
            notices = result.notices
            mainVenture = nil
        } catch {
            self.error = "Erro ao carregar dados do dashboard"
            loadDashboardFallback()
        }
        isLoading = false
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