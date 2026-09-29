//
//  CertificadosRepository.swift
//  Hard Rock Hotel & Vacation Club
//
//  GET/POST certificates/requests.
//

import Foundation

protocol CertificadosRepository {
    func options() -> [CertificateOption]
    func requests() async throws -> [CertificateRequest]
    func request(type: CertificateType) async throws -> CertificateRequest
}

extension CertificadosRepository {
    /// Textos fixos de docs/telas.md (iguais no Android).
    func options() -> [CertificateOption] {
        [
            CertificateOption(type: .nacional, titulo: "Experiência no Brasil",
                              descricao: "Hospedagem para momentos inesquecíveis.",
                              imageUrl: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800"),
            CertificateOption(type: .internacional, titulo: "Experiência Internacional",
                              descricao: "Descubra destinos ao redor do mundo.",
                              imageUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800")
        ]
    }
}

// MARK: - Mock (estado em memória durante a sessão)

final class CertificadosRepositoryMock: CertificadosRepository {
    static let shared = CertificadosRepositoryMock()
    private var stored: [CertificateRequest] = []
    private var nextId = 1

    func requests() async throws -> [CertificateRequest] { stored }

    func request(type: CertificateType) async throws -> CertificateRequest {
        if let existing = stored.first(where: { $0.type == type && ($0.status == .requested || $0.status == .inProgress) }) {
            return existing
        }
        let iso = ISO8601DateFormatter().string(from: Date())
        let created = CertificateRequest(
            id: nextId, type: type, status: .requested,
            protocolNumber: String(format: "CERT-2026-%06d", nextId),
            certificateCode: nil, requestedAt: iso
        )
        nextId += 1
        stored.append(created)
        return created
    }
}

// MARK: - Remote

final class CertificadosRepositoryRemote: CertificadosRepository {
    private let api = HrApiClient.shared

    func requests() async throws -> [CertificateRequest] { try await api.get("certificates/requests") }

    func request(type: CertificateType) async throws -> CertificateRequest {
        try await api.post("certificates/requests",
                           body: CertificateRequestCreate(type: type, preferredDestination: nil, preferredPeriod: nil, notes: nil))
    }
}
