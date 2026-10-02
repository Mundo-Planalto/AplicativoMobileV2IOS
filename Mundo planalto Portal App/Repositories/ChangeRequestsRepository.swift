//
//  ChangeRequestsRepository.swift
//  Mundo Planalto
//
//  GET/POST customers/change-requests: o cliente pede alteração de endereço, telefone
//  ou e-mail e a Central de Contratos aprova.
//

import Foundation

protocol ChangeRequestsRepository {
    func requests() async throws -> [ChangeRequest]
    func create(field: ChangeRequestField, newValue: String) async throws -> ChangeRequest
}

final class ChangeRequestsRepositoryMock: ChangeRequestsRepository {
    static let shared = ChangeRequestsRepositoryMock()

    private var stored: [ChangeRequest] = [
        ChangeRequest(id: 1, field: .phone, newValue: "(62) 98888-0000", status: .approved, createdAt: "2026-09-20")
    ]

    func requests() async throws -> [ChangeRequest] { stored.sorted { $0.id > $1.id } }

    func create(field: ChangeRequestField, newValue: String) async throws -> ChangeRequest {
        let created = ChangeRequest(id: (stored.map(\.id).max() ?? 0) + 1, field: field, newValue: newValue,
                                    status: .pending, createdAt: ISO8601DateFormatter().string(from: Date()))
        stored.append(created)
        return created
    }
}

final class ChangeRequestsRepositoryRemote: ChangeRequestsRepository {
    private let api = HrApiClient.shared

    func requests() async throws -> [ChangeRequest] { try await api.get("customers/change-requests") }
    func create(field: ChangeRequestField, newValue: String) async throws -> ChangeRequest {
        try await api.post("customers/change-requests", body: ChangeRequestCreate(field: field, newValue: newValue))
    }
}
