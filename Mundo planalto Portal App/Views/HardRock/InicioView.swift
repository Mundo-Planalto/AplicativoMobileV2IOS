//
//  InicioView.swift
//  Hard Rock Hotel & Vacation Club
//
//  Aba Início (docs/telas.md, seção "Início").
//

import SwiftUI
import Combine

@MainActor
final class InicioViewModel: ObservableObject {
    @Published var resumo: FinanceiroResumo?
    @Published var isLoading = false

    func load(forceRefresh: Bool = false) async {
        isLoading = true
        async let r = try? RepositoryProvider.financeiro.resumo(forceRefresh: forceRefresh)
        resumo = await r
        isLoading = false
    }
}

struct InicioView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm = InicioViewModel()

    private let heroImage = "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrHeader(
                    nome: appState.currentMember.nome,
                    titulo: "Seus benefícios",
                    subtitulo: "Experiências que valorizam sua jornada"
                ) {
                    router.push(.avisosNoticias)
                }

                heroCard
                shortcuts
                resumoFinanceiroCard
                ofertasCard
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .refreshable { await vm.load(forceRefresh: true) }
        .hrScreen()
        .task { await vm.load() }
    }

    // MARK: Hero

    private var heroCard: some View {
        HrPhotoCard(url: heroImage, height: 300) {
            VStack(alignment: .leading, spacing: 10) {
                HrTag(text: "Certificado de viagem")
                Text("Gramado te espera")
                    .font(HrFont.heroTitle)
                    .foregroundColor(.white)
                Text("Natureza, cultura e momentos inesquecíveis em um dos destinos mais encantadores do Brasil.")
                    .font(HrFont.body)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                HrStatusDot(text: "Disponível")
                HrGoldButton(text: "Solicitar código") { router.push(.certificados) }
                    .padding(.top, 4)
            }
        }
    }

    // MARK: Atalhos

    private var shortcuts: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: HrMetrics.cardSpacing), GridItem(.flexible(), spacing: HrMetrics.cardSpacing)], spacing: HrMetrics.cardSpacing) {
            HrShortcut(icon: "airplane", titulo: "Viagens", subtitulo: "Experiências exclusivas") { router.push(.certificados) }
            HrShortcut(icon: "tag.fill", titulo: "Descontos", subtitulo: "Em parceiros selecionados") { router.switchTab(.beneficios) }
            HrShortcut(icon: "globe", titulo: "Unity", subtitulo: "Vantagens Hard Rock no mundo") { router.switchTab(.beneficios) }
            HrShortcut(icon: "megaphone.fill", titulo: "Campanhas", subtitulo: "Condições especiais") { router.switchTab(.ofertas) }
        }
    }

    // MARK: Resumo financeiro

    private var resumoFinanceiroCard: some View {
        HrCard(highlighted: true) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HrIconBox(icon: "creditcard.fill")
                    Text("Resumo financeiro")
                        .font(HrFont.sectionTitle)
                        .foregroundColor(.white)
                    Spacer()
                }
                HStack {
                    Text("Próximo vencimento")
                        .font(HrFont.caption)
                        .foregroundColor(.hrTextMuted)
                    Spacer()
                    if let r = vm.resumo {
                        HrStatusDot(text: r.situacao, color: r.situacaoEmDia ? .hrSuccess : .hrError)
                    }
                }
                if let r = vm.resumo {
                    Text(r.proximoValor)
                        .font(HrFont.money)
                        .foregroundColor(.hrGold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(r.proximoVencimento)
                        .font(HrFont.caption)
                        .foregroundColor(.hrTextMuted)
                } else if vm.isLoading {
                    ProgressView().tint(.hrGold).padding(.vertical, 8)
                } else {
                    Text("Não foi possível carregar")
                        .font(HrFont.caption)
                        .foregroundColor(.hrTextMuted)
                }
                Button {
                    router.push(.financeiro)
                } label: {
                    HStack(spacing: 4) {
                        Text("Ver detalhes").font(.system(size: 13, weight: .semibold))
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.hrGoldLight)
                }
                .buttonStyle(HrPressStyle())
            }
        }
    }

    // MARK: Ofertas

    private var ofertasCard: some View {
        HrCard(highlighted: true, onTap: { router.switchTab(.ofertas) }) {
            HStack(spacing: 12) {
                HrIconBox(icon: "tag.fill")
                VStack(alignment: .leading, spacing: 3) {
                    Text("Ofertas para você")
                        .font(HrFont.sectionTitle)
                        .foregroundColor(.white)
                    Text("20% de desconto — Restaurante parceiro em Gramado")
                        .font(HrFont.caption)
                        .foregroundColor(.hrTextMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                HrChevron()
            }
        }
    }
}

#Preview {
    NavigationStack { InicioView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
