//
//  InformeRendimentosViewModel.swift
//  Mundo planalto Portal App
//
//  Anos: união do extrato (dueDate + data de pagamento) com GET incometax/years (anos que o backend permite gerar).
//  POST /api/incometax/generate/{year} para gerar o informe.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class InformeRendimentosViewModel: ObservableObject {
    @Published var selectedYear: String = ""
    @Published var availableYears: [String] = []
    /// Inicia true para a primeira pintura já mostrar loading até `loadAvailableYears` terminar.
    @Published var isLoadingYears = true
    @Published var isLoading = false
    @Published var error: String?
    @Published var statusMessage: String?
    @Published var generatedData: InformeRendimentosData?

    /// Carrega anos: extrato (dueDate + pagamento) e API incometax/years. Se o POST `financial/refresh` falhar, tenta extrato sem refresh.
    func loadAvailableYears(forceRefresh: Bool = true) async {
        if AppState.shared.isDemoSession {
            availableYears = ["2025", "2026"]
            if selectedYear.isEmpty { selectedYear = "2026" }
            isLoadingYears = false
            statusMessage = "Na demonstração o informe não é gerado. Entre com sua conta para emitir o documento."
            return
        }
        isLoadingYears = true
        defer { isLoadingYears = false }

        var yearSet = Set<Int>()
        var extratoLastError: Error?

        let attempts: [(forceRefresh: Bool, useCache: Bool)] = forceRefresh
            ? [(true, false), (false, true)]
            : [(false, true)]

        for attempt in attempts {
            do {
                let items = try await ExtratoService.shared.getExtrato(
                    showPaid: true,
                    showOverdue: true,
                    showDue: true,
                    useCache: attempt.useCache,
                    forceRefresh: attempt.forceRefresh
                )
                yearSet.formUnion(InformeExtratoYears.distinctYears(from: items))
                extratoLastError = nil
            } catch {
                extratoLastError = error
            }
        }

        if let apiYears = try? await IncomeTaxService.shared.getAvailableYears() {
            yearSet.formUnion(apiYears)
        }

        let currentYear = Calendar.current.component(.year, from: Date())
        availableYears = yearSet
            .filter { $0 <= currentYear }
            .sorted(by: >)
            .map { String($0) }
        applySelectionAfterYearsLoad()

        if availableYears.isEmpty {
            selectedYear = ""
            statusMessage = nil
            if let e = extratoLastError {
                self.error = AppErrorMapper.userMessage(
                    for: e,
                    fallback: "Não foi possível obter anos para o informe. Confira sua conexão e o extrato financeiro."
                )
            } else {
                self.error = "Não encontramos anos com dados para o informe. Verifique se há movimentação no extrato ou tente novamente mais tarde."
            }
        } else {
            self.error = nil
            updateStatusMessage()
        }
    }

    private func applySelectionAfterYearsLoad() {
        if selectedYear.isEmpty, let first = availableYears.first {
            selectedYear = first
        } else if !availableYears.contains(selectedYear), let first = availableYears.first {
            selectedYear = first
        }
    }

    func selectYear(_ year: String) {
        selectedYear = year
        error = nil
        updateStatusMessage()
    }

    private func updateStatusMessage() {
        guard !selectedYear.isEmpty else {
            statusMessage = nil
            return
        }
        statusMessage = "Informe pronto para geração"
    }

    func generateReport() async {
        if AppState.shared.isDemoSession {
            statusMessage = "Na demonstração o informe não é gerado. Entre com sua conta para emitir o documento."
            return
        }
        guard !selectedYear.isEmpty, let yearInt = Int(selectedYear) else {
            error = "Selecione um ano para gerar o informe"
            return
        }

        isLoading = true
        error = nil
        generatedData = nil

        do {
            let data = try await IncomeTaxService.shared.generateReport(year: yearInt)
            generatedData = data
            self.error = nil
        } catch IncomeTaxError.noData {
            generatedData = nil
            self.error = "Não foram encontrados pagamentos realizados no ano de \(selectedYear). Tente selecionar outro ano ou verifique se há pagamentos registrados."
        } catch {
            generatedData = nil
            self.error = AppErrorMapper.userMessage(
                for: error,
                fallback: "Erro ao gerar informe. Tente novamente."
            )
        }

        isLoading = false
    }
}

// MARK: - Anos a partir do extrato (somente fluxo Informe)

private enum InformeExtratoYears {
    /// Cada linha do extrato: anos do **vencimento** (`dueDate`) e da **data de pagamento/baixa** (`paymentDate`).
    static func distinctYears(from items: [FinancialStatementItem]) -> [Int] {
        var years = Set<Int>()
        for item in items {
            let due = item.dueDate.trimmingCharacters(in: .whitespacesAndNewlines)
            if !due.isEmpty, let y = calendarYearLenient(from: due) {
                years.insert(y)
            }
            if let pd = item.paymentDate?.trimmingCharacters(in: .whitespacesAndNewlines), !pd.isEmpty,
               let y = calendarYearLenient(from: pd) {
                years.insert(y)
            }
        }
        return years.sorted(by: >)
    }

    /// Preferência por parse estruturado; depois qualquer ano 19xx/20xx na string (datas mal formatadas da API).
    static func calendarYearLenient(from raw: String) -> Int? {
        if let y = calendarYear(from: raw) { return y }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let regex = try? NSRegularExpression(pattern: #"(19|20)\d{2}"#, options: []) else { return nil }
        let range = NSRange(location: 0, length: (trimmed as NSString).length)
        let matches = regex.matches(in: trimmed, options: [], range: range)
        let years = matches.compactMap { m -> Int? in
            guard let r = Range(m.range, in: trimmed) else { return nil }
            return Int(trimmed[r])
        }
        guard !years.isEmpty else { return nil }
        return years.max()
    }

    /// Extrai o ano calendário priorizando literais (sem timezone). Fallback só para ISO completo em UTC.
    static func calendarYear(from raw: String) -> Int? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let beforeT = trimmed.split(separator: "T", maxSplits: 1, omittingEmptySubsequences: false)
            .first
            .map(String.init) ?? trimmed

        let headToken = beforeT.split(whereSeparator: { $0.isWhitespace }).first.map(String.init) ?? beforeT

        if headToken.range(of: #"^\d{4}-\d{2}-\d{2}"#, options: .regularExpression) != nil {
            return Int(headToken.prefix(4))
        }

        if beforeT.range(of: #"^\d{4}/\d{2}/\d{2}$"#, options: .regularExpression) != nil {
            return Int(beforeT.prefix(4))
        }

        // dd/MM/yyyy ou d/M/yyyy (último grupo = ano com 4 dígitos)
        if beforeT.range(of: #"^\d{1,2}/\d{1,2}/\d{4}$"#, options: .regularExpression) != nil {
            let parts = beforeT.split(separator: "/")
            if parts.count == 3, let y = Int(parts[2]) { return y }
        }

        if beforeT.range(of: #"^\d{1,2}\.\d{1,2}\.\d{4}$"#, options: .regularExpression) != nil {
            let parts = beforeT.split(separator: ".")
            if parts.count == 3, let y = Int(parts[2]) { return y }
        }

        if beforeT.range(of: #"^\d{2}/\d{2}/\d{2}$"#, options: .regularExpression) != nil {
            let parts = beforeT.split(separator: "/")
            if parts.count == 3, let yy = Int(parts[2]) {
                return yy <= 50 ? (2000 + yy) : (1900 + yy)
            }
        }

        if beforeT.range(of: #"^\d{1,2}-\d{1,2}-\d{4}$"#, options: .regularExpression) != nil {
            let parts = beforeT.split(separator: "-")
            if parts.count == 3, let y = Int(parts[2]) { return y }
        }

        // yyyy-MM-dd com mais componentes depois (sem espaço)
        if trimmed.range(of: #"^\d{4}-\d{2}-\d{2}"#, options: .regularExpression) != nil {
            return Int(trimmed.prefix(4))
        }

        // Fallback: ISO completo → ano em UTC (último recurso)
        let isoFrac = ISO8601DateFormatter()
        isoFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoBasic = ISO8601DateFormatter()
        isoBasic.formatOptions = [.withInternetDateTime]
        if let d = isoFrac.date(from: trimmed) ?? isoBasic.date(from: trimmed) {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(secondsFromGMT: 0)!
            return cal.component(.year, from: d)
        }

        return nil
    }
}
