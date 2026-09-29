//
//  UnityMilhasView.swift
//  Hard Rock Hotel & Vacation Club
//
//  Unity e Milhas (push) — docs/telas.md, tela "Vantagens".
//

import SwiftUI
import Combine

@MainActor
final class UnityMilhasViewModel: ObservableObject {
    @Published var miles: MilesAccount?
    @Published var travel: TravelProfile?
    @Published var receberPromocoes = true
    @Published var mostrarHistorico = false
    @Published var mostrarEmBreve = false

    func load() async {
        miles = try? await RepositoryProvider.members.miles()
        travel = try? await RepositoryProvider.members.travelProfile()
        if let prefs = try? await RepositoryProvider.members.notificationPreferences() {
            receberPromocoes = prefs.milesOffers
        }
    }

    func salvarPreferencia(_ on: Bool) async {
        var prefs = (try? await RepositoryProvider.members.notificationPreferences()) ?? NotificationPreferences(milesOffers: true, announcements: true)
        prefs.milesOffers = on
        _ = try? await RepositoryProvider.members.updateNotificationPreferences(prefs)
    }

    func cadastrarUnity() async {
        try? await RepositoryProvider.milhas.registerUnityInterest()
        if let url = URL(string: AppConfig.unityURL) {
            await UIApplication.shared.open(url)
        }
    }
}

struct UnityMilhasView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm = UnityMilhasViewModel()

    private let imagemAviao = "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Vantagens", subtitulo: "Mais benefícios para sua jornada")
                unityCard
                milhasCard
                perfilViagemCard
                HrPromoToggleCard(isOn: $vm.receberPromocoes)
                    .onChange(of: vm.receberPromocoes) { _, on in
                        Task { await vm.salvarPreferencia(on) }
                    }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
        .task { await vm.load() }
        .sheet(isPresented: $vm.mostrarHistorico) {
            HrMilesHistorySheet(account: vm.miles ?? MilesAccount(balance: 0, entries: []))
        }
        .alert("Em breve", isPresented: $vm.mostrarEmBreve) {
            Button("OK") {}
        } message: {
            Text("A edição do perfil de viagem estará disponível em breve.")
        }
    }

    private var unityCard: some View {
        ZStack(alignment: .topLeading) {
            HrGradient.unity
            HStack {
                Spacer()
                Image(systemName: "globe")
                    .font(.system(size: 150))
                    .foregroundColor(.white.opacity(0.18))
                    .offset(x: 30, y: 10)
            }
            .clipped()
            VStack(alignment: .leading, spacing: 10) {
                Text("Unity")
                    .font(.system(size: 28, weight: .bold).italic())
                    .foregroundColor(.hrGold)
                Text("Vantagens no Hard Rock no mundo")
                    .font(HrFont.sectionTitle)
                    .foregroundColor(.white)
                Text("Cadastre-se no programa e aproveite experiências, ofertas e reconhecimento em destinos participantes.")
                    .font(HrFont.caption)
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                HrTag(text: "Cadastro disponível")
                HrGoldButton(text: "Cadastrar no Unity") { Task { await vm.cadastrarUnity() } }
                HStack(spacing: 8) {
                    miniAtalho("bed.double.fill", "Hotéis")
                    miniAtalho("fork.knife", "Restaurantes")
                    miniAtalho("ticket.fill", "Experiências")
                }
            }
            .padding(HrMetrics.cardPadding)
        }
        .clipShape(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous).stroke(Color.hrGold, lineWidth: 1))
    }

    private func miniAtalho(_ icon: String, _ titulo: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 11, weight: .semibold))
            Text(titulo).font(.system(size: 11, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundColor(.hrGoldLight)
        .padding(.horizontal, 6)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.black.opacity(0.35)))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.hrGoldBorder, lineWidth: 1))
    }

    private var milhasCard: some View {
        HrPhotoCard(url: imagemAviao, height: 300) {
            VStack(alignment: .leading, spacing: 8) {
                HrTag(text: "Milhas")
                Text("Ofertas e promoções")
                    .font(HrFont.heroTitle)
                    .foregroundColor(.white)
                Text("Seu saldo atual \(HrFormat.integer(vm.miles?.balance ?? 12500)) milhas")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(HrGradient.gold))
                Text("Acompanhe campanhas e oportunidades cadastradas para você")
                    .font(HrFont.caption)
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    HrGoldButton(text: "Ver ofertas") { router.switchTab(.ofertas) }
                    HrOutlineButton(text: "Histórico de milhas") { vm.mostrarHistorico = true }
                }
            }
        }
    }

    private var perfilViagemCard: some View {
        HrCard {
            VStack(alignment: .leading, spacing: 12) {
                HrSectionTitle(titulo: "Perfil de viagem")
                VStack(alignment: .leading, spacing: 4) {
                    Text("Onde você mora").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                    Text(vm.travel.map { "\($0.homeCity) • \($0.homeState)" } ?? "Goiânia • GO")
                        .font(HrFont.itemTitle).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Destinos preferidos").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                    HStack(spacing: 8) {
                        ForEach(vm.travel?.preferredDestinations ?? ["Gramado", "Orlando", "Cancún", "Lisboa"], id: \.self) { d in
                            HrChip(text: d, selected: false) {}
                        }
                    }
                }
                HrOutlineButton(text: "Editar perfil") { vm.mostrarEmBreve = true }
            }
        }
    }
}

#Preview {
    NavigationStack { UnityMilhasView() }
        .environmentObject(AppRouter())
}
