//
//  ChatIAViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date

    init(content: String, isUser: Bool, id: UUID = UUID(), timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

struct ChatSession: Identifiable, Codable, Hashable {
    let id: UUID
    var startedAt: Date
    var lastInteractionAt: Date
    var messages: [ChatMessage]

    var title: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.dateFormat = "dd/MM/yyyy HH:mm"
        return "Conversa \(fmt.string(from: startedAt))"
    }
}

@MainActor
class ChatIAViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published private(set) var history: [ChatSession] = []

    private let aiService = AIService.shared
    private let userDefaults = UserDefaults.standard

    private let inactivitySeconds: TimeInterval = 60 * 60
    private let currentSessionKey = "chat_ia_current_session"
    private let historyKey = "chat_ia_history_sessions"
    private let aiSessionKey = "ai_chat_session_id"

    private var currentSessionId: UUID?

    init() {
        loadHistory()
        restoreOrStartSession()
    }

    private func sendWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            content: "Olá! Sou o assistente virtual do Mundo Planalto. Como posso ajudar você hoje?",
            isUser: false
        )
        messages.append(welcomeMessage)
    }

    func allSessionsForHistory() -> [ChatSession] {
        // Inclui a sessão atual (se existir) como primeiro item, seguida do histórico.
        var sessions = history
        if let current = loadCurrentSession() {
            sessions.insert(current, at: 0)
        }
        // Remove duplicatas por id
        var seen = Set<UUID>()
        return sessions.filter { seen.insert($0.id).inserted }
    }

    func loadSessionMessages(sessionId: UUID) -> [ChatMessage] {
        if let current = loadCurrentSession(), current.id == sessionId {
            return current.messages
        }
        return history.first(where: { $0.id == sessionId })?.messages ?? []
    }

    func sendMessage(_ content: String) async {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // Permite apenas 1 envio por vez: só libera novo envio após resposta da IA.
        guard !isLoading else { return }

        // Se ficou mais de 1h sem interação, inicia nova conversa antes de enviar.
        if shouldExpireCurrentSession() {
            archiveAndStartNewSession()
        }

        let userMessage = ChatMessage(content: trimmed, isUser: true)
        messages.append(userMessage)
        touchInteraction()
        persistCurrentSession()

        isLoading = true
        error = nil

        do {
            let result = try await aiService.sendMessage(message: trimmed)
            let aiMessage = ChatMessage(content: result.content, isUser: false)
            messages.append(aiMessage)
            touchInteraction()
            persistCurrentSession()
        } catch {
            let fallbackMessage = "Desculpe, houve um erro ao processar sua mensagem. Tente novamente."
            let detailedMessage = AppErrorMapper.userMessage(
                for: error,
                fallback: fallbackMessage
            )
            let errorMessage = ChatMessage(
                content: detailedMessage,
                isUser: false
            )
            messages.append(errorMessage)
            self.error = AppErrorMapper.userMessage(
                for: error,
                fallback: "Erro ao enviar mensagem"
            )
            touchInteraction()
            persistCurrentSession()
        }

        isLoading = false
    }

    // MARK: - Sessão / Persistência

    private func restoreOrStartSession() {
        if let current = loadCurrentSession() {
            if Date().timeIntervalSince(current.lastInteractionAt) <= inactivitySeconds {
                currentSessionId = current.id
                messages = current.messages
                if messages.isEmpty {
                    sendWelcomeMessage()
                    touchInteraction()
                    persistCurrentSession()
                }
                return
            } else {
                // Expirou por inatividade -> arquiva e inicia nova
                history.insert(current, at: 0)
                saveHistory()
                clearCurrentSession()
            }
        }
        startNewSession()
    }

    private func startNewSession() {
        currentSessionId = UUID()
        messages = []
        sendWelcomeMessage()
        // Reseta a sessão do webhook para evitar continuar contexto antigo.
        userDefaults.set(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased(), forKey: aiSessionKey)
        touchInteraction()
        persistCurrentSession()
    }

    private func archiveAndStartNewSession() {
        if let current = loadCurrentSession() {
            history.insert(current, at: 0)
            saveHistory()
        }
        clearCurrentSession()
        startNewSession()
    }

    private func shouldExpireCurrentSession() -> Bool {
        guard let current = loadCurrentSession() else { return false }
        return Date().timeIntervalSince(current.lastInteractionAt) > inactivitySeconds
    }

    private func touchInteraction() {
        // Atualiza "lastInteractionAt" no storage persistente via persistCurrentSession().
    }

    private func loadCurrentSession() -> ChatSession? {
        guard let data = userDefaults.data(forKey: currentSessionKey) else { return nil }
        return try? JSONDecoder().decode(ChatSession.self, from: data)
    }

    private func persistCurrentSession() {
        let now = Date()
        let id = currentSessionId ?? loadCurrentSession()?.id ?? UUID()
        currentSessionId = id
        let started = loadCurrentSession()?.startedAt ?? now
        let session = ChatSession(id: id, startedAt: started, lastInteractionAt: now, messages: messages)
        if let data = try? JSONEncoder().encode(session) {
            userDefaults.set(data, forKey: currentSessionKey)
        }
    }

    private func clearCurrentSession() {
        userDefaults.removeObject(forKey: currentSessionKey)
        currentSessionId = nil
    }

    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([ChatSession].self, from: data) else {
            history = []
            return
        }
        history = decoded
    }

    private func saveHistory() {
        // Limita para não crescer infinito
        if history.count > 30 {
            history = Array(history.prefix(30))
        }
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: historyKey)
        }
    }
}

