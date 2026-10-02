//
//  CampaignsRepository.swift
//  Mundo Planalto
//
//  GET campaigns (substitui offers) e POST campaigns/{id}/interest (clique rastreável).
//

import Foundation

protocol CampaignsRepository {
    func campaigns() async throws -> [Campaign]
    func registerInterest(id: Int) async throws
}

// MARK: - Mock (docs/telas.md, seção Campanhas, nesta ordem)

final class CampaignsRepositoryMock: CampaignsRepository {
    static let shared = CampaignsRepositoryMock()
    /// Cliques registrados na sessão (o backend é quem conta de verdade).
    private(set) var interestLog: [Int] = []

    func campaigns() async throws -> [Campaign] {
        [
            Campaign(id: 1, category: "Antecipação", title: "Antecipe parcelas e ganhe desconto",
                     subtitle: "Condições válidas por tempo limitado",
                     imageUrl: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800",
                     validUntil: "2026-10-31", ctaLabel: "Quero antecipar", ctaType: .postsales, ctaUrl: nil,
                     whatsappNumber: nil, whatsappMessage: nil, ventureIds: [1], isFeatured: true),
            Campaign(id: 2, category: "Upgrade", title: "Faça upgrade do seu plano",
                     subtitle: "Mais semanas e mais benefícios", imageUrl: nil,
                     validUntil: nil, ctaLabel: "Quero saber mais", ctaType: .online, ctaUrl: nil,
                     whatsappNumber: nil, whatsappMessage: nil, ventureIds: [1], isFeatured: false),
            Campaign(id: 3, category: "Indicação", title: "Indique um amigo e ganhe um brinde",
                     subtitle: "Seu amigo compra, você ganha", imageUrl: nil,
                     validUntil: nil, ctaLabel: "Indicar agora", ctaType: .whatsapp, ctaUrl: nil,
                     whatsappNumber: "5562999999999", whatsappMessage: "Olá! Quero indicar um amigo para o Mundo Planalto.",
                     ventureIds: [1], isFeatured: false),
            Campaign(id: 4, category: "Viagem", title: "Gramado em julho com preço especial",
                     subtitle: "Use seu certificado nesta oferta do Mais Viagens",
                     imageUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
                     validUntil: nil, ctaLabel: "Usar certificado", ctaType: .certificate, ctaUrl: nil,
                     whatsappNumber: nil, whatsappMessage: nil, ventureIds: [1], isFeatured: false)
        ]
    }

    func registerInterest(id: Int) async throws {
        interestLog.append(id)
        #if DEBUG
        print("[Campanhas][mock] interesse registrado na campanha \(id)")
        #endif
    }
}

// MARK: - Remote

final class CampaignsRepositoryRemote: CampaignsRepository {
    private let api = HrApiClient.shared

    func campaigns() async throws -> [Campaign] { try await api.get("campaigns") }
    func registerInterest(id: Int) async throws {
        let _: EmptyPayload = try await api.post("campaigns/\(id)/interest", body: EmptyPayload())
    }
}
