//
//  ExtratoService.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

enum ExtratoError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

struct ExtratoItem: Codable {
    let id: String
    let date: String
    let description: String
    let ventureName: String
    let installmentNumber: String
    let amount: Double
    let type: TransactionType
    let status: PaymentStatus
}

enum TransactionType: String, Codable {
    case payment
    case refund
    case adjustment
    case fee
}

struct ExtratoResponse: Codable {
    let transactions: [ExtratoItem]
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
    let success: Bool
    let message: String?
}

struct PDFExtratoResponse: Codable {
    let pdfUrl: String
    let success: Bool
    let message: String?
}

class ExtratoService {
    static let shared = ExtratoService()

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

    func getExtrato(page: Int = 1, limit: Int = 20, startDate: String? = nil, endDate: String? = nil) async throws -> ExtratoResponse {
        var urlString = baseURL + "extrato?page=\(page)&limit=\(limit)"

        if let startDate = startDate {
            urlString += "&startDate=\(startDate)"
        }
        if let endDate = endDate {
            urlString += "&endDate=\(endDate)"
        }

        guard let url = URL(string: urlString) else {
            throw ExtratoError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ExtratoError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let extratoResponse = try JSONDecoder().decode(ExtratoResponse.self, from: data)
                return extratoResponse
            } else if httpResponse.statusCode == 401 {
                throw ExtratoError.invalidCredentials
            } else {
                throw ExtratoError.invalidResponse
            }
        } catch {
            throw ExtratoError.networkError
        }
    }

    func generateExtratoPDF(startDate: String? = nil, endDate: String? = nil) async throws -> PDFExtratoResponse {
        var urlString = baseURL + "extrato/pdf"

        if let startDate = startDate {
            urlString += "?startDate=\(startDate)"
        }
        if let endDate = endDate {
            urlString += "&endDate=\(endDate)"
        }

        guard let url = URL(string: urlString) else {
            throw ExtratoError.networkError
        }

        let request = createAuthorizedRequest(url: url, method: "POST")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ExtratoError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let pdfResponse = try JSONDecoder().decode(PDFExtratoResponse.self, from: data)
                return pdfResponse
            } else if httpResponse.statusCode == 401 {
                throw ExtratoError.invalidCredentials
            } else {
                throw ExtratoError.invalidResponse
            }
        } catch {
            throw ExtratoError.networkError
        }
    }

    func getInformeRendimentos(year: String) async throws -> PDFExtratoResponse {
        guard let url = URL(string: baseURL + "informe_rendimentos/\(year)") else {
            throw ExtratoError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ExtratoError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let pdfResponse = try JSONDecoder().decode(PDFExtratoResponse.self, from: data)
                return pdfResponse
            } else if httpResponse.statusCode == 401 {
                throw ExtratoError.invalidCredentials
            } else {
                throw ExtratoError.invalidResponse
            }
        } catch {
            throw ExtratoError.networkError
        }
    }
}