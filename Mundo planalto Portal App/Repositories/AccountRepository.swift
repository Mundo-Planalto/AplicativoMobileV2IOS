//
//  AccountRepository.swift
//  Mundo Planalto
//
//  Exclusão de conta pedida de dentro do app (exigência da App Store, regra 5.1.1(v), porque o
//  app tem "Primeiro acesso"). Contrato: POST customers/me/deletion-request
//  (docs/contrato-api-pendente.md, seção 10). O backend abre o pedido para a Central de Contratos.
//

import Foundation

struct AccountDeletionRequest: Codable {
    let reason: String?
}

struct AccountDeletionResult: Codable, Equatable {
    /// Protocolo do pedido, mostrado ao cliente.
    let protocolNumber: String
    /// Prazo em dias para a conclusão (LGPD: o app informa ao cliente).
    let deadlineDays: Int

    enum CodingKeys: String, CodingKey {
        case deadlineDays
        case protocolNumber = "protocol"
    }

    var prazoTexto: String { deadlineDays == 1 ? "em até 1 dia" : "em até \(deadlineDays) dias" }
}

protocol AccountRepository {
    func requestDeletion(reason: String?) async throws -> AccountDeletionResult
}

// MARK: - Mock (sem backend: não inventa protocolo)

final class AccountRepositoryMock: AccountRepository {
    static let shared = AccountRepositoryMock()

    func requestDeletion(reason: String?) async throws -> AccountDeletionResult {
        throw HrApiError.http(501, HrPendente.nadaEnviado)
    }
}

// MARK: - Remote

final class AccountRepositoryRemote: AccountRepository {
    private let api = HrApiClient.shared

    func requestDeletion(reason: String?) async throws -> AccountDeletionResult {
        try await api.post("customers/me/deletion-request", body: AccountDeletionRequest(reason: reason))
    }
}
