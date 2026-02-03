//
//  DashboardService.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

enum DashboardError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

struct FinancialOverviewResponse: Codable {
    let totalInvested: Double
    let totalReturns: Double
    let monthlyReturn: Double
    let returnPercentage: Double
}

struct DashboardNoticeItem: Codable {
    let id: String
    let title: String
    let description: String
    let date: String
    let type: String
}

struct DashboardFinancialSummaryItem: Codable {
    let overdueAmount: Double
    let upcomingAmount: Double
    let overdueInstallments: Int
    let totalAmount: Double
}

struct QuickActionItem: Codable {
    let id: String
    let title: String
    let icon: String
    let action: String
}

struct DashboardResponse: Codable {
    let financialOverview: FinancialOverviewResponse
    let financialSummary: [DashboardFinancialSummaryItem]
    let recentNotices: [DashboardNoticeItem]
    let quickActions: [QuickActionItem]
    let success: Bool
    let message: String?
}

class DashboardService {
    static let shared = DashboardService()

    private let baseURL = "http://10.35.0.55:5187/api/"

    private init() {}

    private func createAuthorizedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization header if token exists
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    func getDashboardData() async throws -> DashboardResponse {
        guard let url = URL(string: baseURL + "dashboard") else {
            throw DashboardError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw DashboardError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let dashboardResponse = try JSONDecoder().decode(DashboardResponse.self, from: data)
                return dashboardResponse
            } else if httpResponse.statusCode == 401 {
                throw DashboardError.invalidCredentials
            } else {
                throw DashboardError.invalidResponse
            }
        } catch {
            throw DashboardError.networkError
        }
    }

    func getFinancialOverview() async throws -> FinancialOverviewResponse {
        guard let url = URL(string: baseURL + "dashboard/financial-overview") else {
            throw DashboardError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw DashboardError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let overview = try JSONDecoder().decode(FinancialOverviewResponse.self, from: data)
                return overview
            } else if httpResponse.statusCode == 401 {
                throw DashboardError.invalidCredentials
            } else {
                throw DashboardError.invalidResponse
            }
        } catch {
            throw DashboardError.networkError
        }
    }

    func getRecentNotices() async throws -> [Notice] {
        guard let url = URL(string: baseURL + "dashboard/notices") else {
            throw DashboardError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw DashboardError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let items = try JSONDecoder().decode([DashboardNoticeItem].self, from: data)
                return items.map { item in
                    Notice(
                        id: item.id,
                        title: item.title,
                        description: item.description,
                        date: item.date,
                        type: NoticeType(rawValue: item.type) ?? .notice
                    )
                }
            } else if httpResponse.statusCode == 401 {
                throw DashboardError.invalidCredentials
            } else {
                throw DashboardError.invalidResponse
            }
        } catch {
            throw DashboardError.networkError
        }
    }
}