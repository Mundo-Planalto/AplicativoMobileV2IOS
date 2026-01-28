//
//  EmpreendimentosViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class EmpreendimentosViewModel: ObservableObject {
    @Published var ventures: [Venture] = []
    @Published var isLoading = false
    @Published var error: String?

    func loadVentures() async {
        isLoading = true
        error = nil

        do {
            // Simular carregamento de dados da API
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo

            // Dados mockados
            ventures = [
                Venture(
                    id: "1",
                    name: "Residencial Parque das Flores",
                    imageUrl: "building.2.fill",
                    progress: 0.75,
                    lastUpdate: "Atualizado há 2 dias"
                ),
                Venture(
                    id: "2",
                    name: "Condomínio Vista Verde",
                    imageUrl: "building.2.fill",
                    progress: 0.45,
                    lastUpdate: "Atualizado há 1 semana"
                ),
                Venture(
                    id: "3",
                    name: "Edifício Central Plaza",
                    imageUrl: "building.2.fill",
                    progress: 0.90,
                    lastUpdate: "Atualizado ontem"
                )
            ]

        } catch {
            self.error = "Erro ao carregar empreendimentos"
        }

        isLoading = false
    }
}