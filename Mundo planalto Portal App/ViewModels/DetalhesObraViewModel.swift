//
//  DetalhesObraViewModel.swift
//  Mundo Planalto
//
//  Acompanhamento de obra de um empreendimento com os dados cadastrados no portal:
//  atualizações (GET ventureupdates/venture/{id}) e vídeos do book (photoBook de GET ventures).
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

    /// Vídeos cadastrados no book do empreendimento (YouTube ou arquivo de vídeo), no formato do card de atualização.
    var videosDoBook: [VentureUpdate] {
        (venture.photoBook ?? []).compactMap { item in
            let tipo = item.mediaType.lowercased()
            let youtube = item.youtubeUrl?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let arquivo = tipo == "video" && !item.photoUrl.isEmpty ? item.photoUrl : nil
            guard !youtube.isEmpty || arquivo != nil else { return nil }
            return VentureUpdate(
                id: "book-\(item.id)",
                date: HrFormat.parseDate(item.createdAt) == nil ? "" : HrFormat.dayMonthYear(item.createdAt),
                title: venture.name,
                description: "",
                images: [],
                imageUrl: nil,
                videoUrl: arquivo,
                youtubeUrl: youtube.isEmpty ? nil : youtube,
                isCompleted: false
            )
        }
    }

    var semConteudo: Bool { updates.isEmpty && videosDoBook.isEmpty }

    func loadVentureDetails(forceRefresh: Bool = false) async {
        isLoading = updates.isEmpty
        error = nil
        do {
            // Mantém o book em dia com o portal (fotos e vídeos novos).
            if let atual = try? await RepositoryProvider.ventures.ventures(forceRefresh: forceRefresh).first(where: { $0.id == venture.id }) {
                venture = atual
            }
            updates = try await RepositoryProvider.ventures.updates(venture: venture)
        } catch {
            self.error = AppErrorMapper.userMessage(for: error, fallback: "Erro ao carregar as atualizações da obra")
        }
        isLoading = false
    }
}
