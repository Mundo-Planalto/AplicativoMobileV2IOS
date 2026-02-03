//
//  NewsService.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
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

struct MarkAsReadResponse: Codable {
    let success: Bool
    let message: String?
}

class NewsService {
    static let shared = NewsService()

    private let baseURL = "http://10.35.0.55:5187/api/"

    private init() {}

    private func createAuthorizedRequest(url: URL, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization header if token exists
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    func getNews(page: Int = 1, limit: Int = 20, category: String? = nil, featured: Bool? = nil) async throws -> NewsResponse {
        var urlString = baseURL + "news?page=\(page)&limit=\(limit)"

        if let category = category {
            urlString += "&category=\(category)"
        }
        if let featured = featured {
            urlString += "&featured=\(featured)"
        }

        guard let url = URL(string: urlString) else {
            throw NewsError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NewsError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                return newsResponse
            } else if httpResponse.statusCode == 401 {
                throw NewsError.invalidCredentials
            } else {
                throw NewsError.invalidResponse
            }
        } catch {
            throw NewsError.networkError
        }
    }

    func getNewsDetail(id: String) async throws -> NewsDetailResponse {
        guard let url = URL(string: baseURL + "news/\(id)") else {
            throw NewsError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NewsError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let detailResponse = try JSONDecoder().decode(NewsDetailResponse.self, from: data)
                return detailResponse
            } else if httpResponse.statusCode == 401 {
                throw NewsError.invalidCredentials
            } else if httpResponse.statusCode == 404 {
                throw NewsError.invalidResponse
            } else {
                throw NewsError.invalidResponse
            }
        } catch {
            throw NewsError.networkError
        }
    }

    func markAsRead(id: String) async throws -> MarkAsReadResponse {
        guard let url = URL(string: baseURL + "news/\(id)/read") else {
            throw NewsError.networkError
        }

        let request = createAuthorizedRequest(url: url, method: "POST")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NewsError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let markResponse = try JSONDecoder().decode(MarkAsReadResponse.self, from: data)
                return markResponse
            } else if httpResponse.statusCode == 401 {
                throw NewsError.invalidCredentials
            } else {
                throw NewsError.invalidResponse
            }
        } catch {
            throw NewsError.networkError
        }
    }

    func getCategories() async throws -> [String] {
        guard let url = URL(string: baseURL + "news/categories") else {
            throw NewsError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NewsError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let categories = try JSONDecoder().decode([String].self, from: data)
                return categories
            } else if httpResponse.statusCode == 401 {
                throw NewsError.invalidCredentials
            } else {
                throw NewsError.invalidResponse
            }
        } catch {
            throw NewsError.networkError
        }
    }
}