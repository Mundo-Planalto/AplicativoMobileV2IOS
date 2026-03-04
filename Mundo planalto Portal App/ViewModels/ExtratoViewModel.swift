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

    /// Abas exibidas na barra (sem "Todas")
    static var tabCases: [ExtratoFilter] { [.aVencer, .pagas, .vencidas] }
}

enum FiltroEmpreendimento: String, CaseIterable {
    case todos = "Todos os empreendimentos"
    case hardRock = "Hard Rock Hotel Gramado"
}

enum FiltroPeriodo: String, CaseIterable {
    case todos = "Todos os períodos"
    case ultimos30 = "Últimos 30 dias"
    case ultimos90 = "Últimos 90 dias"
    case ultimos6Meses = "Últimos 6 meses"
    case ultimoAno = "Último ano"
}

@MainActor
class ExtratoViewModel: ObservableObject {
    @Published var allItems: [FinancialStatementItem] = []
    @Published var filteredItems: [FinancialStatementItem] = []
    @Published var selectedFilter: ExtratoFilter = .aVencer
    @Published var isLoading = false
    @Published var error: String?
    @Published var showFilterModal = false
    @Published var filtroEmpreendimento: FiltroEmpreendimento = .todos
    @Published var filtroPeriodo: FiltroPeriodo = .todos

    var tabOptions: [ExtratoFilter] { ExtratoFilter.tabCases }

    var selectedFilterText: String {
        selectedFilter.rawValue
    }

    func loadFinancialStatement() async {
        isLoading = true
        error = nil
        do {
            let items = try await ExtratoService.shared.getExtrato(showPaid: true, showOverdue: true, showDue: true)
            allItems = items
            applyFilter()
        } catch {
            self.error = "Erro ao carregar extrato financeiro"
            loadFinancialStatementFallback()
        }
        isLoading = false
    }

    private func loadFinancialStatementFallback() {
        let currentYear = Calendar.current.component(.year, from: Date())
        allItems = [
            FinancialStatementItem(id: "1", ventureName: "Residencial Parque das Flores", installmentNumber: "1/24", parcela: "1/24", dueDate: "15/01/\(currentYear)", amount: 1250.00, status: .paid, generatedBillet: true),
            FinancialStatementItem(id: "2", ventureName: "Residencial Parque das Flores", installmentNumber: "2/24", parcela: "2/24", dueDate: "15/02/\(currentYear)", amount: 1250.00, status: .upcoming, generatedBillet: true),
        ]
        applyFilter()
    }

    func setFilter(_ filter: ExtratoFilter) {
        selectedFilter = filter
        applyFilter()
    }

    func applyFiltersFromModal() {
        showFilterModal = false
        applyFilter()
    }

    private func applyFilter() {
        var items = allItems
        // 1) Somente registros com boleto gerado
        items = items.filter { $0.generatedBillet == true }
        // 2) Aba selecionada: A Vencer / Pagas / Vencidas
        if let status = selectedFilter.status {
            items = items.filter { $0.status == status }
        }
        // 3) Filtro de empreendimento (modal)
        if filtroEmpreendimento == .hardRock {
            items = items.filter { $0.ventureName.contains("Hard Rock") || $0.ventureName.contains("Gramado") }
        }
        // 4) Filtro de período (modal): vencimento dentro do intervalo (últimos X dias/meses/ano até hoje)
        if filtroPeriodo != .todos {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let endDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
            let startDate: Date? = {
                switch filtroPeriodo {
                case .todos: return nil
                case .ultimos30: return calendar.date(byAdding: .day, value: -30, to: today)
                case .ultimos90: return calendar.date(byAdding: .day, value: -90, to: today)
                case .ultimos6Meses: return calendar.date(byAdding: .month, value: -6, to: today)
                case .ultimoAno: return calendar.date(byAdding: .year, value: -1, to: today)
                }
            }()
            if let start = startDate {
                items = items.filter { item in
                    guard let due = parseDueDate(item.dueDate) else { return true }
                    let dueStart = calendar.startOfDay(for: due)
                    return dueStart >= start && dueStart < endDate
                }
            }
        }
        filteredItems = items
    }

    /// Converte string de vencimento (dd/MM/yyyy ou yyyy-MM-dd) em Date.
    private func parseDueDate(_ dueDate: String) -> Date? {
        let trimmed = dueDate.trimmingCharacters(in: .whitespaces)
        let fmtBr = DateFormatter()
        fmtBr.dateFormat = "dd/MM/yyyy"
        fmtBr.locale = Locale(identifier: "pt_BR")
        if let d = fmtBr.date(from: trimmed) { return d }
        let fmtIso = DateFormatter()
        fmtIso.dateFormat = "yyyy-MM-dd"
        fmtIso.locale = Locale(identifier: "en_US_POSIX")
        return fmtIso.date(from: trimmed)
    }
}