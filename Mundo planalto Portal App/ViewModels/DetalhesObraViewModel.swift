//
//  DetalhesObraViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DetalhesObraViewModel: ObservableObject {
    @Published var venture: Venture
    @Published var updates: [VentureUpdate] = []
    @Published var isLoading = false
    @Published var error: String?

    init(venture: Venture) {
        self.venture = venture
    }

    func loadVentureDetails() async {
        isLoading = true
        error = nil

        do {
            // Simular carregamento de dados da API
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo

            // Dados mockados de timeline
            updates = [
                VentureUpdate(
                    id: "1",
                    date: "Dezembro 2024",
                    title: "Início da Construção",
                    description: "Foi iniciado o processo de terraplanagem e fundação do empreendimento. Todas as licenças ambientais foram aprovadas.",
                    images: ["construction1", "construction2"],
                    isCompleted: true
                ),
                VentureUpdate(
                    id: "2",
                    date: "Janeiro 2025",
                    title: "Estrutura Principal",
                    description: "Concluída a estrutura principal do prédio. Iniciamos a instalação das infraestruturas básicas de elétrica e hidráulica.",
                    images: ["structure1", "structure2", "structure3"],
                    isCompleted: true
                ),
                VentureUpdate(
                    id: "3",
                    date: "Fevereiro 2025",
                    title: "Revestimento Externo",
                    description: "Aplicação do revestimento externo e instalação das janelas. Preparação para fase de acabamento interno.",
                    images: ["exterior1", "exterior2"],
                    isCompleted: true
                ),
                VentureUpdate(
                    id: "4",
                    date: "Março 2025",
                    title: "Acabamento Interno",
                    description: "Iniciamos os acabamentos internos das unidades. Instalação de pisos, azulejos e preparação para pintura final.",
                    images: ["interior1"],
                    isCompleted: false
                ),
                VentureUpdate(
                    id: "5",
                    date: "Abril 2025",
                    title: "Entrega das Chaves",
                    description: "Previsão de entrega final do empreendimento com todas as unidades prontas para ocupação.",
                    images: [],
                    isCompleted: false
                )
            ]

        } catch {
            self.error = "Erro ao carregar detalhes da obra"
        }

        isLoading = false
    }
}