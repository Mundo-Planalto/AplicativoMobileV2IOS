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
    @Published var empreendimento: MeuEmpreendimentoResumo?
    @Published var collection: CollectionStatus?
    @Published var isLoading = false

    func load(forceRefresh: Bool = false) async {
        isLoading = true
        async let r = try? RepositoryProvider.financeiro.resumo(forceRefresh: forceRefresh)
        async let e = try? RepositoryProvider.financeiro.meuEmpreendimento()
        async let c = try? RepositoryProvider.members.collection()
        resumo = await r
        empreendimento = await e
        collection = await c
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
                meuEmpreendimentoCard
                collectionSection
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
            HrShortcut(icon: "globe", titulo: "Unity", subtitulo: "Vantagens para você") { router.push(.unityMilhas) }
            HrShortcut(icon: "star.fill", titulo: "Milhas", subtitulo: "Acumule e aproveite") { router.push(.unityMilhas) }
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

    // MARK: Meu empreendimento

    private var meuEmpreendimentoCard: some View {
        HrCard(onTap: { router.switchTab(.empreendimentos) }) {
            HStack(spacing: 12) {
                HrPhoto(url: vm.empreendimento?.imageUrl, height: 64, cornerRadius: 12, placeholderIcon: "building.2.fill")
                    .frame(width: 64)
                VStack(alignment: .leading, spacing: 3) {
                    HrTag(text: "Meu empreendimento")
                    Text(vm.empreendimento?.nome ?? "Hard Rock Hotel Gramado")
                        .font(HrFont.itemTitle)
                        .foregroundColor(.white)
                    if let unidade = vm.empreendimento?.unidade, !unidade.isEmpty {
                        Text(unidade)
                            .font(HrFont.captionSmall)
                            .foregroundColor(.hrTextMuted)
                    }
                }
                Spacer()
                HrChevron()
            }
        }
    }

    // MARK: Collection

    private var collectionSection: some View {
        HrCard {
            VStack(alignment: .leading, spacing: 12) {
                HrSectionTitle(titulo: "Collection Hard Rock", subtitulo: "Complete sua coleção mantendo as parcelas em dia")
                let items = vm.collection?.items ?? (1...6).map { CollectionItem(index: $0, status: $0 <= 2 ? .sent : .locked) }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                    ForEach(items) { item in
                        VStack(spacing: 4) {
                            ZStack(alignment: .bottomTrailing) {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(item.status == .locked ? Color.hrSurfaceElevated : Color.hrGold.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(item.status == .locked ? Color.hrGoldBorder.opacity(0.5) : Color.hrGold, lineWidth: 1)
                                    )
                                Image(systemName: "tshirt.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(item.status == .locked ? .hrTextMuted.opacity(0.4) : .hrGold)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                if item.status == .locked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.hrTextMuted)
                                        .padding(3)
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                            Text(item.status.legenda)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(item.status == .locked ? .hrTextMuted.opacity(0.6) : .hrGoldLight)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
                let unlocked = vm.collection?.desbloqueadas ?? 2
                let total = max(items.count, 1)
                Text("\(unlocked) de \(total) camisetas desbloqueadas")
                    .font(HrFont.caption)
                    .foregroundColor(.hrTextMuted)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.hrSurfaceElevated)
                        Capsule().fill(HrGradient.gold)
                            .frame(width: geo.size.width * CGFloat(unlocked) / CGFloat(total))
                    }
                }
                .frame(height: 3)
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
