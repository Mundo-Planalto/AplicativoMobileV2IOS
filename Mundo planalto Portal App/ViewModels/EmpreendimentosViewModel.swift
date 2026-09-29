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

    /// Empreendimento de demonstração (docs/telas.md).
    static let demoVenture = Venture(
        id: "demo-1",
        name: "Hard Rock Hotel Gramado",
        imageUrl: FinanceiroRepositoryMock.imagemGramado,
        progress: 0,
        lastUpdate: "",
        photoBook: nil,
        unit: "Unidade 1208 • Torre A"
    )

    func loadVentures(forceRefresh: Bool = false) async {
        error = nil
        if AppState.shared.isDemoSession {
            ventures = [Self.demoVenture]
            isLoading = false
            return
        }

        // Se não for refresh forçado, tenta renderizar imediatamente usando cache.
        if !forceRefresh,
           let cached = EmpreendimentosService.shared.getEmpreendimentosCached(),
           !cached.empreendimentos.isEmpty {
            ventures = cached.empreendimentos
            // Atualiza em background para manter frescor.
            isLoading = true
            do {
                let response = try await EmpreendimentosService.shared.getEmpreendimentos(
                    useCache: false,
                    forceRefresh: true
                )
                ventures = response.empreendimentos
            } catch {
                // Mantém o cache já exibido; mostra erro só se não tiver dados.
                if ventures.isEmpty {
                    self.error = AppErrorMapper.userMessage(
                        for: error,
                        fallback: "Erro ao carregar empreendimentos"
                    )
                }
            }
            isLoading = false
            return
        }

        // Sem cache (ou refresh forçado): carrega normalmente.
        isLoading = true
        do {
            let response = try await EmpreendimentosService.shared.getEmpreendimentos(
                useCache: !forceRefresh,
                forceRefresh: forceRefresh
            )
            ventures = response.empreendimentos
        } catch {
            self.error = AppErrorMapper.userMessage(
                for: error,
                fallback: "Erro ao carregar empreendimentos"
            )
        }
        isLoading = false
    }
}