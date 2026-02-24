//
//  DashboardService.swift
//  Mundo planalto Portal App
//
//  Integração com GET /api/customers/dashboard e /api/dashboard/client.
//

import Foundation

enum DashboardError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

/// Resposta do endpoint GET /api/customers/dashboard (documentação da API).
struct ClientDashboardDto: Codable {
    let customerName: String
    let totalOverdue: Double
    let totalDue: Double
    let overdueCount: Int
    let dueCount: Int
    let nextDueDate: String?
    let nextDueValue: Double
    let recentAnnouncements: [AnnouncementDto]?
    let isEsolutionCustomer: Bool?
}

struct AnnouncementDto: Codable {
    let id: Int
    let title: String
    let content: String
    let postDate: String
    let imageUrl: String?
    let targetCostCenterId: Int?
}

class DashboardService {
    static let shared = DashboardService()
    private init() {}

    private var baseURL: String { ApiConfig.baseURL + "/" }

    private func createAuthorizedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// GET /api/customers/dashboard ou /api/dashboard/client
    func getCustomerDashboard() async throws -> (clientInfo: ClientInfo, financialSummary: FinancialSummary, notices: [Notice]) {
        let path = baseURL + "customers/dashboard"
        guard let url = URL(string: path) else { throw DashboardError.networkError }
        let request = createAuthorizedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw DashboardError.invalidResponse }
        if http.statusCode == 401 { throw DashboardError.invalidCredentials }
        guard http.statusCode == 200 else { throw DashboardError.invalidResponse }

        let decoded = try JSONDecoder().decode(ApiResponse<ClientDashboardDto>.self, from: data)
        guard let dto = decoded.data else { throw DashboardError.invalidResponse }

        let clientInfo = ClientInfo(
            name: dto.customerName,
            totalVentures: 0
        )
        let financialSummary = FinancialSummary(
            overdueAmount: dto.totalOverdue,
            upcomingAmount: dto.totalDue,
            overdueInstallments: dto.overdueCount,
            totalAmount: dto.totalOverdue + dto.totalDue
        )
        let notices: [Notice] = (dto.recentAnnouncements ?? []).map { a in
            Notice(
                id: "\(a.id)",
                title: a.title,
                description: a.content,
                date: a.postDate,
                type: .news
            )
        }
        return (clientInfo, financialSummary, notices)
    }
}