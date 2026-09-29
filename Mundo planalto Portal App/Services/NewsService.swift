//
//  NewsService.swift
//  Mundo planalto Portal App
//
//  GET /api/announcements (opcional costCenterId)
//

import Foundation

enum NewsError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

struct NewsArticle: Codable {
    let id: String
    let title: String
    let content: String
    let summary: String?
    let author: String?
    let publishedDate: String
    let category: String
    let tags: [String]?
    let imageUrl: String?
    let isFeatured: Bool
    let readCount: Int
}

struct NewsResponse: Codable {
    let news: [NewsArticle]
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
    let success: Bool
    let message: String?
}

struct NewsDetailResponse: Codable {
    let news: NewsArticle
    let success: Bool
    let message: String?
}

/// Item de GET /api/announcements (antes declarado no DashboardService removido).
struct AnnouncementDto: Codable {
    let id: Int
    let title: String
    let content: String
    let postDate: String
    let imageUrl: String?
    let targetCostCenterId: Int?
    /// Tipo vindo da API para diferenciar aviso vs notícia ("notice" | "news" ou "aviso" | "noticia").
    let type: String?
}

class NewsService {
    static let shared = NewsService()
    private init() {}

    private var baseURL: String { ApiConfig.baseURL + "/" }

    private func mapNoticeType(_ rawType: String?) -> NoticeType {
        guard let rawType else { return .news }
        let normalized = rawType
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)

        switch normalized {
        case "aviso", "avisos", "notice", "notificacao", "alerta":
            return .notice
        case "noticia", "noticias", "news", "informativo":
            return .news
        default:
            return .news
        }
    }

    private func createAuthorizedRequest(url: URL, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body { request.httpBody = body }
        return request
    }

    /// GET /api/announcements?costCenterId= (opcional)
    func getAnnouncements(costCenterId: Int? = nil) async throws -> [Notice] {
        var urlString = baseURL + "announcements"
        if let id = costCenterId {
            urlString += "?costCenterId=\(id)"
        }
        guard let url = URL(string: urlString) else { throw NewsError.networkError }
        var request = createAuthorizedRequest(url: url)
        var (data, response) = try await URLSession.shared.data(for: request)
        if (response as? HTTPURLResponse)?.statusCode == 401 {
            let recovered = await AuthService.shared.recoverSessionIfNeeded()
            guard recovered else { throw NewsError.invalidCredentials }
            request = createAuthorizedRequest(url: url)
            let retry = try await URLSession.shared.data(for: request)
            data = retry.0
            response = retry.1
        }
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            if (response as? HTTPURLResponse)?.statusCode == 401 { throw NewsError.invalidCredentials }
            throw NewsError.invalidResponse
        }
        let decoded = try JSONDecoder().decode(ApiResponse<[AnnouncementDto]>.self, from: data)
        return (decoded.data ?? []).map { a in
            Notice(
                id: "\(a.id)",
                title: a.title,
                description: a.content,
                date: a.postDate,
                type: mapNoticeType(a.type)
            )
        }
    }

    func getNews(page: Int = 1, limit: Int = 20, category: String? = nil, featured: Bool? = nil) async throws -> NewsResponse {
        let notices = try await getAnnouncements()
        let news = notices.enumerated().map { i, n in
            NewsArticle(id: n.id, title: n.title, content: n.description, summary: nil, author: nil, publishedDate: n.date, category: "Geral", tags: nil, imageUrl: nil, isFeatured: false, readCount: 0)
        }
        return NewsResponse(news: news, totalCount: news.count, currentPage: 1, totalPages: 1, success: true, message: nil)
    }

    func getNewsDetail(id: String) async throws -> NewsDetailResponse {
        let notices = try await getAnnouncements()
        guard let n = notices.first(where: { $0.id == id }) else { throw NewsError.invalidResponse }
        let article = NewsArticle(id: n.id, title: n.title, content: n.description, summary: nil, author: nil, publishedDate: n.date, category: "Geral", tags: nil, imageUrl: nil, isFeatured: false, readCount: 0)
        return NewsDetailResponse(news: article, success: true, message: nil)
    }
}