//
//  OfertasView.swift
//  Hard Rock Hotel & Vacation Club
//
//  Aba Ofertas (docs/telas.md).
//

import SwiftUI
import Combine

@MainActor
final class OfertasViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var filtro = "Todas"
    @Published var alerta: String?
    @Published var coupon: Coupon?
    let filtros = ["Todas", "Hospedagem", "Gastronomia", "Experiências"]

    var destaque: Offer? { offers.first { $0.isFeatured } }

    var disponiveis: [Offer] {
        offers.filter { !$0.isFeatured }.filter { offer in
            switch filtro {
            case "Hospedagem": return offer.category == .hospedagem
            case "Gastronomia": return offer.category == .gastronomia
            case "Experiências": return offer.category == .experiencias
            default: return true
            }
        }
    }

    func load() async {
        offers = (try? await RepositoryProvider.ofertas.offers()) ?? []
    }

    func abrir(_ offer: Offer, router: AppRouter) async {
        if let partnerId = offer.partnerId {
            coupon = try? await RepositoryProvider.beneficios.coupon(partnerId: partnerId)
        } else if let url = offer.ctaUrl.flatMap(URL.init(string:)) {
            await UIApplication.shared.open(url)
        } else {
            alerta = "\(offer.title)\n\(offer.subtitle)"
        }
    }
}

struct OfertasView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm = OfertasViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrHeader(nome: appState.currentMember.nome, titulo: "Ofertas", subtitulo: "Promoções e campanhas selecionadas para você") {
                    router.push(.avisosNoticias)
                }

                HrChipRow(options: vm.filtros, selected: $vm.filtro)

                if let d = vm.destaque {
                    HrPhotoCard(url: d.imageUrl, height: 260) {
                        VStack(alignment: .leading, spacing: 8) {
                            HrTag(text: "Campanha em destaque")
                            Text(d.title)
                                .font(HrFont.heroTitle)
                                .foregroundColor(.white)
                            Text(d.subtitle)
                                .font(HrFont.caption)
                                .foregroundColor(.white.opacity(0.85))
                            HrTag(text: "Até 31 de outubro", color: .hrGoldLight)
                            HrGoldButton(text: d.ctaLabel) { vm.alerta = "\(d.title)\n\(d.subtitle)" }
                        }
                    }
                }

                HrSectionTitle(titulo: "Ofertas disponíveis")
                    .padding(.top, 8)

                ForEach(vm.disponiveis) { offer in
                    ofertaCard(offer)
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
        .task { await vm.load() }
        .sheet(item: $vm.coupon) { HrCouponSheet(coupon: $0) }
        .alert("Campanha", isPresented: Binding(get: { vm.alerta != nil }, set: { if !$0 { vm.alerta = nil } })) {
            Button("OK") { vm.alerta = nil }
        } message: {
            Text(vm.alerta ?? "")
        }
    }

    private func ofertaCard(_ offer: Offer) -> some View {
        HrCard(padding: 12) {
            HStack(spacing: 12) {
                HrPhoto(url: offer.imageUrl, height: 96, cornerRadius: 12)
                    .frame(width: 96)
                VStack(alignment: .leading, spacing: 4) {
                    HrTag(text: offer.category.tag)
                    Text(offer.title)
                        .font(HrFont.itemTitle)
                        .foregroundColor(.white)
                    Text(offer.subtitle)
                        .font(HrFont.captionSmall)
                        .foregroundColor(.hrTextMuted)
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        Task { await vm.abrir(offer, router: router) }
                    } label: {
                        HStack(spacing: 3) {
                            Text(offer.ctaLabel).font(.system(size: 13, weight: .semibold))
                            Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.hrGoldLight)
                    }
                    .buttonStyle(HrPressStyle())
                    .padding(.top, 2)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    NavigationStack { OfertasView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
