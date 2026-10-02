//
//  DetalhesObraViewModel.swift
//  Mundo Planalto
//
//  Atualizações da obra (vídeos, fotos e descrição) de um empreendimento.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DetalhesObraViewModel: ObservableObject {
    @Published var venture: Venture
    @Published var updates: [VentureUpdate] = []
    @Published var isLoading = false
    @Published var error: String?

    init(venture: Venture) {
        self.venture = venture
    }

    func loadVentureDetails() async {
        isLoading = updates.isEmpty
        error = nil
        do {
            updates = try await RepositoryProvider.ventures.updates(venture: venture)
        } catch {
            self.error = AppErrorMapper.userMessage(for: error, fallback: "Erro ao carregar as atualizações da obra")
        }
        isLoading = false
    }
}
