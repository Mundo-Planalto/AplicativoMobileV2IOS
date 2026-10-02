//
//  PerfilView.swift
//  Mundo Planalto
//
//  Aba Perfil (revisão de 01/10): cartão do membro, perfil de viagem, dados pessoais com
//  solicitação de alteração, preferências (único opt-in do app), segurança e "Sair".
//

import SwiftUI

struct PerfilView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = PerfilViewModel()
    @State private var expandida: PerfilSecao?
    @State private var confirmarSaida = false
    @State private var trocarSenha = false
    @State private var receberCampanhas = true
    @State private var receberAvisos = true
    @State private var prefsCarregadas = false
    @State private var travel: TravelProfile?
    @State private var clube: String?

    enum PerfilSecao { case pessoais, endereco, preferencias, seguranca }

    var body: some View {
        let member = appState.currentMember
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrHeader(nome: member.nome, titulo: "Perfil", subtitulo: "Sua jornada, ainda mais especial.") {
                    router.push(.avisosNoticias)
                }

                CartaoDigitalCard(
                    nome: viewModel.userName.isEmpty ? member.nome : viewModel.userName,
                    nivel: member.nivel,
                    numeroMembro: member.numeroMembro,
                    desde: member.desde,
                    clube: clube ?? member.clube
                ) {
                    router.push(.cartaoDigital)
                }

                HStack(spacing: 10) {
                    HrGoldButton(text: "Ver benefícios") { router.switchTab(.beneficios) }
                    HrIconSquareButton(icon: "qrcode") { router.push(.cartaoDigital) }
                }

                // Perfil de viagem
                HrSectionTitle(titulo: "Perfil de viagem", subtitulo: "Usamos isso para escolher campanhas para você")
                    .padding(.top, 8)
                perfilViagemCard

                // Dados pessoais
                HrSectionTitle(titulo: "Dados pessoais", subtitulo: "Mantenha seus dados atualizados")
                    .padding(.top, 8)

                secao(.pessoais, icon: "person.fill", titulo: "Informações pessoais", subtitulo: "Nome, CPF, e-mail e telefone") {
                    infoLinha("Nome", viewModel.userName)
                    infoLinha("CPF/CNPJ", viewModel.userDocument)
                    infoLinha("E-mail", viewModel.userEmail.isEmpty ? "—" : viewModel.userEmail)
                    infoLinha("Telefone", viewModel.userPhone)
                    HrOutlineButton(text: "Solicitar alteração") { router.push(.alteracaoDados(.phone)) }
                        .padding(.top, 4)
                }

                secao(.endereco, icon: "house.fill", titulo: "Endereço de correspondência", subtitulo: "Seu endereço cadastrado") {
                    Text(viewModel.userAddressLine1).font(HrFont.body).foregroundColor(.white)
                    Text(viewModel.userAddressLine2).font(HrFont.body).foregroundColor(.white)
                    if !viewModel.userAddressCep.isEmpty {
                        Text(viewModel.userAddressCep).font(HrFont.caption).foregroundColor(.hrTextMuted)
                    }
                    HrOutlineButton(text: "Solicitar alteração") { router.push(.alteracaoDados(.address)) }
                        .padding(.top, 4)
                }

                secao(.preferencias, icon: "slider.horizontal.3", titulo: "Preferências", subtitulo: "Comunicações e campanhas") {
                    Toggle(isOn: $receberCampanhas) {
                        Text("Receber campanhas e novidades").font(HrFont.itemTitle).foregroundColor(.white)
                    }
                    .tint(.hrGold)
                    Toggle(isOn: $receberAvisos) {
                        Text("Avisos do empreendimento").font(HrFont.itemTitle).foregroundColor(.white)
                    }
                    .tint(.hrGold)
                }

                secao(.seguranca, icon: "shield.fill", titulo: "Segurança", subtitulo: "Senha e acesso") {
                    HrListRow(icon: "key.fill", titulo: "Trocar senha", subtitulo: "Altere sua senha de acesso") { trocarSenha = true }
                    HrListRow(icon: "gearshape.fill", titulo: "Configurações", subtitulo: "Notificações, política e versão") { router.push(.sistema) }
                }

                HrListRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    titulo: "Sair",
                    subtitulo: "Encerrar a sessão neste dispositivo",
                    iconColor: .hrError,
                    titleColor: .hrError
                ) { confirmarSaida = true }
                .padding(.top, 8)
                .id("sair")
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .onAppear {
            #if DEBUG
            // Atalho de teste: `-hrScrollBottom` rola até o "Sair" para conferir o fim da tela.
            if ProcessInfo.processInfo.arguments.contains("-hrScrollBottom") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation { proxy.scrollTo("sair", anchor: .bottom) }
                }
            }
            #endif
        }
        }
        .hrScreen()
        .task { await carregar() }
        .onChange(of: receberCampanhas) { _, _ in salvarPreferencias() }
        .onChange(of: receberAvisos) { _, _ in salvarPreferencias() }
        .sheet(isPresented: $trocarSenha) { TrocarSenhaView() }
        .alert("Sair", isPresented: $confirmarSaida) {
            Button("Cancelar", role: .cancel) {}
            Button("Sair", role: .destructive) {
                Task { await appState.logout() }
            }
        } message: {
            Text("Deseja encerrar a sessão neste dispositivo?")
        }
    }

    private func carregar() async {
        await viewModel.loadUserData()
        travel = try? await RepositoryProvider.travelProfile.profile()
        clube = (try? await RepositoryProvider.member.card())?.clubName
        if let prefs = try? await RepositoryProvider.member.notificationPreferences() {
            receberCampanhas = prefs.campaigns
            receberAvisos = prefs.announcements
        }
        prefsCarregadas = true
    }

    private func salvarPreferencias() {
        guard prefsCarregadas else { return }
        let prefs = NotificationPreferences(campaigns: receberCampanhas, announcements: receberAvisos)
        Task { _ = try? await RepositoryProvider.member.updateNotificationPreferences(prefs) }
    }

    private var perfilViagemCard: some View {
        HrCard {
            VStack(alignment: .leading, spacing: 12) {
                infoLinha("Onde você mora", travel?.moradaTexto ?? "—")
                VStack(alignment: .leading, spacing: 6) {
                    Text("Destinos preferidos").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                    if let destinos = travel?.preferredDestinations, !destinos.isEmpty {
                        HrFlow(spacing: 8) {
                            ForEach(destinos, id: \.self) { d in
                                HrChip(text: d, selected: false) {}
                                    .allowsHitTesting(false)
                            }
                        }
                    } else {
                        Text("—").font(HrFont.body).foregroundColor(.white)
                    }
                }
                infoLinha("Próxima viagem", travel?.proximaViagemTexto ?? "—")
                HrOutlineButton(text: "Editar perfil de viagem") { router.push(.perfilViagem) }
            }
        }
        .task(id: router.paths[.perfil]?.count ?? 0) {
            // Recarrega ao voltar da tela de edição.
            travel = try? await RepositoryProvider.travelProfile.profile()
        }
    }

    private func infoLinha(_ rotulo: String, _ valor: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(rotulo).font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
            Text(valor.isEmpty ? "—" : valor).font(HrFont.body).foregroundColor(.white)
        }
    }

    /// Linha expansível: HrListRow com chevron que gira e conteúdo abaixo.
    private func secao<Content: View>(
        _ id: PerfilSecao, icon: String, titulo: String, subtitulo: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        let aberta = expandida == id
        return VStack(spacing: 0) {
            HrListRow(icon: icon, titulo: titulo, subtitulo: subtitulo, onTap: {
                withAnimation(.easeInOut(duration: 0.2)) { expandida = aberta ? nil : id }
            }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.hrGold)
                    .rotationEffect(.degrees(aberta ? 180 : 0))
            }
            if aberta {
                VStack(alignment: .leading, spacing: 10) {
                    content()
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.hrSurfaceElevated))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.hrGoldBorder, lineWidth: 1))
                .padding(.top, 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

/// Layout em linhas que quebra quando não cabe (chips de destinos).
struct HrFlow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, widest: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth { x = 0; y += rowHeight + spacing; rowHeight = 0 }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widest = max(widest, x - spacing)
        }
        return CGSize(width: maxWidth == .infinity ? widest : maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX { x = bounds.minX; y += rowHeight + spacing; rowHeight = 0 }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    NavigationStack { PerfilView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
