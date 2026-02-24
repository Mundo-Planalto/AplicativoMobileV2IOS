//
//  EmpreendimentosViewModel.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class EmpreendimentosViewModel: ObservableObject {
    @Published var ventures: [Venture] = []
    @Published var isLoading = false
    @Published var error: String?

    func loadVentures() async {
        isLoading = true
        error = nil
        do {
            let response = try await EmpreendimentosService.shared.getEmpreendimentos()
            ventures = response.empreendimentos
        } catch {
            self.error = "Erro ao carregar empreendimentos"
        }
        isLoading = false
    }
}