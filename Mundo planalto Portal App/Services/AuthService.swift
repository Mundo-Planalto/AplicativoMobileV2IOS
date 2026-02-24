//
//  AuthService.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

enum AuthError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

class AuthService {
    static let shared = AuthService()
    private init() {}

    private var baseURL: String { ApiConfig.baseURL + "/" }

    func login(document: String, password: String) async throws -> LoginResponse {
        let loginURLString = baseURL + "auth/login"
        guard let url = URL(string: loginURLString) else {
            print("[AuthService] ❌ URL inválida: \(loginURLString)")
            throw AuthError.networkError
        }

        print("[AuthService] 📤 Login → \(url.absoluteString)")

        let requestBody = LoginRequest(document: CPFMask.unformat(document), password: password)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let data: Data
        let httpResponse: HTTPURLResponse
        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                print("[AuthService] ❌ Resposta não é HTTPURLResponse")
                throw AuthError.invalidResponse
            }
            data = responseData
            httpResponse = http
        } catch {
            print("[AuthService] ❌ Erro de rede: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                print("[AuthService]    Código: \(urlError.code.rawValue), descrição: \(urlError.errorUserInfo)")
            }
            throw AuthError.networkError
        }

        let statusCode = httpResponse.statusCode
        let responseBody = String(data: data, encoding: .utf8) ?? "(não foi possível converter para string)"

        print("[AuthService] 📥 Status HTTP: \(statusCode)")
        if !data.isEmpty {
            print("[AuthService] 📥 Corpo da resposta: \(responseBody)")
        }

        let decoder = JSONDecoder()
        if let loginResponse = try? decoder.decode(LoginResponse.self, from: data) {
            if !loginResponse.success {
                print("[AuthService] ⚠️ API retornou success=false, message: \(loginResponse.message ?? "nil")")
            }
            return loginResponse
        }

        if statusCode == 200 {
            print("[AuthService] ❌ Status 200 mas corpo não é LoginResponse válido. Corpo: \(responseBody)")
            throw AuthError.invalidResponse
        }

        // Status 4xx/5xx: tenta extrair "message" do JSON (ex.: 404 "Recurso não encontrado")
        var messageFromAPI: String?
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let msg = json["message"] as? String {
            messageFromAPI = msg
            print("[AuthService] ⚠️ Status \(statusCode), mensagem da API: \(msg)")
        } else {
            print("[AuthService] ⚠️ Status \(statusCode), corpo não decodificou. Usando mensagem padrão.")
        }

        return LoginResponse(
            token: nil,
            message: messageFromAPI ?? (statusCode == 404 ? "Recurso não encontrado." : "Usuário ou senha incorreta."),
            success: false,
            user: nil
        )
    }

    /// POST /api/auth/register - Registro de novo usuário (primeiro acesso).
    func primeiroAcesso(document: String, password: String, confirmPassword: String) async throws -> RegisterResponse {
        guard let url = URL(string: baseURL + "auth/register") else {
            throw AuthError.networkError
        }

        let requestBody = RegisterRequest(document: CPFMask.unformat(document), password: password, confirmPassword: confirmPassword)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.invalidResponse }

        let decoder = JSONDecoder()
        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            if let wrapped = try? decoder.decode(ApiResponse<RegisterResponse>.self, from: data), let inner = wrapped.data {
                return inner
            }
            if let direct = try? decoder.decode(RegisterResponse.self, from: data) {
                return direct
            }
        }
        if let api = try? decoder.decode(ApiResponse<RegisterResponse>.self, from: data), !api.success {
            throw AuthError.invalidCredentials
        }
        throw AuthError.networkError
    }

    /// GET /api/auth/me - Retorna o usuário atual (requer Bearer token).
    func getMe() async throws -> UserDto? {
        guard let url = URL(string: baseURL + "auth/me"),
              let token = PreferencesManager.shared.getAuthToken() else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
        let decoded = try? JSONDecoder().decode(ApiResponse<UserDto>.self, from: data)
        return decoded?.data
    }

    func logout() async throws -> LogoutResponse {
        guard let url = URL(string: baseURL + "logout") else {
            throw AuthError.networkError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization header if token exists
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard response is HTTPURLResponse else {
                throw AuthError.invalidResponse
            }

            let logoutResponse = try JSONDecoder().decode(LogoutResponse.self, from: data)
            return logoutResponse
        } catch {
            throw AuthError.networkError
        }
    }
}
