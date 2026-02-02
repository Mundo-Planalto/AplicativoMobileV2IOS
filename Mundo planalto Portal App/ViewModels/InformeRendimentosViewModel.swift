//
//  InformeRendimentosViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
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
    @Published var pdfUrl: String?

    init() {
        loadAvailableYears()
    }

    private func loadAvailableYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        availableYears = (2020...currentYear).reversed().map { String($0) }
        selectedYear = String(currentYear) // Ano atual como padrão
    }

    func generateReport() async {
        guard !selectedYear.isEmpty else {
            error = "Selecione um ano para gerar o informe"
            return
        }

        isLoading = true
        error = nil
        pdfUrl = nil

        do {
            // Simular geração do informe via API
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos

            // Simular URL do PDF gerado
            pdfUrl = "https://example.com/informe-\(selectedYear).pdf"

            // Em produção, aqui seria a navegação para IncomeTaxReportView
            print("Informe gerado para o ano \(selectedYear)")
            print("PDF URL: \(pdfUrl!)")

        } catch {
            self.error = "Erro ao gerar informe de rendimentos"
        }

        isLoading = false
    }
}