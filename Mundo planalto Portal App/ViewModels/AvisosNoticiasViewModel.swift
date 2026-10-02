//
//  AvisosNoticiasViewModel.swift
//  Mundo Planalto
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AvisosNoticiasViewModel: ObservableObject {
    @Published var notices: [AppNotice] = []
    @Published var isLoading = false
    @Published var error: String?

    /// Avisos de demonstração (sem API). Textos provisórios, ver docs/PENDENCIAS.md.
    static let demoNotices: [AppNotice] = [
        AppNotice(id: "demo-1", title: "Atualização da obra — Setembro de 2026",
                  description: "O novo vídeo do acompanhamento da obra do Hard Rock Hotel Gramado já está disponível na aba Empreendimentos.",
                  date: "28/09/2026", type: .notice),
        AppNotice(id: "demo-2", title: "Programa Unity disponível para membros",
                  description: "Cadastre-se no Hard Rock Unity e aproveite vantagens em hotéis, restaurantes e experiências no mundo todo.",
                  date: "15/09/2026", type: .news),
        AppNotice(id: "demo-3", title: "Seu certificado foi liberado",
                  description: "O certificado Mais Viagens — Experiência Gramado já pode ser usado. Veja o código em Viagens.",
                  date: "02/09/2026", type: .notice)
    ]

    func loadNotices() async {
        isLoading = true
        error = nil
        if AppState.shared.isDemoSession {
            notices = Self.demoNotices
            isLoading = false
            return
        }
        do {
            let list = try await NewsService.shared.getAnnouncements()
            notices = list
        } catch {
            self.error = AppErrorMapper.userMessage(
                for: error,
                fallback: "Erro ao carregar avisos e notícias"
            )
        }
        isLoading = false
    }
}
