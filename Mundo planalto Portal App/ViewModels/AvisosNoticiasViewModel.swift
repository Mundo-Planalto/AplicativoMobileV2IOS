//
//  AvisosNoticiasViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AvisosNoticiasViewModel: ObservableObject {
    @Published var notices: [AppNotice] = []
    @Published var isLoading = false
    @Published var error: String?

    func loadNotices() async {
        isLoading = true
        error = nil

        do {
            // Simular carregamento de dados da API
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo

            // Dados mockados expandidos
            notices = [
                AppNotice(id: "1",
                      title: "Reunião de Condôminos - Residencial Parque das Flores",
                      description: "Reunião marcada para o dia 15/02 às 19h na sala de eventos do prédio. Ordem do dia: prestação de contas, manutenção preventiva e sugestões dos moradores.",
                      date: "10/01/2025",
                      type: .notice),
                AppNotice(id: "2",
                      title: "Nova Fase da Obra - Condomínio Vista Verde",
                      description: "Iniciamos a construção da torre norte com previsão de entrega para dezembro de 2025. Acompanhe o progresso através do nosso aplicativo.",
                      date: "08/01/2025",
                      type: .news),
                AppNotice(id: "3",
                      title: "Manutenção Programada - Sistema Elétrico",
                      description: "No próximo sábado (18/01) realizaremos manutenção preventiva no sistema elétrico das áreas comuns. O serviço será das 8h às 12h.",
                      date: "05/01/2025",
                      type: .notice),
                AppNotice(id: "4",
                      title: "Campanha de Reciclagem Inaugurada",
                      description: "Lançamos nossa campanha de conscientização ambiental. Pontos de coleta seletiva foram instalados em todas as torres do empreendimento.",
                      date: "03/01/2025",
                      type: .news),
                AppNotice(id: "5",
                      title: "Atualização no Regulamento Interno",
                      description: "Foram aprovadas alterações no regulamento interno, incluindo novas regras para uso das áreas de lazer e normas de convivência.",
                      date: "01/01/2025",
                      type: .notice),
                AppNotice(id: "6",
                      title: "Parceria com Academia Local",
                      description: "Assinamos convênio com a academia FitLife para desconto especial aos moradores. Desconto de 30% na mensalidade.",
                      date: "28/12/2024",
                      type: .news),
                AppNotice(id: "7",
                      title: "Festa Junina 2025 - Programação Completa",
                      description: "Anunciamos a programação completa da Festa Junina 2025: quadrilha, comidas típicas, brincadeiras e show musical no dia 15/06.",
                      date: "25/12/2024",
                      type: .notice),
                AppNotice(id: "8",
                      title: "Sistema de Segurança Atualizado",
                      description: "Implementamos novo sistema de câmeras de segurança com reconhecimento facial e monitoramento 24 horas em todas as áreas comuns.",
                      date: "20/12/2024",
                      type: .news)
            ]

        } catch {
            self.error = "Erro ao carregar avisos e notícias"
        }

        isLoading = false
    }
}