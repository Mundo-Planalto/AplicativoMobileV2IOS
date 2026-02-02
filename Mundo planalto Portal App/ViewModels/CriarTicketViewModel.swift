//
//  CriarTicketViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

enum TicketPriority: String, CaseIterable {
    case baixa = "Baixa"
    case media = "Média"
    case alta = "Alta"
    case urgente = "Urgente"

    var color: Color {
        switch self {
        case .baixa: return .green
        case .media: return .blue
        case .alta: return .orange
        case .urgente: return .red
        }
    }
}

enum TicketState {
    case idle
    case loading
    case success(String) // ticket ID
    case error(String)
}

@MainActor
class CriarTicketViewModel: ObservableObject {
    @Published var subject = ""
    @Published var description = ""
    @Published var priority: TicketPriority = .media
    @Published var state: TicketState = .idle

    var isFormValid: Bool {
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        description.count >= 10
    }

    func createTicket() async {
        guard isFormValid else {
            state = .error("Preencha todos os campos obrigatórios")
            return
        }

        state = .loading

        do {
            // Simular criação do ticket via API
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos

            // Simular ID do ticket criado
            let ticketId = "TK-\(Int.random(in: 1000...9999))"
            state = .success(ticketId)

        } catch {
            state = .error("Erro ao criar ticket. Tente novamente.")
        }
    }

    func resetForm() {
        subject = ""
        description = ""
        priority = .media
        state = .idle
    }
}