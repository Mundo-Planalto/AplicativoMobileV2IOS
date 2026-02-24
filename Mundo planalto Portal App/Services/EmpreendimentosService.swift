//
//  EmpreendimentosService.swift
//  Mundo planalto Portal App
//
//  GET /api/ventures, /api/customers/ventures, /api/ventureupdates/venture/{id}
//

import Foundation

enum EmpreendimentosError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

/// Resposta da API: GET /api/ventures ou /api/customers/ventures
struct CostCenterDto: Codable {
    let id: Int
    let name: String
    let description: String?
    let type: String?
    let imageUrl: String?
    let companyName: String?
    let isActive: Bool?
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

/// GET /api/ventureupdates/venture/{ventureId}
struct VentureUpdateDto: Codable {
    let id: Int
    let costCenterId: Int
    let costCenterName: String
    let title: String
    let content: String
    let imageUrl: String?
    let postDate: String
}

class EmpreendimentosService {
    static let shared = EmpreendimentosService()
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

    private func fullImageURL(_ path: String?) -> String {
        guard let path = path, !path.isEmpty else { return "" }
        if path.hasPrefix("http") { return path }
        let base = ApiConfig.baseURL.hasSuffix("/") ? String(ApiConfig.baseURL.dropLast()) : ApiConfig.baseURL
        let baseHost = base.replacingOccurrences(of: "/api", with: "")
        return baseHost + (path.hasPrefix("/") ? path : "/" + path)
    }

    /// GET /api/ventures ou /api/customers/ventures - lista empreendimentos do cliente
    func getEmpreendimentos() async throws -> EmpreendimentosResponse {
        let path = baseURL + "ventures"
        guard let url = URL(string: path) else { throw EmpreendimentosError.networkError }
        let request = createAuthorizedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw EmpreendimentosError.invalidResponse }
        if http.statusCode == 401 { throw EmpreendimentosError.invalidCredentials }
        guard http.statusCode == 200 else { throw EmpreendimentosError.invalidResponse }

        let decoded = try JSONDecoder().decode(ApiResponse<[CostCenterDto]>.self, from: data)
        guard let list = decoded.data else { throw EmpreendimentosError.invalidResponse }
        let ventures = list.map { dto in
            Venture(
                id: "\(dto.id)",
                name: dto.name,
                imageUrl: fullImageURL(dto.imageUrl).isEmpty ? "venture\(dto.id)" : fullImageURL(dto.imageUrl),
                progress: 0,
                lastUpdate: ""
            )
        }
        return EmpreendimentosResponse(empreendimentos: ventures, totalCount: ventures.count, success: true, message: nil)
    }

    /// GET /api/costcenters/{id} - detalhe (fallback se não houver endpoint específico de detalhe)
    func getEmpreendimentoDetail(id: String) async throws -> EmpreendimentoDetailResponse {
        guard let url = URL(string: baseURL + "costcenters/\(id)") else { throw EmpreendimentosError.networkError }
        let request = createAuthorizedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw EmpreendimentosError.invalidResponse }
        if http.statusCode == 401 { throw EmpreendimentosError.invalidCredentials }
        if http.statusCode == 404 { throw EmpreendimentosError.invalidResponse }
        guard http.statusCode == 200 else { throw EmpreendimentosError.invalidResponse }

        let decoded = try JSONDecoder().decode(ApiResponse<CostCenterDto>.self, from: data)
        guard let dto = decoded.data else { throw EmpreendimentosError.invalidResponse }
        let detail = EmpreendimentoDetail(
            id: "\(dto.id)",
            name: dto.name,
            description: dto.description ?? "",
            imageUrl: fullImageURL(dto.imageUrl),
            progress: 0,
            lastUpdate: "",
            status: "Ativo",
            location: "",
            startDate: "",
            estimatedCompletion: "",
            updates: []
        )
        return EmpreendimentoDetailResponse(empreendimento: detail, success: true, message: nil)
    }

    /// GET /api/ventureupdates/venture/{ventureId} - atualizações de um empreendimento
    func getVentureUpdates(ventureId: Int) async throws -> [VentureUpdateDto] {
        let path = baseURL + "ventureupdates/venture/\(ventureId)"
        guard let url = URL(string: path) else { throw EmpreendimentosError.networkError }
        let request = createAuthorizedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return [] }
        let decoded = try? JSONDecoder().decode(ApiResponse<[VentureUpdateDto]>.self, from: data)
        return decoded?.data ?? []
    }
}