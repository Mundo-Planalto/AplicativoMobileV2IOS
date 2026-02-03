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

    private let baseURL = "http://10.35.0.55:5187/api/"

    private init() {}

    func login(cpf: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: baseURL + "login") else {
            throw AuthError.networkError
        }
        
        let requestBody = LoginRequest(cpf: CPFMask.unformat(cpf), password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                return loginResponse
            } else {
                throw AuthError.invalidCredentials
            }
        } catch {
            throw AuthError.networkError
        }
    }

    func primeiroAcesso(cpf: String, password: String, confirmPassword: String) async throws -> RegisterResponse {
        guard let url = URL(string: baseURL + "primeiro_acesso") else {
            throw AuthError.networkError
        }

        let requestBody = RegisterRequest(cpf: CPFMask.unformat(cpf), password: password, confirmPassword: confirmPassword)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }

            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                return registerResponse
            } else {
                throw AuthError.invalidCredentials
            }
        } catch {
            throw AuthError.networkError
        }
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
