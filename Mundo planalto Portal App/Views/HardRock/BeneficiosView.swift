//
//  BeneficiosView.swift
//  Mundo Planalto
//
//  Aba Benefícios (docs/telas.md, revisão de 01/10): até 2 parceiros em destaque com foto,
//  card Unity com identidade do programa (abre no navegador interno), lista de parceiros
//  e atalho para os certificados. A lista já vem filtrada por empreendimento do backend.
//

import SwiftUI
import Combine

@MainActor
final class BeneficiosViewModel: ObservableObject {
    @Published var partners: [Partner] = []
    @Published var coupon: Coupon?
    @Published var filtro = "Todos"
    @Published var cupomEmBreve = false

    /// "Todos", "Viagens" e uma opção por cidade dos parceiros (mock: Gramado).
    var filtros: [String] {
        var seen = Set<String>()
        let cidades = partners.map(\.city).filter { !$0.isEmpty && seen.insert($0).inserted }
        return ["Todos", "Viagens"] + cidades
    }

    /// No máximo 2 destaques com imagem.
    var destaques: [Partner] {
        Array(partners.filter { $0.isFeatured == true && $0.imageUrl != nil }.prefix(2)).filter(passaNoFiltro)
    }

    var lista: [Partner] { partners.filter(passaNoFiltro) }

    var mostraViagens: Bool { filtro == "Todos" || filtro == "Viagens" }
    var mostraParceiros: Bool { filtro != "Viagens" }

    private func passaNoFiltro(_ p: Partner) -> Bool {
        filtro == "Todos" || p.city == filtro
    }

    func load() async {
        partners = (try? await RepositoryProvider.partners.partners()) ?? []
    }

    func abrirCupom(partnerId: Int) async {
        if RepositoryProvider.acoesSimuladas {
            cupomEmBreve = true
            return
        }
        coupon = try? await RepositoryProvider.partners.coupon(partnerId: partnerId)
    }
}

struct BeneficiosView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm = BeneficiosViewModel()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                    HrHeader(nome: appState.currentMember.nome, titulo: "Benefícios", subtitulo: "Vantagens exclusivas para você") {
                        router.push(.avisosNoticias)
                    }

                    HrChipRow(options: vm.filtros, selected: $vm.filtro)
                    HrConteudoExemploAviso()

                    if vm.mostraParceiros {
                        ForEach(vm.destaques) { partner in
                            destaqueCard(partner)
                        }
                    }

                    if vm.mostraViagens {
                        unityCard.id("unity")
                    }

                    if vm.mostraParceiros, !vm.lista.isEmpty {
                        HrSectionTitle(titulo: "Parceiros", subtitulo: "Mínimo de 10% de desconto • validação por cupom")
                            .padding(.top, 8)
                        ForEach(vm.lista) { partner in
                            HrListRow(icon: iconePara(partner.category), titulo: partner.name, subtitulo: partner.discountText) {
                                Task { await vm.abrirCupom(partnerId: partner.id) }
                            }
                        }
                    }

                    if vm.mostraViagens {
                        certificadosCard.padding(.top, 8)
                    }
                }
                .padding(.horizontal, HrMetrics.screenMargin)
                .padding(.bottom, HrMetrics.scrollBottomInset)
            }
            .onChange(of: router.beneficiosScrollTarget) { _, target in
                rolar(para: target, proxy: proxy)
            }
            .onAppear { rolar(para: router.beneficiosScrollTarget, proxy: proxy) }
        }
        .hrScreen()
        .task { await vm.load() }
        .sheet(item: $vm.coupon) { coupon in
            HrCouponSheet(coupon: coupon)
        }
        .alert("Disponível em breve", isPresented: $vm.cupomEmBreve) {
            Button("OK") {}
        } message: {
            Text("O cupom deste parceiro ainda não pode ser gerado pelo app. Nada foi enviado ao servidor.")
        }
    }

    private func rolar(para target: String?, proxy: ScrollViewProxy) {
        guard let target else { return }
        vm.filtro = "Todos"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation { proxy.scrollTo(target, anchor: .top) }
            router.beneficiosScrollTarget = nil
        }
    }

    // MARK: Destaques

    private func destaqueCard(_ partner: Partner) -> some View {
        HrPhotoCard(url: partner.imageUrl, height: 240) {
            VStack(alignment: .leading, spacing: 8) {
                HrTag(text: partner.isNew == true ? "Parceiro novo" : "Parceiro")
                Text(partner.discountText)
                    .font(HrFont.heroTitle)
                    .foregroundColor(.white)
                Text("\(partner.name) • \(partner.city)")
                    .font(HrFont.caption)
                    .foregroundColor(.white.opacity(0.85))
                if RepositoryProvider.acoesSimuladas {
                    HrEmBreveButton()
                } else {
                    HrGoldButton(text: "Ver voucher") { Task { await vm.abrirCupom(partnerId: partner.id) } }
                }
            }
        }
    }

    // MARK: Unity (identidade do programa; sem inventar logo até o asset chegar)

    private var unityCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HARD ROCK UNITY")
                .font(.system(size: 18, weight: .bold))
                .tracking(1)
                .foregroundColor(.white)
            Text("Vantagens no Hard Rock no mundo")
                .font(HrFont.itemTitle)
                .foregroundColor(.white)
            Text("Cadastre-se no programa e aproveite experiências, ofertas e reconhecimento em destinos participantes.")
                .font(HrFont.caption)
                .foregroundColor(.hrTextMuted)
                .fixedSize(horizontal: false, vertical: true)
            HrGoldButton(text: "Cadastrar no Unity") { router.open(AppConfig.unityURL) }
                .padding(.top, 2)
            HStack(spacing: 8) {
                miniAtalho("bed.double.fill", "Hotéis")
                miniAtalho("fork.knife", "Restaurantes")
                miniAtalho("ticket.fill", "Experiências")
            }
        }
        .padding(HrMetrics.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#1A1A1A"))
        .clipShape(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous).stroke(Color.hrGoldBorder, lineWidth: 1))
    }

    private func miniAtalho(_ icon: String, _ titulo: String) -> some View {
        Button { router.open(AppConfig.unityURL) } label: {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 11, weight: .semibold))
                Text(titulo).font(.system(size: 11, weight: .semibold)).lineLimit(1).minimumScaleFactor(0.7)
            }
            .foregroundColor(.hrGoldLight)
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.black.opacity(0.35)))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.hrGoldBorder, lineWidth: 1))
        }
        .buttonStyle(HrPressStyle())
    }

    // MARK: Certificados

    private var certificadosCard: some View {
        HrCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    HrIconBox(icon: "airplane")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Certificados de viagem")
                            .font(HrFont.sectionTitle)
                            .foregroundColor(.white)
                        Text("Veja seus certificados e solicite a ativação")
                            .font(HrFont.caption)
                            .foregroundColor(.hrTextMuted)
                    }
                }
                HrOutlineButton(text: "Ver meus certificados") { router.push(.viagens) }
            }
        }
    }

    private func iconePara(_ c: PartnerCategory) -> String {
        switch c {
        case .gastronomia: return "fork.knife"
        case .hospedagem: return "bed.double.fill"
        case .experiencias: return "ticket.fill"
        case .compras: return "bag.fill"
        case .outros: return "tag.fill"
        }
    }
}

extension Coupon: Identifiable {
    var id: String { "\(partnerId)-\(code)" }
}

#Preview {
    NavigationStack { BeneficiosView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
