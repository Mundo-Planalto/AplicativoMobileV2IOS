//
//  HrPlaceholders.swift
//  Hard Rock Hotel & Vacation Club
//
//  Telas novas ainda em construção (substituídas na etapa 4 do CLAUDE.md).
//

import SwiftUI

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

struct BeneficiosView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrHeader(nome: appState.currentMember.nome, titulo: "Benefícios", subtitulo: "Vantagens exclusivas para você") {
                    router.push(.avisosNoticias)
                }
                HrCard { Text("Em construção").font(HrFont.itemTitle).foregroundColor(.white) }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
        }
        .hrScreen()
    }
}

struct OfertasView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrHeader(nome: appState.currentMember.nome, titulo: "Ofertas", subtitulo: "Promoções e campanhas selecionadas para você") {
                    router.push(.avisosNoticias)
                }
                HrCard { Text("Em construção").font(HrFont.itemTitle).foregroundColor(.white) }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
        }
        .hrScreen()
    }
}

struct FinanceiroView: View {
    var body: some View { HrPlaceholderScreen(titulo: "Financeiro", subtitulo: "Acompanhe sua situação e tenha mais controle sobre seu investimento") }
}

struct CertificadosView: View {
    var body: some View { HrPlaceholderScreen(titulo: "Certificados de viagem", subtitulo: "Escolha uma experiência para solicitar") }
}

struct UnityMilhasView: View {
    var body: some View { HrPlaceholderScreen(titulo: "Vantagens", subtitulo: "Mais benefícios para sua jornada") }
}

struct CartaoDigitalView: View {
    var body: some View { HrPlaceholderScreen(titulo: "Cartão do membro", subtitulo: "Apresente nos parceiros para validar seus benefícios") }
}

struct PoliticaPrivacidadeView: View {
    var body: some View { HrPlaceholderScreen(titulo: "Política de privacidade") }
}
