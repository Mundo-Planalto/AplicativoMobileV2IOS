//
//  SystemService.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

enum SystemError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

struct AppVersion: Codable {
    let version: String
    let buildNumber: String
    let releaseDate: String
    let isMandatory: Bool
    let changelog: String?
}

struct SystemInfo: Codable {
    let appVersion: String
    let apiVersion: String
    let serverStatus: String
    let lastMaintenance: String?
    let supportedFeatures: [String]
}

struct ContactInfo: Codable {
    let phone: String?
    let email: String?
    let whatsapp: String?
    let address: String?
    let businessHours: String?
}

struct TermsAndPrivacy: Codable {
    let termsOfUse: String
    let privacyPolicy: String
    let lastUpdated: String
}

struct SystemResponse: Codable {
    let success: Bool
    let message: String?
    let data: String? // Generic data field for various responses
}

struct VersionCheckResponse: Codable {
    let currentVersion: AppVersion
    let updateAvailable: Bool
    let updateUrl: String?
    let success: Bool
    let message: String?
}

struct FeedbackRequest: Codable {
    let type: FeedbackType
    let subject: String
    let message: String
    let rating: Int?
}

enum FeedbackType: String, Codable {
    case bug
    case suggestion
    case question
    case praise
    case other
}

class SystemService {
    static let shared = SystemService()

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

    func getSystemInfo() async throws -> SystemInfo {
        guard let url = URL(string: baseURL + "system/info") else {
            throw SystemError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SystemError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let systemInfo = try JSONDecoder().decode(SystemInfo.self, from: data)
                return systemInfo
            } else {
                throw SystemError.invalidResponse
            }
        } catch {
            throw SystemError.networkError
        }
    }

    func checkForUpdates(currentVersion: String) async throws -> VersionCheckResponse {
        guard let url = URL(string: baseURL + "system/check-update?version=\(currentVersion)") else {
            throw SystemError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SystemError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let versionResponse = try JSONDecoder().decode(VersionCheckResponse.self, from: data)
                return versionResponse
            } else {
                throw SystemError.invalidResponse
            }
        } catch {
            throw SystemError.networkError
        }
    }

    func getContactInfo() async throws -> ContactInfo {
        guard let url = URL(string: baseURL + "system/contact") else {
            throw SystemError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SystemError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let contactInfo = try JSONDecoder().decode(ContactInfo.self, from: data)
                return contactInfo
            } else {
                throw SystemError.invalidResponse
            }
        } catch {
            throw SystemError.networkError
        }
    }

    func getTermsAndPrivacy() async throws -> TermsAndPrivacy {
        guard let url = URL(string: baseURL + "system/terms-privacy") else {
            throw SystemError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SystemError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let termsResponse = try JSONDecoder().decode(TermsAndPrivacy.self, from: data)
                return termsResponse
            } else {
                throw SystemError.invalidResponse
            }
        } catch {
            throw SystemError.networkError
        }
    }

    func sendFeedback(feedback: FeedbackRequest) async throws -> SystemResponse {
        guard let url = URL(string: baseURL + "system/feedback") else {
            throw SystemError.networkError
        }

        let body = try JSONEncoder().encode(feedback)
        let request = createAuthorizedRequest(url: url, method: "POST", body: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SystemError.invalidResponse
            }

            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                let feedbackResponse = try JSONDecoder().decode(SystemResponse.self, from: data)
                return feedbackResponse
            } else if httpResponse.statusCode == 401 {
                throw SystemError.invalidCredentials
            } else {
                throw SystemError.invalidResponse
            }
        } catch {
            throw SystemError.networkError
        }
    }

    func reportBug(subject: String, description: String) async throws -> SystemResponse {
        let feedback = FeedbackRequest(
            type: .bug,
            subject: subject,
            message: description,
            rating: nil
        )
        return try await sendFeedback(feedback: feedback)
    }

    func sendSuggestion(subject: String, description: String) async throws -> SystemResponse {
        let feedback = FeedbackRequest(
            type: .suggestion,
            subject: subject,
            message: description,
            rating: nil
        )
        return try await sendFeedback(feedback: feedback)
    }
}