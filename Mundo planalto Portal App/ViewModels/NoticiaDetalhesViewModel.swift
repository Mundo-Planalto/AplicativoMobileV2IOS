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
    @Published var notice: AppNotice?
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
            // Carrega da API (lista) e filtra pelo id
            let list = AppState.shared.isDemoSession
                ? AvisosNoticiasViewModel.demoNotices
                : try await NewsService.shared.getAnnouncements()
            if let found = list.first(where: { $0.id == noticeId }) {
                notice = found
                AppState.shared.markNoticeAsRead(noticeId)
            } else {
                error = "Aviso/Notícia não encontrado(a)"
            }
        } catch {
            self.error = AppErrorMapper.userMessage(
                for: error,
                fallback: "Erro ao carregar detalhes da notícia"
            )
        }

        isLoading = false
    }
}