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
    @Published var filtroEmpreendimento: String = "Todos os empreendimentos"
    @Published var filtroPeriodo: FiltroPeriodo = .todos

    private let todosEmpreendimentosLabel = "Todos os empreendimentos"

    var empreendimentoOptions: [String] {
        let names = allItems
            .map { $0.ventureName.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let uniqueSorted = Array(Set(names)).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        return [todosEmpreendimentosLabel] + uniqueSorted
    }

    var tabOptions: [ExtratoFilter] { ExtratoFilter.tabCases }

    var selectedFilterText: String {
        selectedFilter.rawValue
    }

    func loadFinancialStatement(forceRefresh: Bool = false) async {
        isLoading = true
        error = nil
        if AppState.shared.isDemoSession {
            allItems = Self.demoItems()
            applyFilter()
            isLoading = false
            return
        }
        do {
            let items = try await ExtratoService.shared.getExtrato(
                showPaid: true,
                showOverdue: true,
                showDue: true,
                useCache: true,
                forceRefresh: forceRefresh
            )
            allItems = items
            applyFilter()
        } catch ExtratoError.invalidCredentials {
            self.error = "Não foi possível validar sua sessão no momento. Tente novamente em instantes."
            loadFinancialStatementFallback()
        } catch ExtratoError.networkError {
            self.error = "Verifique sua conexão e tente novamente."
            loadFinancialStatementFallback()
        } catch {
            self.error = "Não foi possível carregar o extrato. Tente novamente."
            loadFinancialStatementFallback()
        }
        isLoading = false
    }

    /// Erro de rede/sessão: mantém a lista vazia e mostra a mensagem.
    private func loadFinancialStatementFallback() {
        allItems = []
        applyFilter()
    }

    /// Demonstração: 48 parcelas de R$ 2.480,00 do Hard Rock Hotel Gramado, 28 pagas e 20 a vencer
    /// a partir de 15/10/2026 (coerente com a tela Financeiro de docs/telas.md).
    static func demoItems() -> [FinancialStatementItem] {
        let cal = Calendar(identifier: .gregorian)
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.dateFormat = "dd/MM/yyyy"
        var comps = DateComponents(); comps.year = 2026; comps.month = 10; comps.day = 15
        guard let firstUpcoming = cal.date(from: comps) else { return [] }
        return (1...48).map { n in
            let due = cal.date(byAdding: .month, value: n - 29, to: firstUpcoming) ?? firstUpcoming
            let paid = n <= 28
            let paidDate = paid ? cal.date(byAdding: .day, value: -2, to: due) : nil
            return FinancialStatementItem(
                id: "demo-\(n)",
                ventureName: "Hard Rock Hotel Gramado",
                installmentNumber: "\(n)/48",
                parcela: "\(n)/48",
                dueDate: fmt.string(from: due),
                paymentDate: paidDate.map { fmt.string(from: $0) },
                amount: 2480.00,
                status: paid ? .paid : .upcoming,
                contractNumber: "HRVC-8150",
                generatedBillet: !paid
            )
        }
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
        // Aba selecionada: A Vencer / Pagas / Vencidas
        if let status = selectedFilter.status {
            items = items.filter { $0.status == status }
            // Só em "A Vencer": exibir apenas itens com boleto gerado (generatedBillet == true)
            if selectedFilter == .aVencer {
                items = items.filter { $0.generatedBillet == true }
            }
        }
        // Filtro de empreendimento (modal)
        if filtroEmpreendimento != todosEmpreendimentosLabel {
            let selected = filtroEmpreendimento.trimmingCharacters(in: .whitespacesAndNewlines)
            items = items.filter {
                $0.ventureName.trimmingCharacters(in: .whitespacesAndNewlines)
                    .localizedCaseInsensitiveCompare(selected) == .orderedSame
            }
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