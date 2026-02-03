//
//  ChatIAViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

struct ChatMessageRequest: Codable {
    let message: String
    let chat: String
}

struct ChatMessageResponseItem: Codable {
    let output: String
}

struct ChatMessage: Identifiable {
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

class ChatIAViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let aiService = AIService.shared

    init() {
        sendWelcomeMessage()
    }

    private func sendWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            content: "Olá! Sou o assistente virtual do Mundo Planalto. Como posso ajudar você hoje?",
            isUser: false
        )
        messages.append(welcomeMessage)
    }

    func sendMessage(_ content: String) async {
        let userMessage = ChatMessage(content: content, isUser: true)
        messages.append(userMessage)

        isLoading = true
        error = nil

        do {
            let response = try await aiService.sendMessage(message: content)
            let aiMessage = ChatMessage(content: response.messageText ?? response.message.content, isUser: false)
            messages.append(aiMessage)
        } catch {
            let errorMessage = ChatMessage(
                content: "Desculpe, houve um erro ao processar sua mensagem. Tente novamente.",
                isUser: false
            )
            messages.append(errorMessage)
            self.error = "Erro ao enviar mensagem"
        }

        isLoading = false
    }
}

