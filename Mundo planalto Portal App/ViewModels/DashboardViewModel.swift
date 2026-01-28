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
            // Simular carregamento de dados da API
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo

            // Dados mockados
            clientInfo = ClientInfo(name: "João Silva", totalVentures: 3)

            financialSummary = FinancialSummary(
                overdueAmount: 2500.50,
                upcomingAmount: 1800.75,
                overdueInstallments: 2,
                totalAmount: 15750.25
            )

            mainVenture = Venture(
                id: "1",
                name: "Residencial Parque das Flores",
                imageUrl: "venture1",
                progress: 0.75,
                lastUpdate: "Atualizado há 2 dias"
            )

            notices = [
                Notice(id: "1",
                      title: "Reunião de Condôminos",
                      description: "Reunião marcada para o dia 15/02 às 19h",
                      date: "10/01/2025",
                      type: .notice),
                Notice(id: "2",
                      title: "Nova Fase da Obra",
                      description: "Iniciamos a construção da torre norte",
                      date: "08/01/2025",
                      type: .news),
                Notice(id: "3",
                      title: "Manutenção Programada",
                      description: "Sistema elétrico será atualizado",
                      date: "05/01/2025",
                      type: .notice)
            ]

        } catch {
            self.error = "Erro ao carregar dados do dashboard"
        }

        isLoading = false
    }
}