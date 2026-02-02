//
//  ExtratoViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

enum ExtratoFilter: String, CaseIterable {
    case todas = "Todas"
    case aVencer = "A Vencer"
    case pagas = "Pagas"
    case vencidas = "Vencidas"

    var status: PaymentStatus? {
        switch self {
        case .todas: return nil
        case .aVencer: return .upcoming
        case .pagas: return .paid
        case .vencidas: return .overdue
        }
    }
}

@MainActor
class ExtratoViewModel: ObservableObject {
    @Published var allItems: [FinancialStatementItem] = []
    @Published var filteredItems: [FinancialStatementItem] = []
    @Published var selectedFilter: ExtratoFilter = .todas
    @Published var isLoading = false
    @Published var error: String?

    var filterOptions: [ExtratoFilter] {
        ExtratoFilter.allCases
    }

    var selectedFilterText: String {
        selectedFilter.rawValue
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
                    parcela: "1/24",
                    dueDate: "15/01/2025",
                    amount: 1250.00,
                    status: .paid
                ),
                FinancialStatementItem(
                    id: "2",
                    ventureName: "Residencial Parque das Flores",
                    installmentNumber: "2/24",
                    parcela: "2/24",
                    dueDate: "15/02/2025",
                    amount: 1250.00,
                    status: .upcoming
                ),
                FinancialStatementItem(
                    id: "3",
                    ventureName: "Condomínio Vista Verde",
                    installmentNumber: "1/36",
                    parcela: "1/36",
                    dueDate: "10/12/2024",
                    amount: 890.50,
                    status: .overdue
                ),
                FinancialStatementItem(
                    id: "4",
                    ventureName: "Condomínio Vista Verde",
                    installmentNumber: "2/36",
                    parcela: "2/36",
                    dueDate: "10/01/2025",
                    amount: 890.50,
                    status: .paid
                ),
                FinancialStatementItem(
                    id: "5",
                    ventureName: "Edifício Central Plaza",
                    installmentNumber: "1/48",
                    parcela: "1/48",
                    dueDate: "20/03/2025",
                    amount: 2100.75,
                    status: .upcoming
                ),
                FinancialStatementItem(
                    id: "6",
                    ventureName: "Edifício Central Plaza",
                    installmentNumber: "2/48",
                    parcela: "2/48",
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

    func setFilter(_ filter: ExtratoFilter) {
        selectedFilter = filter
        applyFilter()
    }

    private func applyFilter() {
        if let status = selectedFilter.status {
            filteredItems = allItems.filter { $0.status == status }
        } else {
            filteredItems = allItems
        }
    }
}