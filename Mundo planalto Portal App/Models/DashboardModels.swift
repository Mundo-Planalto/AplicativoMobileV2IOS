//
//  DashboardModels.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

struct ClientInfo: Identifiable, Codable {
    var id = UUID()
    let name: String
    let totalVentures: Int
}

struct FinancialSummary: Codable {
    let overdueAmount: Double
    let upcomingAmount: Double
    let overdueInstallments: Int
    let totalAmount: Double
}

struct Venture: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let imageUrl: String
    let progress: Double // 0.0 to 1.0
    let lastUpdate: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Venture, rhs: Venture) -> Bool {
        lhs.id == rhs.id
    }
}

struct Notice: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let date: String
    let type: NoticeType

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Notice, rhs: Notice) -> Bool {
        lhs.id == rhs.id
    }
}

enum NoticeType: String, Codable {
    case notice
    case news
}

struct VentureUpdate: Identifiable, Codable {
    let id: String
    let date: String
    let title: String
    let description: String
    let images: [String]
    let isCompleted: Bool
}

struct FinancialStatementItem: Identifiable, Codable {
    let id: String
    let ventureName: String
    let installmentNumber: String // "1/24"
    let dueDate: String
    let amount: Double
    let status: PaymentStatus
}

enum PaymentStatus: String, Codable {
    case paid
    case upcoming
    case overdue
}

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let destination: AppDestination
}

enum AppDestination {
    case ventures
    case financial
    case notices
    case profile
}