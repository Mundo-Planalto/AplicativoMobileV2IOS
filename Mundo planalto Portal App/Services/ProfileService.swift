//
//  ProfileService.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

enum ProfileError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

struct UserProfile: Codable {
    let id: String
    let name: String
    let cpf: String
    let email: String?
    let phone: String?
    let address: String?
    let registrationDate: String
    let status: String
}

struct UpdateProfileRequest: Codable {
    let name: String?
    let email: String?
    let phone: String?
    let address: String?
}

struct ProfileResponse: Codable {
    let profile: UserProfile
    let success: Bool
    let message: String?
}

struct UpdateProfileResponse: Codable {
    let success: Bool
    let message: String?
}

class ProfileService {
    static let shared = ProfileService()

    private var baseURL: String { ApiConfig.baseURL + "/" }

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

    /// GET /api/auth/me - retorna perfil do usuário atual
    func getProfile() async throws -> ProfileResponse {
        guard let url = URL(string: baseURL + "auth/me") else { throw ProfileError.networkError }
        let request = createAuthorizedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ProfileError.invalidResponse }
        if http.statusCode == 401 { throw ProfileError.invalidCredentials }
        guard http.statusCode == 200 else { throw ProfileError.invalidResponse }
        let decoded = try JSONDecoder().decode(ApiResponse<UserDto>.self, from: data)
        guard let user = decoded.data else { throw ProfileError.invalidResponse }
        let profile = UserProfile(
            id: "\(user.id)",
            name: user.name ?? "",
            cpf: user.document,
            email: user.email,
            phone: nil,
            address: nil,
            registrationDate: "",
            status: "Ativo"
        )
        return ProfileResponse(profile: profile, success: true, message: nil)
    }

    func updateProfile(updates: UpdateProfileRequest) async throws -> UpdateProfileResponse {
        guard let url = URL(string: baseURL + "profile") else {
            throw ProfileError.networkError
        }

        let body = try JSONEncoder().encode(updates)
        let request = createAuthorizedRequest(url: url, method: "PUT", body: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ProfileError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let updateResponse = try JSONDecoder().decode(UpdateProfileResponse.self, from: data)
                return updateResponse
            } else if httpResponse.statusCode == 401 {
                throw ProfileError.invalidCredentials
            } else {
                throw ProfileError.invalidResponse
            }
        } catch {
            throw ProfileError.networkError
        }
    }

    /// POST /api/auth/change-password
    func changePassword(currentPassword: String, newPassword: String, confirmPassword: String) async throws -> UpdateProfileResponse {
        guard let url = URL(string: baseURL + "auth/change-password") else { throw ProfileError.networkError }
        let requestBody = ["currentPassword": currentPassword, "newPassword": newPassword, "confirmPassword": confirmPassword]
        let body = try JSONEncoder().encode(requestBody)
        let request = createAuthorizedRequest(url: url, method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ProfileError.invalidResponse }
        if http.statusCode == 401 { throw ProfileError.invalidCredentials }
        guard http.statusCode == 200 else {
            if let api = try? JSONDecoder().decode(ApiResponse<Empty>.self, from: data), let msg = api.message {
                throw ProfileError.invalidResponse
            }
            throw ProfileError.invalidResponse
        }
        return UpdateProfileResponse(success: true, message: nil)
    }
}

private struct Empty: Codable {}