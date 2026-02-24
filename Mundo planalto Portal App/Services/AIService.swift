//
//  AIService.swift
//  Mundo planalto Portal App
//
//  Atendimento com IA via webhook Railway. Sessão (chat) exclusiva por usuário.
//

import Foundation
import UIKit

enum AIError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

struct AIChatMessage: Codable {
    let id: String?
    let role: MessageRole?
    let content: String
    let timestamp: String?
    let isTyping: Bool?
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

/// Request para o webhook: { "message": "...", "chat": "sessionId" }
struct ChatWebhookRequest: Codable {
    let message: String
    let chat: String
}

/// Resposta esperada do webhook (ajustar conforme API real)
struct ChatWebhookResponse: Codable {
    let output: String?
    let message: String?
    let response: String?
    var text: String? { output ?? message ?? response }
}

class AIService {
    static let shared = AIService()
    private init() {}

    private let webhookURL = "https://primary-production-77f3.up.railway.app/webhook/fbee63dc-1f61-4e02-9cfa-a7c6001c704a"

    private func chatSessionId() -> String {
        let key = "ai_chat_session_id"
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let newId = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }

    func sendMessage(message: String) async throws -> (content: String, sessionId: String) {
        guard let url = URL(string: webhookURL) else { throw AIError.networkError }
        let sessionId = chatSessionId()
        let body = ChatWebhookRequest(message: message, chat: sessionId)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw AIError.invalidResponse }
        guard http.statusCode == 200 else { throw AIError.invalidResponse }
        let decoded = try? JSONDecoder().decode(ChatWebhookResponse.self, from: data)
        let rawText = decoded?.text ?? String(data: data, encoding: .utf8) ?? "Resposta indisponível."
        let displayText = Self.extractMessageOnly(rawText)
        return (displayText, sessionId)
    }

    /// Extrai apenas o texto da mensagem da resposta (remove JSON extra, HTML, etc.).
    private static func extractMessageOnly(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return stripHTML(trimmed)
        }
        for key in ["output", "message", "response", "content", "text", "reply"] {
            if let val = json[key] as? String, !val.isEmpty { return stripHTML(val) }
        }
        if let msg = json["message"] as? [String: Any], let content = msg["content"] as? String {
            return stripHTML(content)
        }
        return stripHTML(trimmed)
    }

    private static func stripHTML(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.contains("<"), t.contains(">"),
              let data = t.data(using: .utf8),
              let attributed = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return t.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        }
        return attributed.string
    }
}