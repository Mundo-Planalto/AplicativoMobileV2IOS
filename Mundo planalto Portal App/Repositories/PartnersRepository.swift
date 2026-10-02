//
//  PartnersRepository.swift
//  Mundo Planalto
//
//  GET partners (já filtrado pelo backend por empreendimento do cliente) e
//  POST partners/{id}/coupon.
//

import Foundation

protocol PartnersRepository {
    func partners() async throws -> [Partner]
    func coupon(partnerId: Int) async throws -> Coupon
}

// MARK: - Mock (docs/telas.md: 6 parceiros de Gramado; destaques Belle du Val e Snowland)

final class PartnersRepositoryMock: PartnersRepository {
    static let shared = PartnersRepositoryMock()

    private struct Seed {
        let id: Int; let nome: String; let desconto: String; let cupom: String
        let categoria: PartnerCategory; let percent: Int
        var imagem: String? = nil; var destaque = false; var novo = false
    }

    private let seeds: [Seed] = [
        Seed(id: 1, nome: "Chocolates Lugano", desconto: "10% de desconto", cupom: "HRVC-LUGANO10", categoria: .compras, percent: 10),
        Seed(id: 2, nome: "Restaurante Belle du Val", desconto: "20% no jantar", cupom: "HRVC-20JANTAR", categoria: .gastronomia, percent: 20,
             imagem: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800", destaque: true),
        Seed(id: 3, nome: "Snowland", desconto: "15% no ingresso", cupom: "HRVC-SNOW15", categoria: .experiencias, percent: 15,
             imagem: "https://images.unsplash.com/photo-1483921020237-2ff51e8e4b22?w=800", destaque: true, novo: true),
        Seed(id: 4, nome: "Mini Mundo", desconto: "10% no ingresso", cupom: "HRVC-MINI10", categoria: .experiencias, percent: 10),
        Seed(id: 5, nome: "Cervejaria Rasen Bier", desconto: "10% na conta", cupom: "HRVC-RASEN10", categoria: .gastronomia, percent: 10),
        Seed(id: 6, nome: "Vinícola Ravanello", desconto: "15% em vinhos", cupom: "HRVC-RAVA15", categoria: .gastronomia, percent: 15)
    ]

    func partners() async throws -> [Partner] {
        seeds.map {
            Partner(id: $0.id, name: $0.nome, category: $0.categoria, city: "Gramado", state: "RS",
                    discountPercent: $0.percent, discountText: $0.desconto, terms: nil, validationType: "coupon",
                    logoUrl: nil, imageUrl: $0.imagem, address: nil, usageLimitPerCustomer: nil, validUntil: nil,
                    isActive: true, isFeatured: $0.destaque, ventureIds: [1], isNew: $0.novo)
        }
    }

    func coupon(partnerId: Int) async throws -> Coupon {
        guard let s = seeds.first(where: { $0.id == partnerId }) else { throw HrApiError.http(404, "Parceiro não encontrado") }
        return Coupon(partnerId: s.id, partnerName: s.nome, code: s.cupom, discountText: s.desconto,
                      validUntil: nil, remainingUses: nil, instructions: "Apresente este código no parceiro")
    }
}

// MARK: - Remote

final class PartnersRepositoryRemote: PartnersRepository {
    private let api = HrApiClient.shared

    func partners() async throws -> [Partner] { try await api.get("partners") }
    func coupon(partnerId: Int) async throws -> Coupon { try await api.post("partners/\(partnerId)/coupon", body: EmptyPayload()) }
}
