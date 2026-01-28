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
    @Published var notice: Notice
    @Published var isLoading = false
    @Published var error: String?

    init(notice: Notice) {
        self.notice = notice
    }

    // Aqui poderia carregar dados adicionais da notícia se necessário
    func loadNoticeDetails() async {
        isLoading = true
        error = nil

        do {
            // Simular carregamento de dados adicionais se necessário
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos

            // A notícia já tem todos os dados necessários, então apenas simular sucesso

        } catch {
            self.error = "Erro ao carregar detalhes da notícia"
        }

        isLoading = false
    }
}