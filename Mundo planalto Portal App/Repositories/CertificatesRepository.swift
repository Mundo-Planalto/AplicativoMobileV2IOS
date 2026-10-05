//
//  CertificatesRepository.swift
//  Mundo Planalto
//
//  GET members/me/certificates e POST certificates/{id}/request (protocolo com SLA).
//  Os certificados são cadastrados pela Central de Contratos por venda; o app só renderiza.
//

import Foundation

protocol CertificatesRepository {
    func certificates() async throws -> [Certificate]
    func requestActivation(id: Int) async throws -> CertificateRequestResult
}

// MARK: - Mock (docs/revisao-ceo-01-10.md, seção 5; estado em memória durante a sessão)

final class CertificatesRepositoryMock: CertificatesRepository {
    static let shared = CertificatesRepositoryMock()

    private let store: [Certificate] = [
        Certificate(id: 1, name: "Certificado RCI — 7 noites", type: .rci, quantity: 1, status: .available,
                    expiresAt: "2027-12-31", protocolNumber: nil, code: nil, useUrl: nil,
                    requestedAt: nil, releasedAt: nil, usedAt: nil),
        Certificate(id: 2, name: "Mais Viagens — Experiência Gramado", type: .maisviagens, quantity: 1, status: .released,
                    expiresAt: "2027-06-30", protocolNumber: nil, code: "MV-8150-2026", useUrl: "https://maisviagens.com.br/",
                    requestedAt: nil, releasedAt: "2026-09-02", usedAt: nil)
    ]

    func certificates() async throws -> [Certificate] { store }

    func requestActivation(id: Int) async throws -> CertificateRequestResult {
        // Sem backend não existe protocolo: o mock não inventa sucesso.
        throw HrApiError.http(501, HrPendente.nadaEnviado)
    }
}

// MARK: - Remote

final class CertificatesRepositoryRemote: CertificatesRepository {
    private let api = HrApiClient.shared

    func certificates() async throws -> [Certificate] { try await api.get("members/me/certificates") }
    func requestActivation(id: Int) async throws -> CertificateRequestResult {
        try await api.post("certificates/\(id)/request", body: EmptyPayload())
    }
}
