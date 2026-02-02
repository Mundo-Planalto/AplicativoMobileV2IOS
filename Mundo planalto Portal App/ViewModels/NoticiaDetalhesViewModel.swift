//
//  NoticiaDetalhesViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class NoticiaDetalhesViewModel: ObservableObject {
    @Published var notice: Notice?
    @Published var isLoading = false
    @Published var error: String?

    private let noticeId: String

    init(noticeId: String) {
        self.noticeId = noticeId
    }

    func loadNoticeDetails() async {
        isLoading = true
        error = nil

        do {
            // Simular carregamento da notícia específica pela API
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo

            // Em produção, faria: GET /announcements/{noticeId}
            // Por enquanto, simula busca no array de dados mockados
            if let mockNotice = getMockNoticeById(noticeId) {
                notice = mockNotice
            } else {
                error = "Notícia não encontrada"
            }

        } catch {
            self.error = "Erro ao carregar detalhes da notícia"
        }

        isLoading = false
    }

    private func getMockNoticeById(_ id: String) -> Notice? {
        // Dados mockados - em produção viria da API
        let mockNotices = [
            Notice(id: "1",
                  title: "Reunião de Condôminos - Residencial Parque das Flores",
                  description: "Reunião marcada para o dia 15/02 às 19h na sala de eventos do prédio. Ordem do dia: prestação de contas, manutenção preventiva e sugestões dos moradores. Todos os condôminos estão convidados a participar desta importante reunião onde serão discutidos os assuntos administrativos do condomínio, incluindo a aprovação do orçamento para o próximo ano, planejamento de manutenções preventivas e espaço para sugestões e reclamações dos moradores. A presença de todos é fundamental para a boa gestão do nosso lar.",
                  date: "10/01/2025",
                  type: .notice),
            Notice(id: "2",
                  title: "Nova Fase da Obra - Condomínio Vista Verde",
                  description: "Iniciamos a construção da torre norte com previsão de entrega para dezembro de 2025. Acompanhe o progresso através do nosso aplicativo. Esta nova fase inclui a construção de 48 apartamentos de alto padrão com vista para o parque municipal.",
                  date: "08/01/2025",
                  type: .news)
        ]

        return mockNotices.first { $0.id == id }
    }
}