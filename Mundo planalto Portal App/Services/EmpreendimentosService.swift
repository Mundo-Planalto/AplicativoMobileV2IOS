//
//  EmpreendimentosService.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

enum EmpreendimentosError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

struct EmpreendimentoDetail: Codable {
    let id: String
    let name: String
    let description: String
    let imageUrl: String
    let progress: Double
    let lastUpdate: String
    let status: String
    let location: String
    let startDate: String
    let estimatedCompletion: String
    let updates: [VentureUpdate]
}

struct EmpreendimentosResponse: Codable {
    let empreendimentos: [Venture]
    let totalCount: Int
    let success: Bool
    let message: String?
}

struct EmpreendimentoDetailResponse: Codable {
    let empreendimento: EmpreendimentoDetail
    let success: Bool
    let message: String?
}

class EmpreendimentosService {
    static let shared = EmpreendimentosService()

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

    func getEmpreendimentos() async throws -> EmpreendimentosResponse {
        guard let url = URL(string: baseURL + "empreendimentos") else {
            throw EmpreendimentosError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw EmpreendimentosError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let empreendimentosResponse = try JSONDecoder().decode(EmpreendimentosResponse.self, from: data)
                return empreendimentosResponse
            } else if httpResponse.statusCode == 401 {
                throw EmpreendimentosError.invalidCredentials
            } else {
                throw EmpreendimentosError.invalidResponse
            }
        } catch {
            throw EmpreendimentosError.networkError
        }
    }

    func getEmpreendimentoDetail(id: String) async throws -> EmpreendimentoDetailResponse {
        guard let url = URL(string: baseURL + "empreendimentos/\(id)") else {
            throw EmpreendimentosError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw EmpreendimentosError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let detailResponse = try JSONDecoder().decode(EmpreendimentoDetailResponse.self, from: data)
                return detailResponse
            } else if httpResponse.statusCode == 401 {
                throw EmpreendimentosError.invalidCredentials
            } else if httpResponse.statusCode == 404 {
                throw EmpreendimentosError.invalidResponse
            } else {
                throw EmpreendimentosError.invalidResponse
            }
        } catch {
            throw EmpreendimentosError.networkError
        }
    }
}