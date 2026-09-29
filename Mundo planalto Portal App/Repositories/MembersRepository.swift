//
//  MembersRepository.swift
//  Hard Rock Hotel & Vacation Club
//
//  GET/PUT members/me/* (cartão, perfil de viagem, preferências, utilizações, milhas, collection).
//

import Foundation

protocol MembersRepository {
    func card() async throws -> MemberCard
    func redemptions() async throws -> [BenefitRedemption]
    func miles() async throws -> MilesAccount
    func collection() async throws -> CollectionStatus
    func travelProfile() async throws -> TravelProfile
    func notificationPreferences() async throws -> NotificationPreferences
    func updateNotificationPreferences(_ prefs: NotificationPreferences) async throws -> NotificationPreferences
}

// MARK: - Mock (docs/telas.md)

final class MembersRepositoryMock: MembersRepository {
    static let shared = MembersRepositoryMock()

    private let prefsKey = "hr_mock_notification_prefs"

    func card() async throws -> MemberCard {
        let demo = MemberInfo.demo
        // Sessão real: nome do cliente logado (nunca o do usuário fictício).
        let nome = AppState.shared.isDemoSession ? demo.nome : (PreferencesManager.shared.getUserName() ?? "")
        return MemberCard(
            name: nome,
            level: .founder,
            memberNumber: demo.numeroMembro,
            memberSince: "2026-01-15",
            status: .active,
            cardToken: "HRVC-8150-DEMO",
            verifyUrl: demo.verifyUrl,
            benefitUsageCount: 3
        )
    }

    func redemptions() async throws -> [BenefitRedemption] {
        [
            BenefitRedemption(id: 1, partnerId: 1, partnerName: "Chocolates Lugano", discountText: "10%", usedAt: "2026-09-20T15:30:00Z", source: "qr"),
            BenefitRedemption(id: 2, partnerId: 2, partnerName: "Restaurante Belle du Val", discountText: "20%", usedAt: "2026-09-14T21:10:00Z", source: "coupon"),
            BenefitRedemption(id: 3, partnerId: 3, partnerName: "Snowland", discountText: "15%", usedAt: "2026-09-02T11:00:00Z", source: "qr")
        ]
    }

    func miles() async throws -> MilesAccount {
        MilesAccount(
            balance: 12500,
            entries: [
                MilesEntry(id: 1, amount: 2000, description: "Campanha Milhas em dobro", createdAt: "2026-09-12"),
                MilesEntry(id: 2, amount: 500, description: "Hospedagem Gramado", createdAt: "2026-08-28"),
                MilesEntry(id: 3, amount: 10000, description: "Bônus de boas-vindas", createdAt: "2026-08-01")
            ]
        )
    }

    func collection() async throws -> CollectionStatus {
        CollectionStatus(
            contractNumber: nil,
            eligible: true,
            items: [
                CollectionItem(index: 1, status: .sent),
                CollectionItem(index: 2, status: .sent),
                CollectionItem(index: 3, status: .locked),
                CollectionItem(index: 4, status: .locked),
                CollectionItem(index: 5, status: .locked),
                CollectionItem(index: 6, status: .locked)
            ]
        )
    }

    func travelProfile() async throws -> TravelProfile {
        TravelProfile(homeCity: "Goiânia", homeState: "GO", preferredDestinations: ["Gramado", "Orlando", "Cancún", "Lisboa"])
    }

    func notificationPreferences() async throws -> NotificationPreferences {
        if let data = UserDefaults.standard.data(forKey: prefsKey),
           let saved = try? JSONDecoder().decode(NotificationPreferences.self, from: data) {
            return saved
        }
        return NotificationPreferences(milesOffers: true, announcements: true)
    }

    func updateNotificationPreferences(_ prefs: NotificationPreferences) async throws -> NotificationPreferences {
        if let data = try? JSONEncoder().encode(prefs) {
            UserDefaults.standard.set(data, forKey: prefsKey)
        }
        return prefs
    }
}

// MARK: - Remote (docs/openapi-hardrock.yaml)

final class MembersRepositoryRemote: MembersRepository {
    private let api = HrApiClient.shared

    func card() async throws -> MemberCard { try await api.get("members/me/card") }
    func redemptions() async throws -> [BenefitRedemption] { try await api.get("members/me/redemptions") }
    func miles() async throws -> MilesAccount { try await api.get("members/me/miles") }
    func collection() async throws -> CollectionStatus { try await api.get("members/me/collection") }
    func travelProfile() async throws -> TravelProfile { try await api.get("members/me/travel-profile") }
    func notificationPreferences() async throws -> NotificationPreferences { try await api.get("members/me/notification-preferences") }
    func updateNotificationPreferences(_ prefs: NotificationPreferences) async throws -> NotificationPreferences {
        try await api.put("members/me/notification-preferences", body: prefs)
    }
}
