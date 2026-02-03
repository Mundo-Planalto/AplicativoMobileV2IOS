//
//  PDFService.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import Combine

enum PDFError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
    case invalidURL
}

struct PDFDocument: Codable {
    let id: String
    let title: String
    let description: String?
    let fileName: String
    let downloadUrl: String
    let fileSize: Int64?
    let uploadedDate: String
    let category: String
}

struct PDFListResponse: Codable {
    let documents: [PDFDocument]
    let totalCount: Int
    let success: Bool
    let message: String?
}

struct PDFDownloadResponse: Codable {
    let downloadUrl: String
    let expiresAt: String?
    let success: Bool
    let message: String?
}

struct PDFUploadResponse: Codable {
    let document: PDFDocument
    let success: Bool
    let message: String?
}

class PDFService {
    static let shared = PDFService()

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

    func getPDFDocuments(category: String? = nil, page: Int = 1, limit: Int = 20) async throws -> PDFListResponse {
        var urlString = baseURL + "pdfs?page=\(page)&limit=\(limit)"

        if let category = category {
            urlString += "&category=\(category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }

        guard let url = URL(string: urlString) else {
            throw PDFError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PDFError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let pdfResponse = try JSONDecoder().decode(PDFListResponse.self, from: data)
                return pdfResponse
            } else if httpResponse.statusCode == 401 {
                throw PDFError.invalidCredentials
            } else {
                throw PDFError.invalidResponse
            }
        } catch {
            throw PDFError.networkError
        }
    }

    func getPDFDownloadUrl(documentId: String) async throws -> PDFDownloadResponse {
        guard let url = URL(string: baseURL + "pdfs/\(documentId)/download") else {
            throw PDFError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PDFError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let downloadResponse = try JSONDecoder().decode(PDFDownloadResponse.self, from: data)
                return downloadResponse
            } else if httpResponse.statusCode == 401 {
                throw PDFError.invalidCredentials
            } else if httpResponse.statusCode == 404 {
                throw PDFError.invalidResponse
            } else {
                throw PDFError.invalidResponse
            }
        } catch {
            throw PDFError.networkError
        }
    }

    func downloadPDF(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw PDFError.invalidURL
        }

        var request = URLRequest(url: url)

        // Add authorization header if token exists for protected downloads
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PDFError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                return data
            } else if httpResponse.statusCode == 401 {
                throw PDFError.invalidCredentials
            } else {
                throw PDFError.invalidResponse
            }
        } catch {
            throw PDFError.networkError
        }
    }

    func getPDFCategories() async throws -> [String] {
        guard let url = URL(string: baseURL + "pdfs/categories") else {
            throw PDFError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PDFError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let categories = try JSONDecoder().decode([String].self, from: data)
                return categories
            } else if httpResponse.statusCode == 401 {
                throw PDFError.invalidCredentials
            } else {
                throw PDFError.invalidResponse
            }
        } catch {
            throw PDFError.networkError
        }
    }

    // Helper method to create a shareable URL for PDFs
    func createShareablePDFUrl(documentId: String, expiresInHours: Int = 24) async throws -> String {
        guard let url = URL(string: baseURL + "pdfs/\(documentId)/share?expiresIn=\(expiresInHours)") else {
            throw PDFError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PDFError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let shareResponse = try JSONDecoder().decode([String: String].self, from: data)
                if let shareUrl = shareResponse["shareUrl"] {
                    return shareUrl
                } else {
                    throw PDFError.invalidResponse
                }
            } else if httpResponse.statusCode == 401 {
                throw PDFError.invalidCredentials
            } else {
                throw PDFError.invalidResponse
            }
        } catch {
            throw PDFError.networkError
        }
    }
}