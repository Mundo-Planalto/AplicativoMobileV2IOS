//
//  MilhasRepository.swift
//  Hard Rock Hotel & Vacation Club
//
//  GET miles/offers e POST unity/interest.
//

import Foundation

protocol MilhasRepository {
    func milesOffers() async throws -> [MilesOffer]
    func registerUnityInterest() async throws
}

final class MilhasRepositoryMock: MilhasRepository {
    static let shared = MilhasRepositoryMock()

    func milesOffers() async throws -> [MilesOffer] {
        [
            MilesOffer(id: 1, title: "Milhas em dobro", summary: "Campanha promocional ativa", destination: nil,
                       program: nil, url: nil, capturedAt: "2026-09-12T10:00:00Z", expiresAt: "2026-10-31T23:59:59Z")
        ]
    }

    func registerUnityInterest() async throws {}
}

final class MilhasRepositoryRemote: MilhasRepository {
    private let api = HrApiClient.shared

    func milesOffers() async throws -> [MilesOffer] { try await api.get("miles/offers") }

    func registerUnityInterest() async throws {
        let _: EmptyPayload = try await api.post("unity/interest", body: EmptyPayload())
    }
}
