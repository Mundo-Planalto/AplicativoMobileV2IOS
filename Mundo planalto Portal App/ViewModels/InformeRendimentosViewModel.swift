//
//  InformeRendimentosViewModel.swift
//  Mundo planalto Portal App
//
//  Usa GET /api/incometax/years e POST /api/incometax/generate/{year}.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class InformeRendimentosViewModel: ObservableObject {
    @Published var selectedYear: String = ""
    @Published var availableYears: [String] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var statusMessage: String?
    @Published var generatedData: InformeRendimentosData?

    init() {
        loadAvailableYears()
    }

    func loadAvailableYears() {
        Task {
            do {
                let years = try await IncomeTaxService.shared.getAvailableYears()
                availableYears = years.sorted(by: >).map { String($0) }
                if selectedYear.isEmpty, let first = availableYears.first {
                    selectedYear = first
                }
                updateStatusMessage()
            } catch {
                let currentYear = Calendar.current.component(.year, from: Date())
                availableYears = (2018...currentYear).reversed().map { String($0) }
                if selectedYear.isEmpty { selectedYear = String(currentYear) }
                updateStatusMessage()
            }
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
            self.error = "Erro ao gerar informe. Tente novamente."
        }

        isLoading = false
    }
}
