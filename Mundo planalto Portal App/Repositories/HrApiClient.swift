//
//  HrApiClient.swift
//  Hard Rock Hotel & Vacation Club
//
//  Cliente HTTP mínimo para as implementações `Remote`: Bearer do Keychain,
//  envelope ApiResponse<T>, 401 → AppState.handleUnauthorized.
//

import Foundation

enum HrApiError: Error {
    case invalidURL
    case unauthorized
    case http(Int, String?)
    case decoding
    case network
}

struct HrApiClient {
    static let shared = HrApiClient()

    private let session: URLSession = .shared

    func get<T: Codable>(_ path: String, query: [String: String] = [:]) async throws -> T {
        try await request(path, method: "GET", query: query, body: Optional<Data>.none)
    }

    func post<T: Codable, B: Encodable>(_ path: String, body: B) async throws -> T {
        let data = try JSONEncoder().encode(body)
        return try await request(path, method: "POST", body: data)
    }

    func put<T: Codable, B: Encodable>(_ path: String, body: B) async throws -> T {
        let data = try JSONEncoder().encode(body)
        return try await request(path, method: "PUT", body: data)
    }

    func delete(_ path: String) async throws {
        let _: EmptyPayload = try await request(path, method: "DELETE", body: Optional<Data>.none)
    }

    private func request<T: Codable>(_ path: String, method: String, query: [String: String] = [:], body: Data?) async throws -> T {
        var components = URLComponents(string: ApiConfig.fullPath(path))
        if !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components?.url else { throw HrApiError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = PreferencesManager.shared.getAuthToken(), !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.httpBody = body

        let data: Data
        let http: HTTPURLResponse
        do {
            let (d, r) = try await session.data(for: req)
            guard let h = r as? HTTPURLResponse else { throw HrApiError.network }
            data = d
            http = h
        } catch {
            throw HrApiError.network
        }

        #if DEBUG
        print("[HrApi] \(method) \(path) → HTTP \(http.statusCode), \(data.count) bytes")
        #endif

        if http.statusCode == 401 {
            _ = await AuthService.shared.recoverSessionIfNeeded()
            throw HrApiError.unauthorized
        }
        guard (200...299).contains(http.statusCode) else {
            let msg = (try? JSONDecoder().decode(ApiResponse<EmptyPayload>.self, from: data))?.message
            throw HrApiError.http(http.statusCode, msg)
        }

        let decoder = JSONDecoder()
        if let wrapped = try? decoder.decode(ApiResponse<T>.self, from: data) {
            if let inner = wrapped.data { return inner }
            if let empty = EmptyPayload() as? T { return empty }
            throw HrApiError.decoding
        }
        if let direct = try? decoder.decode(T.self, from: data) { return direct }
        throw HrApiError.decoding
    }
}

struct EmptyPayload: Codable {}
