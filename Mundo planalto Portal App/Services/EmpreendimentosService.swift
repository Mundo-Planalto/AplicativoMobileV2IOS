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

/// Item do photoBook em GET /api/ventures
struct PhotoBookItemDto: Codable {
    let id: Int
    let photoUrl: String
    let mediaType: String
    let youtubeUrl: String?
    let createdAt: String?
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
    let photoBook: [PhotoBookItemDto]?
    let city: String?
    let state: String?
    let instagramUrl: String?
    let youtubeUrl: String?
    let whatsappChannelUrl: String?
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
    let videoUrl: String?
    let youtubeUrl: String?
    let postDate: String
}

class EmpreendimentosService {
    static let shared = EmpreendimentosService()
    private init() {}

    private var baseURL: String { ApiConfig.baseURL + "/" }

    private func empreendimentosCacheKey() -> String {
        let userId = PreferencesManager.shared.getUserId() ?? "anon"
        return "empreendimentos|user:\(userId)"
    }

    func getEmpreendimentosCached() -> EmpreendimentosResponse? {
        let cacheKey = empreendimentosCacheKey()
        return ApiCache.shared.get(EmpreendimentosResponse.self, key: cacheKey)
    }

    private func createAuthorizedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// Constrói URL completa para imagem/vídeo (path relativo do servidor). Evita barra dupla.
    private static func fullMediaURL(_ path: String?) -> String {
        guard let path = path, !path.trimmingCharacters(in: .whitespaces).isEmpty else { return "" }
        let trimmed = path.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") { return trimmed }
        var base = ApiConfig.baseURL
        if base.hasSuffix("/") { base = String(base.dropLast()) }
        let baseHost = base.replacingOccurrences(of: "/api", with: "")
        let pathNorm = trimmed.hasPrefix("/") ? trimmed : "/" + trimmed
        if baseHost.hasSuffix("/") {
            return baseHost + pathNorm.dropFirst()
        }
        return baseHost + pathNorm
    }

    /// Exposto para montar URLs de mídia em updates (ex.: ViewModel).
    static func mediaURL(for path: String?) -> String {
        fullMediaURL(path)
    }

    private func fullImageURL(_ path: String?) -> String {
        Self.fullMediaURL(path)
    }

    /// GET /api/ventures ou /api/customers/ventures - lista empreendimentos do cliente
    func getEmpreendimentos(
        useCache: Bool = true,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 10 * 60
    ) async throws -> EmpreendimentosResponse {
        let cacheKey = empreendimentosCacheKey()
        if useCache, !forceRefresh,
           let cached: EmpreendimentosResponse = ApiCache.shared.get(EmpreendimentosResponse.self, key: cacheKey) {
            return cached
        }

        // Alguns ambientes expõem /ventures e outros /customers/ventures.
        let pathsToTry = ["ventures", "customers/ventures"]
        var lastError: Error = EmpreendimentosError.invalidResponse

        for p in pathsToTry {
            let path = baseURL + p
            guard let url = URL(string: path) else {
                lastError = EmpreendimentosError.networkError
                continue
            }
            var request = createAuthorizedRequest(url: url)
            var (data, response) = try await URLSession.shared.data(for: request)
            guard var http = response as? HTTPURLResponse else {
                lastError = EmpreendimentosError.invalidResponse
                continue
            }
            if http.statusCode == 401 {
                let recovered = await AuthService.shared.recoverSessionIfNeeded()
                guard recovered else { throw EmpreendimentosError.invalidCredentials }
                request = createAuthorizedRequest(url: url)
                let retry = try await URLSession.shared.data(for: request)
                data = retry.0
                response = retry.1
                guard let retryHttp = response as? HTTPURLResponse else {
                    lastError = EmpreendimentosError.invalidResponse
                    continue
                }
                http = retryHttp
            }
            if http.statusCode == 401 { throw EmpreendimentosError.invalidCredentials }
            guard http.statusCode == 200 else {
                lastError = EmpreendimentosError.invalidResponse
                continue
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            // Padrão: ApiResponse<[CostCenterDto]>
            if let decoded = try? decoder.decode(ApiResponse<[CostCenterDto]>.self, from: data),
               let list = decoded.data {
                let ventures = mapCostCenters(list)
                let response = EmpreendimentosResponse(empreendimentos: ventures, totalCount: ventures.count, success: true, message: nil)
                if useCache {
                    ApiCache.shared.set(response, key: cacheKey, ttl: cacheTTL)
                }
                return response
            }
            // Fallback: array puro
            if let list = try? decoder.decode([CostCenterDto].self, from: data) {
                let ventures = mapCostCenters(list)
                let response = EmpreendimentosResponse(empreendimentos: ventures, totalCount: ventures.count, success: true, message: nil)
                if useCache {
                    ApiCache.shared.set(response, key: cacheKey, ttl: cacheTTL)
                }
                return response
            }

            lastError = EmpreendimentosError.invalidResponse
        }

        // Se falhar, tenta reaproveitar cache (evita tela vazia).
        if useCache {
            if let cached: EmpreendimentosResponse = ApiCache.shared.get(EmpreendimentosResponse.self, key: cacheKey) {
                return cached
            }
        }

        throw lastError
    }

    private func mapCostCenters(_ list: [CostCenterDto]) -> [Venture] {
        let ventures = list.map { dto in
            let photoBook = (dto.photoBook ?? []).map { p in
                PhotoBookItem(
                    id: p.id,
                    photoUrl: Self.fullMediaURL(p.photoUrl),
                    mediaType: p.mediaType,
                    youtubeUrl: p.youtubeUrl,
                    createdAt: p.createdAt
                )
            }
            return Venture(
                id: "\(dto.id)",
                name: dto.name,
                imageUrl: Self.fullMediaURL(dto.imageUrl).isEmpty ? "venture\(dto.id)" : Self.fullMediaURL(dto.imageUrl),
                progress: 0,
                lastUpdate: "",
                photoBook: photoBook.isEmpty ? nil : photoBook,
                city: dto.city,
                state: dto.state,
                instagramUrl: dto.instagramUrl,
                youtubeUrl: dto.youtubeUrl,
                whatsappChannelUrl: dto.whatsappChannelUrl
            )
        }
        return ventures
    }

    /// GET /api/costcenters/{id} - detalhe (fallback se não houver endpoint específico de detalhe)
    func getEmpreendimentoDetail(id: String) async throws -> EmpreendimentoDetailResponse {
        guard let url = URL(string: baseURL + "costcenters/\(id)") else { throw EmpreendimentosError.networkError }
        var request = createAuthorizedRequest(url: url)
        var (data, response) = try await URLSession.shared.data(for: request)
        guard var http = response as? HTTPURLResponse else { throw EmpreendimentosError.invalidResponse }
        if http.statusCode == 401 {
            let recovered = await AuthService.shared.recoverSessionIfNeeded()
            guard recovered else { throw EmpreendimentosError.invalidCredentials }
            request = createAuthorizedRequest(url: url)
            let retry = try await URLSession.shared.data(for: request)
            data = retry.0
            response = retry.1
            guard let retryHttp = response as? HTTPURLResponse else { throw EmpreendimentosError.invalidResponse }
            http = retryHttp
        }
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