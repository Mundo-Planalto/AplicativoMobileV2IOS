//
//  DetalhesObraViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
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
        isLoading = true
        error = nil
        let ventureId = Int(venture.id) ?? 0
        do {
            let dtos = try await EmpreendimentosService.shared.getVentureUpdates(ventureId: ventureId)
            updates = dtos.map { dto in
                VentureUpdate(
                    id: "\(dto.id)",
                    date: formatPostDate(dto.postDate),
                    title: dto.title,
                    description: dto.content,
                    images: [dto.imageUrl].compactMap { $0 },
                    isCompleted: false
                )
            }
        } catch {
            self.error = "Erro ao carregar detalhes da obra"
        }
        isLoading = false
    }

    private func formatPostDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) {
            let out = DateFormatter()
            out.locale = Locale(identifier: "pt_BR")
            out.dateStyle = .medium
            return out.string(from: date)
        }
        return iso
    }
}