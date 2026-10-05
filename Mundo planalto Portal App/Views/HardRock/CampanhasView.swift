//
//  CampanhasView.swift
//  Mundo Planalto
//
//  Aba Campanhas (antiga Ofertas): filtros dinâmicos pelas categorias das campanhas ativas
//  e CTA rastreável por tipo (online, pós-vendas, WhatsApp, link, certificado).
//

import SwiftUI
import Combine

@MainActor
final class CampanhasViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var filtro = "Todas"
    @Published var isLoading = false
    @Published var error: String?
    @Published var interesseRecebido = false
    @Published var enviandoId: Int?

    /// "Todas" + uma opção por categoria presente, na ordem em que aparecem.
    var filtros: [String] {
        var seen = Set<String>()
        return ["Todas"] + campaigns.map(\.category).filter { seen.insert($0).inserted }
    }

    var visiveis: [Campaign] {
        filtro == "Todas" ? campaigns : campaigns.filter { $0.category == filtro }
    }

    func load() async {
        isLoading = campaigns.isEmpty
        error = nil
        do {
            campaigns = try await RepositoryProvider.campaigns.campaigns()
            if !filtros.contains(filtro) { filtro = "Todas" }
        } catch {
            self.error = AppErrorMapper.userMessage(for: error, fallback: "Não foi possível carregar as campanhas.")
        }
        isLoading = false
    }

    /// CTAs que só registram interesse no servidor: travados enquanto o backend não existe.
    func emBreve(_ campaign: Campaign) -> Bool {
        RepositoryProvider.acoesSimuladas && (campaign.ctaType == .online || campaign.ctaType == .postsales)
    }

    /// Registra o clique (o backend mede cliques e conversão) e executa o CTA.
    func executar(_ campaign: Campaign, router: AppRouter) async {
        enviandoId = campaign.id
        try? await RepositoryProvider.campaigns.registerInterest(id: campaign.id)
        enviandoId = nil
        switch campaign.ctaType {
        case .online, .postsales:
            interesseRecebido = true
        case .whatsapp:
            router.open(campaign.whatsappURL)
        case .link:
            router.open(campaign.ctaUrl)
        case .certificate:
            router.push(.viagens, on: .inicio)
        }
    }
}

struct CampanhasView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm = CampanhasViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrHeader(nome: appState.currentMember.nome, titulo: "Campanhas", subtitulo: "Condições especiais e campanhas para você") {
                    router.push(.avisosNoticias)
                }

                HrChipRow(options: vm.filtros, selected: $vm.filtro)
                HrConteudoExemploAviso()

                if vm.isLoading {
                    HrCard { HStack { Spacer(); ProgressView().tint(.hrGold); Spacer() } }
                } else if let error = vm.error, vm.campaigns.isEmpty {
                    HrCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(error).font(HrFont.body).foregroundColor(.white)
                            HrOutlineButton(text: "Tentar novamente") { Task { await vm.load() } }
                        }
                    }
                } else if vm.visiveis.isEmpty {
                    HrCard {
                        HStack(spacing: 12) {
                            HrIconBox(icon: "megaphone")
                            Text("Nenhuma campanha ativa no momento.")
                                .font(HrFont.caption).foregroundColor(.hrTextMuted)
                        }
                    }
                } else {
                    ForEach(vm.visiveis) { campaign in
                        if campaign.isFeatured == true {
                            destaqueCard(campaign)
                        } else {
                            campanhaCard(campaign)
                        }
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .refreshable { await vm.load() }
        .hrScreen()
        .task { await vm.load() }
        .alert("Recebemos seu interesse", isPresented: $vm.interesseRecebido) {
            Button("OK") {}
        } message: {
            Text("Nossa equipe entra em contato em breve.")
        }
    }

    private func destaqueCard(_ c: Campaign) -> some View {
        HrPhotoCard(url: c.imageUrl, height: 280) {
            VStack(alignment: .leading, spacing: 8) {
                HrTag(text: c.category)
                Text(c.title)
                    .font(HrFont.heroTitle)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(c.subtitle)
                    .font(HrFont.caption)
                    .foregroundColor(.white.opacity(0.85))
                if let validade = c.validadeTexto {
                    HrTag(text: validade, color: .hrGoldLight)
                }
                if vm.emBreve(c) {
                    HrEmBreveButton()
                } else {
                    HrGoldButton(text: c.ctaLabel, isLoading: vm.enviandoId == c.id) {
                        Task { await vm.executar(c, router: router) }
                    }
                }
            }
        }
    }

    private func campanhaCard(_ c: Campaign) -> some View {
        HrCard(padding: 12) {
            HStack(alignment: .top, spacing: 12) {
                HrPhoto(url: c.imageUrl, height: 96, cornerRadius: 12)
                    .frame(width: 96)
                VStack(alignment: .leading, spacing: 5) {
                    HrTag(text: c.category)
                    Text(c.title)
                        .font(HrFont.sectionTitle)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(c.subtitle)
                        .font(HrFont.caption)
                        .foregroundColor(.hrTextMuted)
                        .fixedSize(horizontal: false, vertical: true)
                    if let validade = c.validadeTexto {
                        HrTag(text: validade, color: .hrGoldLight)
                    }
                    if vm.emBreve(c) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock").font(.system(size: 11, weight: .semibold))
                            Text("Disponível em breve").font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.hrTextMuted)
                        .padding(.top, 2)
                    } else {
                    Button {
                        Task { await vm.executar(c, router: router) }
                    } label: {
                        HStack(spacing: 4) {
                            if vm.enviandoId == c.id {
                                ProgressView().tint(.hrGoldLight).scaleEffect(0.7)
                            }
                            Text(c.ctaLabel).font(.system(size: 13, weight: .semibold))
                            Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.hrGoldLight)
                    }
                    .buttonStyle(HrPressStyle())
                    .padding(.top, 2)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    NavigationStack { CampanhasView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
