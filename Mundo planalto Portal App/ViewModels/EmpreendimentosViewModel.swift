//
//  EmpreendimentosViewModel.swift
//  Mundo Planalto
//

import Foundation
import SwiftUI
import Combine

@MainActor
class EmpreendimentosViewModel: ObservableObject {
    @Published var ventures: [Venture] = []
    @Published var isLoading = false
    @Published var error: String?

    static var demoVenture: Venture { VenturesRepositoryMock.demoVenture }

    func loadVentures(forceRefresh: Bool = false) async {
        error = nil
        // Mostra o cache na hora (login real) e atualiza em seguida.
        if !forceRefresh, ventures.isEmpty, !AppState.shared.isDemoSession,
           let cached = EmpreendimentosService.shared.getEmpreendimentosCached(), !cached.empreendimentos.isEmpty {
            ventures = cached.empreendimentos
        }
        isLoading = true
        do {
            ventures = try await RepositoryProvider.ventures.ventures(forceRefresh: forceRefresh || !ventures.isEmpty)
        } catch {
            if ventures.isEmpty {
                self.error = AppErrorMapper.userMessage(for: error, fallback: "Erro ao carregar empreendimentos")
            }
        }
        isLoading = false
    }
}
