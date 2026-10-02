//
//  TravelProfileRepository.swift
//  Mundo Planalto
//
//  GET/PUT members/me/travel-profile. Pré-preenchido com as respostas do PEP;
//  cada edição gera histórico para o Pós-vendas (no backend).
//

import Foundation

protocol TravelProfileRepository {
    func profile() async throws -> TravelProfile
    func save(_ profile: TravelProfile) async throws -> TravelProfile
}

final class TravelProfileRepositoryMock: TravelProfileRepository {
    static let shared = TravelProfileRepositoryMock()

    private var stored = TravelProfile(
        homeCity: "Goiânia", homeState: "GO",
        preferredDestinations: ["Gramado", "Orlando", "Cancún", "Lisboa"],
        nextTripWhen: .within6Months, nextTripDestination: "Gramado", source: "pep"
    )

    func profile() async throws -> TravelProfile { stored }

    func save(_ profile: TravelProfile) async throws -> TravelProfile {
        var updated = profile
        updated.source = "app"
        stored = updated
        return updated
    }
}

final class TravelProfileRepositoryRemote: TravelProfileRepository {
    private let api = HrApiClient.shared

    func profile() async throws -> TravelProfile { try await api.get("members/me/travel-profile") }
    func save(_ profile: TravelProfile) async throws -> TravelProfile { try await api.put("members/me/travel-profile", body: profile) }
}
