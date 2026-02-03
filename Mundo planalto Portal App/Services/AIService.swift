//
//  AIService.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

enum AIError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

struct AIChatMessage: Codable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: String
    let isTyping: Bool?
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

struct ChatRequest: Codable {
    let message: String
    let context: String?
}

struct ChatResponse: Codable {
    let message: AIChatMessage
    let success: Bool
    let messageText: String?
}

struct ChatHistoryResponse: Codable {
    let messages: [AIChatMessage]
    let totalCount: Int
    let success: Bool
    let message: String?
}

struct AICapabilities: Codable {
    let canAnswerQuestions: Bool
    let canProvideFinancialAdvice: Bool
    let canHelpWithNavigation: Bool
    let supportedTopics: [String]
}

struct AICapabilitiesResponse: Codable {
    let capabilities: AICapabilities
    let success: Bool
    let message: String?
}

class AIService {
    static let shared = AIService()

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

    func sendMessage(message: String, context: String? = nil) async throws -> ChatResponse {
        guard let url = URL(string: baseURL + "ai/chat") else {
            throw AIError.networkError
        }

        let requestBody = ChatRequest(message: message, context: context)
        let body = try JSONEncoder().encode(requestBody)
        let request = createAuthorizedRequest(url: url, method: "POST", body: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                return chatResponse
            } else if httpResponse.statusCode == 401 {
                throw AIError.invalidCredentials
            } else {
                throw AIError.invalidResponse
            }
        } catch {
            throw AIError.networkError
        }
    }

    func getChatHistory(limit: Int = 50, offset: Int = 0) async throws -> ChatHistoryResponse {
        guard let url = URL(string: baseURL + "ai/chat/history?limit=\(limit)&offset=\(offset)") else {
            throw AIError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let historyResponse = try JSONDecoder().decode(ChatHistoryResponse.self, from: data)
                return historyResponse
            } else if httpResponse.statusCode == 401 {
                throw AIError.invalidCredentials
            } else {
                throw AIError.invalidResponse
            }
        } catch {
            throw AIError.networkError
        }
    }

    func clearChatHistory() async throws -> ChatResponse {
        guard let url = URL(string: baseURL + "ai/chat/clear") else {
            throw AIError.networkError
        }

        let request = createAuthorizedRequest(url: url, method: "DELETE")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let clearResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                return clearResponse
            } else if httpResponse.statusCode == 401 {
                throw AIError.invalidCredentials
            } else {
                throw AIError.invalidResponse
            }
        } catch {
            throw AIError.networkError
        }
    }

    func getCapabilities() async throws -> AICapabilitiesResponse {
        guard let url = URL(string: baseURL + "ai/capabilities") else {
            throw AIError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let capabilitiesResponse = try JSONDecoder().decode(AICapabilitiesResponse.self, from: data)
                return capabilitiesResponse
            } else if httpResponse.statusCode == 401 {
                throw AIError.invalidCredentials
            } else {
                throw AIError.invalidResponse
            }
        } catch {
            throw AIError.networkError
        }
    }

    func getQuickSuggestions() async throws -> [String] {
        guard let url = URL(string: baseURL + "ai/suggestions") else {
            throw AIError.networkError
        }

        let request = createAuthorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let suggestions = try JSONDecoder().decode([String].self, from: data)
                return suggestions
            } else if httpResponse.statusCode == 401 {
                throw AIError.invalidCredentials
            } else {
                throw AIError.invalidResponse
            }
        } catch {
            throw AIError.networkError
        }
    }
}