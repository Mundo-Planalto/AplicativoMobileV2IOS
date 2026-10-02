//
//  ChangeRequestsRepository.swift
//  Mundo Planalto
//
//  Alteração de dados: o cliente pede troca de endereço, telefone ou e-mail e a Central de
//  Contratos aprova. Contrato novo: GET/POST customers/change-requests.
//  Enquanto ele não existe, o login real usa o endpoint que o portal já tem para endereço
//  (address/change-requests); telefone e e-mail ficam indisponíveis fora da demonstração.
//

import Foundation

/// Endereço completo do formulário (o backend atual exige os campos separados).
struct AddressForm: Equatable {
    var street = ""
    var number = ""
    var complement = ""
    var neighborhood = ""
    var city = ""
    var state = ""
    var zipCode = ""

    var isValid: Bool {
        ![street, number, neighborhood, city, state, zipCode].contains { $0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var resumo: String {
        let comp = complement.trimmingCharacters(in: .whitespaces)
        return "\(street), \(number)" + (comp.isEmpty ? "" : " — \(comp)") + " — \(neighborhood), \(city)/\(state), CEP \(zipCode)"
    }
}

enum ChangeRequestError: LocalizedError {
    case notAvailable(ChangeRequestField)
    case failed

    var errorDescription: String? {
        switch self {
        case .notAvailable(let field):
            return "A alteração de \(field.titulo.lowercased()) pelo app estará disponível em breve. Por enquanto, fale com a Central de Contratos."
        case .failed:
            return "Não foi possível enviar a solicitação. Tente novamente."
        }
    }
}

protocol ChangeRequestsRepository {
    func requests() async throws -> [ChangeRequest]
    func create(field: ChangeRequestField, newValue: String, address: AddressForm?) async throws -> ChangeRequest
}

// MARK: - Mock (demonstração)

final class ChangeRequestsRepositoryMock: ChangeRequestsRepository {
    static let shared = ChangeRequestsRepositoryMock()

    private var stored: [ChangeRequest] = [
        ChangeRequest(id: 1, field: .phone, newValue: "(62) 98888-0000", status: .approved, createdAt: "2026-09-20")
    ]

    func requests() async throws -> [ChangeRequest] { stored.sorted { $0.id > $1.id } }

    func create(field: ChangeRequestField, newValue: String, address: AddressForm?) async throws -> ChangeRequest {
        let created = ChangeRequest(id: (stored.map(\.id).max() ?? 0) + 1, field: field,
                                    newValue: address?.resumo ?? newValue,
                                    status: .pending, createdAt: ISO8601DateFormatter().string(from: Date()))
        stored.append(created)
        return created
    }
}

// MARK: - Portal atual (login real enquanto customers/change-requests não existe)

final class ChangeRequestsRepositoryPortal: ChangeRequestsRepository {
    func requests() async throws -> [ChangeRequest] {
        try await AddressService.shared.getMyChangeRequests().map { dto in
            ChangeRequest(id: dto.id, field: .address, newValue: dto.requestedAddress,
                          status: Self.status(dto.status), createdAt: dto.requestDate)
        }
        .sorted { $0.id > $1.id }
    }

    func create(field: ChangeRequestField, newValue: String, address: AddressForm?) async throws -> ChangeRequest {
        guard field == .address, let a = address else { throw ChangeRequestError.notAvailable(field) }
        let comp = a.complement.trimmingCharacters(in: .whitespaces)
        guard let dto = try await AddressService.shared.createChangeRequest(
            street: a.street, number: a.number, complement: comp.isEmpty ? nil : comp,
            neighborhood: a.neighborhood, city: a.city, state: a.state, zipCode: a.zipCode
        ) else { throw ChangeRequestError.failed }
        return ChangeRequest(id: dto.id, field: .address, newValue: dto.requestedAddress,
                             status: Self.status(dto.status), createdAt: dto.requestDate)
    }

    private static func status(_ raw: String) -> ChangeRequestStatus {
        let s = raw.lowercased()
        if s.contains("aprov") || s.contains("approv") { return .approved }
        if s.contains("recus") || s.contains("reject") || s.contains("rejei") { return .rejected }
        return .pending
    }
}

// MARK: - Remote (contrato novo)

final class ChangeRequestsRepositoryRemote: ChangeRequestsRepository {
    private let api = HrApiClient.shared

    func requests() async throws -> [ChangeRequest] { try await api.get("customers/change-requests") }

    func create(field: ChangeRequestField, newValue: String, address: AddressForm?) async throws -> ChangeRequest {
        try await api.post("customers/change-requests", body: ChangeRequestCreate(field: field, newValue: address?.resumo ?? newValue))
    }
}
