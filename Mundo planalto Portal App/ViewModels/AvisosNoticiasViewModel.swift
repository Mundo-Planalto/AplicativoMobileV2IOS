//
//  AvisosNoticiasViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AvisosNoticiasViewModel: ObservableObject {
    @Published var notices: [AppNotice] = []
    @Published var isLoading = false
    @Published var error: String?

    func loadNotices() async {
        isLoading = true
        error = nil
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