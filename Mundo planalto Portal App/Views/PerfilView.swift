//
//  PerfilView.swift
//  Hard Rock Hotel & Vacation Club
//
//  Aba Perfil: cartão do membro, dados pessoais em linhas expansíveis e "Sair" (docs/telas.md).
//

import SwiftUI

struct PerfilView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = PerfilViewModel()
    @State private var expandida: PerfilSecao?
    @State private var showSolicitarAlteracaoEndereco = false
    @State private var confirmarSaida = false
    @State private var mostrarEmBreve = false
    @State private var receberPromocoes = true
    @State private var receberAvisos = true

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
                    desde: member.desde
                ) {
                    router.push(.cartaoDigital)
                }

                HStack(spacing: 10) {
                    HrGoldButton(text: "Ver benefícios") { router.switchTab(.beneficios) }
                    HrIconSquareButton(icon: "qrcode") { router.push(.cartaoDigital) }
                }

                HrSectionTitle(titulo: "Dados pessoais", subtitulo: "Gerencie suas informações e preferências.")
                    .padding(.top, 8)

                secao(.pessoais, icon: "person.fill", titulo: "Informações pessoais", subtitulo: "Seu nome, e-mail e telefone") {
                    infoLinha("Nome", viewModel.userName)
                    infoLinha("CPF/CNPJ", viewModel.userDocument)
                    infoLinha("E-mail", viewModel.userEmail.isEmpty ? "—" : viewModel.userEmail)
                    infoLinha("Telefone", viewModel.userPhone)
                }

                secao(.endereco, icon: "house.fill", titulo: "Endereço de correspondência", subtitulo: "Seu endereço cadastrado") {
                    Text(viewModel.userAddressLine1).font(HrFont.body).foregroundColor(.white)
                    Text(viewModel.userAddressLine2).font(HrFont.body).foregroundColor(.white)
                    if !viewModel.userAddressCep.isEmpty {
                        Text(viewModel.userAddressCep).font(HrFont.caption).foregroundColor(.hrTextMuted)
                    }
                    HrOutlineButton(text: "Solicitar alteração") { showSolicitarAlteracaoEndereco = true }
                        .padding(.top, 4)
                }

                secao(.preferencias, icon: "slider.horizontal.3", titulo: "Preferências", subtitulo: "Comunicações e experiências") {
                    Toggle(isOn: $receberPromocoes) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Receber campanhas e novidades").font(HrFont.itemTitle).foregroundColor(.white)
                            Text("Campanhas, benefícios e condições especiais").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                        }
                    }
                    .tint(.hrGold)
                    Toggle(isOn: $receberAvisos) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Avisos do empreendimento").font(HrFont.itemTitle).foregroundColor(.white)
                            Text("Notícias e comunicados").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                        }
                    }
                    .tint(.hrGold)
                }

                secao(.seguranca, icon: "shield.fill", titulo: "Segurança", subtitulo: "Senha, acesso e dispositivos") {
                    HrListRow(icon: "key.fill", titulo: "Alterar senha", subtitulo: "Troque sua senha de acesso") { mostrarEmBreve = true }
                    HrListRow(icon: "gearshape.fill", titulo: "Sistema", subtitulo: "Notificações, política e versão") { router.push(.sistema) }
                    HrListRow(icon: "hand.raised.fill", titulo: "Política de privacidade", subtitulo: "Como tratamos seus dados") { router.push(.politicaPrivacidade) }
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
            // Atalho de teste: `-hrScrollBottom` rola até o "Sair" para conferir o recuo da tab bar.
            if ProcessInfo.processInfo.arguments.contains("-hrScrollBottom") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation { proxy.scrollTo("sair", anchor: .bottom) }
                }
            }
            #endif
        }
        }
        .hrScreen()
        .task {
            await viewModel.loadUserData()
            if let prefs = try? await RepositoryProvider.member.notificationPreferences() {
                receberPromocoes = prefs.campaigns
                receberAvisos = prefs.announcements
            }
        }
        .onChange(of: receberPromocoes) { _, _ in salvarPreferencias() }
        .onChange(of: receberAvisos) { _, _ in salvarPreferencias() }
        .sheet(isPresented: $showSolicitarAlteracaoEndereco) {
            SolicitarAlteracaoEnderecoView()
                .environmentObject(appState)
        }
        .alert("Sair", isPresented: $confirmarSaida) {
            Button("Cancelar", role: .cancel) {}
            Button("Sair", role: .destructive) {
                Task { await appState.logout() }
            }
        } message: {
            Text("Deseja encerrar a sessão neste dispositivo?")
        }
        .alert("Em breve", isPresented: $mostrarEmBreve) {
            Button("OK") {}
        } message: {
            Text("A alteração de senha pelo app estará disponível em breve.")
        }
    }

    private func salvarPreferencias() {
        let prefs = NotificationPreferences(campaigns: receberPromocoes, announcements: receberAvisos)
        Task { _ = try? await RepositoryProvider.member.updateNotificationPreferences(prefs) }
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

#Preview {
    NavigationStack { PerfilView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
