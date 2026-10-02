//
//  OfertasRepository.swift
//  Hard Rock Hotel & Vacation Club
//
//  GET offers.
//

import Foundation

protocol OfertasRepository {
    func offers() async throws -> [Offer]
}

// MARK: - Mock (docs/telas.md, seção Ofertas)

final class OfertasRepositoryMock: OfertasRepository {
    static let shared = OfertasRepositoryMock()

    func offers() async throws -> [Offer] {
        [
            Offer(id: 100, title: "Experiências que valem mais", subtitle: "Condições especiais por tempo limitado",
                  description: nil, category: .experiencias,
                  imageUrl: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800",
                  isFeatured: true, ctaLabel: "Ver campanha", ctaUrl: nil, partnerId: nil, validFrom: nil, validUntil: "2026-10-31"),
            Offer(id: 1, title: "20% de desconto", subtitle: "Restaurantes parceiros em Gramado", description: nil,
                  category: .gastronomia, imageUrl: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400",
                  isFeatured: false, ctaLabel: "Ver oferta", ctaUrl: nil, partnerId: 2, validFrom: nil, validUntil: nil),
            Offer(id: 2, title: "Fim de semana especial", subtitle: "Condições exclusivas para membros", description: nil,
                  category: .hospedagem, imageUrl: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400",
                  isFeatured: false, ctaLabel: "Ver oferta", ctaUrl: nil, partnerId: nil, validFrom: nil, validUntil: nil)
        ]
    }
}

// MARK: - Remote

final class OfertasRepositoryRemote: OfertasRepository {
    private let api = HrApiClient.shared
    func offers() async throws -> [Offer] { try await api.get("offers") }
}
