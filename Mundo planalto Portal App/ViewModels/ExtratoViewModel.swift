//
//  ExtratoViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ExtratoViewModel: ObservableObject {
    @Published var allItems: [FinancialStatementItem] = []
    @Published var filteredItems: [FinancialStatementItem] = []
    @Published var selectedFilter: PaymentStatus? = nil
    @Published var isLoading = false
    @Published var error: String?

    var filterOptions: [String] {
        ["Todas", "A Vencer", "Pagas", "Vencidas"]
    }

    var selectedFilterText: String {
        switch selectedFilter {
        case .upcoming: return "A Vencer"
        case .paid: return "Pagas"
        case .overdue: return "Vencidas"
        case nil: return "Todas"
        }
    }

    func loadFinancialStatement() async {
        isLoading = true
        error = nil

        do {
            // Simular carregamento de dados da API
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo

            // Dados mockados
            allItems = [
                FinancialStatementItem(
                    id: "1",
                    ventureName: "Residencial Parque das Flores",
                    installmentNumber: "1/24",
                    dueDate: "15/01/2025",
                    amount: 1250.00,
                    status: .paid
                ),
                FinancialStatementItem(
                    id: "2",
                    ventureName: "Residencial Parque das Flores",
                    installmentNumber: "2/24",
                    dueDate: "15/02/2025",
                    amount: 1250.00,
                    status: .upcoming
                ),
                FinancialStatementItem(
                    id: "3",
                    ventureName: "Condomínio Vista Verde",
                    installmentNumber: "1/36",
                    dueDate: "10/12/2024",
                    amount: 890.50,
                    status: .overdue
                ),
                FinancialStatementItem(
                    id: "4",
                    ventureName: "Condomínio Vista Verde",
                    installmentNumber: "2/36",
                    dueDate: "10/01/2025",
                    amount: 890.50,
                    status: .paid
                ),
                FinancialStatementItem(
                    id: "5",
                    ventureName: "Edifício Central Plaza",
                    installmentNumber: "1/48",
                    dueDate: "20/03/2025",
                    amount: 2100.75,
                    status: .upcoming
                ),
                FinancialStatementItem(
                    id: "6",
                    ventureName: "Edifício Central Plaza",
                    installmentNumber: "2/48",
                    dueDate: "20/02/2025",
                    amount: 2100.75,
                    status: .overdue
                )
            ]

            applyFilter()

        } catch {
            self.error = "Erro ao carregar extrato financeiro"
        }

        isLoading = false
    }

    func setFilter(_ filterText: String) {
        switch filterText {
        case "Todas":
            selectedFilter = nil
        case "A Vencer":
            selectedFilter = .upcoming
        case "Pagas":
            selectedFilter = .paid
        case "Vencidas":
            selectedFilter = .overdue
        default:
            selectedFilter = nil
        }
        applyFilter()
    }

    private func applyFilter() {
        if let filter = selectedFilter {
            filteredItems = allItems.filter { $0.status == filter }
        } else {
            filteredItems = allItems
        }
    }
}