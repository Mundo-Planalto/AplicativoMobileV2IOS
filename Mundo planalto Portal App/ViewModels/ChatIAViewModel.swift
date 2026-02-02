//
//  ChatIAViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine
import CommonCrypto

struct ChatMessageRequest: Codable {
    let message: String
    let chat: String
}

struct ChatMessageResponseItem: Codable {
    let output: String
}

@MainActor
class ChatIAViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: String?

    private let apiUrl = "https://primary-production-77f3.up.railway.app/webhook/fbee63dc-1f61-4e02-9cfa-a7c6001c704a"

    // GUID determinístico baseado em dados do usuário
    private var chatId: String {
        // Simulando um UUID determinístico
        // Em produção, seria baseado em userId + cpfCnpj
        let userData = "user123_12345678900"
        return UUID(userData.utf8Data.sha256().prefix(16)).uuidString
    }

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
            let response = try await sendToAPI(message: content)
            let aiMessage = ChatMessage(content: response, isUser: false)
            messages.append(aiMessage)
        } catch {
            let errorMessage = ChatMessage(
                content: "Desculpe, houve um erro ao processar sua mensagem. Tente novamente.",
                isUser: false
            )
            messages.append(errorMessage)
        }

        isLoading = false
    }

    private func sendToAPI(message: String) async throws -> String {
        let request = ChatMessageRequest(message: message, chat: chatId)

        guard let url = URL(string: apiUrl) else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode([ChatMessageResponseItem].self, from: data)
        return decodedResponse.first?.output ?? "Não foi possível obter uma resposta."
    }
}

extension Data {
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
}

extension UUID {
    init(_ data: Data) {
        let bytes = [UInt8](data.prefix(16))
        let uuid = NSUUID(uuidBytes: bytes) as UUID
        self = uuid
    }
}
