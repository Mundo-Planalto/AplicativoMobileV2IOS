//
//  HrPlaceholders.swift
//  Mundo Planalto
//
//  Telas herdadas ainda não migradas (ver docs/PENDENCIAS.md).
//

import SwiftUI
import Combine

/// Tela empilhada genérica com HrBackHeader e conteúdo em construção.
struct HrPlaceholderScreen: View {
    let titulo: String
    var subtitulo: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: titulo, subtitulo: subtitulo)
                HrCard {
                    HStack(spacing: 12) {
                        HrIconBox(icon: "hammer.fill")
                        Text("Em construção")
                            .font(HrFont.itemTitle)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
    }
}

struct PoliticaPrivacidadeView: View {
    var body: some View { HrPlaceholderScreen(titulo: "Política de privacidade", subtitulo: "Texto oficial em breve") }
}

struct TermosUsoView: View {
    var body: some View { HrPlaceholderScreen(titulo: "Termos de uso", subtitulo: "Texto oficial em breve") }
}
