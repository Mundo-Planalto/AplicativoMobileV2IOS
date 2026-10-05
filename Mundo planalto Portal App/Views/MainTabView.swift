//
//  MainTabView.swift
//  Mundo Planalto
//
//  TabView com 5 abas (Início, Benefícios, Campanhas, Empreendimentos, Perfil),
//  cada uma com sua NavigationStack e rotas de AppRoute. A tab bar do sistema fica
//  oculta e a HrTabBar fica abaixo do TabView, com espaço próprio.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var router = AppRouter()

    var body: some View {
        // A HrTabBar ocupa espaço próprio abaixo do TabView (não flutua por cima do conteúdo),
        // então o fim de toda rolagem, inclusive das telas empilhadas, termina acima dela.
        VStack(spacing: 0) {
            if appState.isDemoSession { HrDemoBanner() }
            TabView(selection: $router.selectedTab) {
                tabContent(.inicio) { InicioView() }
                tabContent(.beneficios) { BeneficiosView() }
                tabContent(.campanhas) { CampanhasView() }
                tabContent(.empreendimentos) { EmpreendimentosView() }
                tabContent(.perfil) { PerfilView() }
            }
            HrTabBar(selected: $router.selectedTab)
        }
        .background(Color.hrBlack.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .environmentObject(router)
        .hrBrowser($router.browser)
        .task {
            await appState.refreshAllUnreadBadges()
        }
        .onReceive(NotificationCenter.default.publisher(for: .noticeUnreadCountShouldRefresh)) { _ in
            Task { await appState.refreshAllUnreadBadges() }
        }
        // Compatibilidade com o push e com a Início antiga.
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToNews"))) { _ in
            router.push(.avisosNoticias, on: .inicio)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToVentures"))) { _ in
            router.switchTab(.empreendimentos)
        }
    }

    private func tabContent<Root: View>(_ tab: TabItem, @ViewBuilder root: @escaping () -> Root) -> some View {
        NavigationStack(path: router.path(for: tab)) {
            root()
                .navigationDestination(for: AppRoute.self) { route in
                    RouteView(route: route)
                }
                .toolbar(.hidden, for: .tabBar)
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.hidden, for: .tabBar)
        .tag(tab)
    }
}

/// Resolve cada AppRoute para a tela correspondente.
struct RouteView: View {
    let route: AppRoute

    var body: some View {
        Group {
            switch route {
            case .financeiro:
                FinanceiroView()
            case .extrato:
                ExtratoView()
            case .informeRendimentos:
                InformeRendimentosView()
            case .viagens:
                ViagensView()
            case .cartaoDigital:
                CartaoDigitalView()
            case .perfilViagem:
                PerfilViagemView()
            case .alteracaoDados(let field):
                AlteracaoDadosView(campoInicial: field)
            case .avisosNoticias:
                AvisosNoticiasView()
            case .politicaPrivacidade:
                PoliticaPrivacidadeView()
            case .sistema:
                SistemaView()
            case .financeiroEmpreendimento(let venture):
                FinanceiroView(venture: venture)
            case .empreendimento(let venture):
                EmpreendimentoHubView(venture: venture)
            case .galeria(let venture):
                GaleriaView(venture: venture)
            case .videosObra(let venture):
                DetalhesObraView(venture: venture)
            case .documentos(let venture):
                DocumentosView(venture: venture)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState.shared)
}
