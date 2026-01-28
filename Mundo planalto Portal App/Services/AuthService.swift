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
    
    func login(cpf: String, password: String) async throws -> LoginResponse {
        // TODO: Substituir pela URL real da API
        guard let url = URL(string: "https://api.mundoplanalto.com.br/auth/login") else {
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
}
