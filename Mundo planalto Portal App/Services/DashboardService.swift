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

/// Resposta do endpoint GET /api/customers/dashboard.
/// Decodifica vários formatos: camelCase, snake_case, nomes em português e objeto aninhado "financialSummary"/"financial".
struct ClientDashboardDto: Codable {
    let customerName: String?
    let totalOverdue: Double?
    let totalDue: Double?
    let overdueCount: Int?
    let dueCount: Int?
    let nextDueDate: String?
    let nextDueValue: Double?
    let recentAnnouncements: [AnnouncementDto]?
    let isEsolutionCustomer: Bool?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RawKey.self)
        func decodeDouble(from c: KeyedDecodingContainer<RawKey>, keys: [String]) -> Double? {
            for key in keys {
                guard let k = RawKey(stringValue: key) else { continue }
                if let v = try? c.decodeIfPresent(Double.self, forKey: k) { return v }
                if let v = try? c.decodeIfPresent(Int.self, forKey: k) { return Double(v) }
                if let s = try? c.decodeIfPresent(String.self, forKey: k), let v = Double(s) { return v }
            }
            return nil
        }
        func decodeInt(from c: KeyedDecodingContainer<RawKey>, keys: [String]) -> Int? {
            for key in keys {
                guard let k = RawKey(stringValue: key) else { continue }
                if let v = try? c.decodeIfPresent(Int.self, forKey: k) { return v }
                if let s = try? c.decodeIfPresent(String.self, forKey: k), let v = Int(s) { return v }
            }
            return nil
        }
        func decodeString(from c: KeyedDecodingContainer<RawKey>, keys: [String]) -> String? {
            for key in keys {
                guard let k = RawKey(stringValue: key) else { continue }
                if let v = try? c.decodeIfPresent(String.self, forKey: k) { return v }
            }
            return nil
        }

        var totalOverdue: Double?
        var totalDue: Double?
        var overdueCount: Int?
        var nextDueDate: String?
        var nextDueValue: Double?
        var customerName: String?
        var recentAnnouncements: [AnnouncementDto]?
        var isEsolutionCustomer: Bool?

        let nestedKeys = ["financialSummary", "financial", "resumoFinanceiro"]
        for nestedKey in nestedKeys {
            guard let key = RawKey(stringValue: nestedKey),
                  let nested = try? container.nestedContainer(keyedBy: RawKey.self, forKey: key) else { continue }
            if totalOverdue == nil { totalOverdue = decodeDouble(from: nested, keys: ["totalOverdue", "total_overdue", "totalVencido", "dividasVencidas"]) }
            if totalDue == nil { totalDue = decodeDouble(from: nested, keys: ["totalDue", "total_due", "aVencer", "totalAVencer"]) }
            if overdueCount == nil { overdueCount = decodeInt(from: nested, keys: ["overdueCount", "overdue_count", "parcelasAtrasadas", "parcelas_atrasadas"]) }
            if nextDueDate == nil { nextDueDate = decodeString(from: nested, keys: ["nextDueDate", "next_due_date", "proximoVencimento", "dataProximoVencimento"]) }
            if nextDueValue == nil { nextDueValue = decodeDouble(from: nested, keys: ["nextDueValue", "next_due_value", "valorProximoVencimento", "valor_proximo_vencimento"]) }
            break
        }
        if totalOverdue == nil { totalOverdue = decodeDouble(from: container, keys: ["totalOverdue", "total_overdue", "totalVencido", "dividasVencidas"]) }
        if totalDue == nil { totalDue = decodeDouble(from: container, keys: ["totalDue", "total_due", "aVencer", "totalAVencer"]) }
        if overdueCount == nil { overdueCount = decodeInt(from: container, keys: ["overdueCount", "overdue_count", "parcelasAtrasadas", "parcelas_atrasadas"]) }
        if nextDueDate == nil { nextDueDate = decodeString(from: container, keys: ["nextDueDate", "next_due_date", "proximoVencimento", "dataProximoVencimento"]) }
        if nextDueValue == nil { nextDueValue = decodeDouble(from: container, keys: ["nextDueValue", "next_due_value", "valorProximoVencimento", "valor_proximo_vencimento"]) }
        if customerName == nil { customerName = decodeString(from: container, keys: ["customerName", "customer_name", "nome"]) }
        if recentAnnouncements == nil { recentAnnouncements = try? container.decodeIfPresent([AnnouncementDto].self, forKey: RawKey(stringValue: "recentAnnouncements")!) }
        if recentAnnouncements == nil { recentAnnouncements = try? container.decodeIfPresent([AnnouncementDto].self, forKey: RawKey(stringValue: "recent_announcements")!) }
        isEsolutionCustomer = (try? container.decodeIfPresent(Bool.self, forKey: RawKey(stringValue: "isEsolutionCustomer")!)) ?? nil

        self.customerName = customerName
        self.totalOverdue = totalOverdue
        self.totalDue = totalDue
        self.overdueCount = overdueCount
        self.dueCount = decodeInt(from: container, keys: ["dueCount", "due_count"])
        self.nextDueDate = nextDueDate
        self.nextDueValue = nextDueValue
        self.recentAnnouncements = recentAnnouncements
        self.isEsolutionCustomer = isEsolutionCustomer
    }

    private struct RawKey: CodingKey {
        let stringValue: String
        let intValue: Int? = nil
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }
}

struct AnnouncementDto: Codable {
    let id: Int
    let title: String
    let content: String
    let postDate: String
    let imageUrl: String?
    let targetCostCenterId: Int?
    /// Tipo vindo da API para diferenciar aviso vs notícia.
    /// Ex.: "notice" | "news" ou "aviso" | "noticia".
    let type: String?
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
        var request = createAuthorizedRequest(url: url)
        var (data, response) = try await URLSession.shared.data(for: request)
        guard var http = response as? HTTPURLResponse else { throw DashboardError.invalidResponse }
        if http.statusCode == 401 {
            let recovered = await AuthService.shared.recoverSessionIfNeeded()
            guard recovered else { throw DashboardError.invalidCredentials }
            request = createAuthorizedRequest(url: url)
            let retry = try await URLSession.shared.data(for: request)
            data = retry.0
            response = retry.1
            guard let retryHttp = response as? HTTPURLResponse else { throw DashboardError.invalidResponse }
            http = retryHttp
        }
        if http.statusCode == 401 { throw DashboardError.invalidCredentials }
        guard http.statusCode == 200 else { throw DashboardError.invalidResponse }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(ApiResponse<ClientDashboardDto>.self, from: data)
        guard let dto = decoded.data else { throw DashboardError.invalidResponse }

        let totalOverdue = dto.totalOverdue ?? 0
        let totalDue = dto.totalDue ?? 0
        let clientInfo = ClientInfo(
            name: dto.customerName ?? "Cliente",
            totalVentures: 0
        )
        let financialSummary = FinancialSummary(
            overdueAmount: totalOverdue,
            upcomingAmount: totalDue,
            overdueInstallments: dto.overdueCount ?? 0,
            totalAmount: totalOverdue + totalDue,
            nextDueDate: dto.nextDueDate,
            nextDueValue: dto.nextDueValue ?? 0
        )
        let notices: [Notice] = (dto.recentAnnouncements ?? []).map { a in
            let normalized = (a.type ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            let noticeType: NoticeType = {
                switch normalized {
                case "aviso", "avisos", "notice", "alerta", "notificacao":
                    return .notice
                case "noticia", "noticias", "news", "informativo":
                    return .news
                default:
                    return .news
                }
            }()
            return Notice(
                id: "\(a.id)",
                title: a.title,
                description: a.content,
                date: a.postDate,
                type: noticeType
            )
        }
        return (clientInfo, financialSummary, notices)
    }
}