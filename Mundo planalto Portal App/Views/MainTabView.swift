//
//  MainTabView.swift
//  Hard Rock Hotel & Vacation Club
//
//  TabView com 5 abas (Início, Benefícios, Ofertas, Empreendimentos, Perfil),
//  cada uma com sua NavigationStack e rotas de AppRoute. A tab bar do sistema fica
//  oculta e a HrTabBar é desenhada como safeAreaInset inferior de cada aba.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var router = AppRouter()

    var body: some View {
        TabView(selection: $router.selectedTab) {
            tabContent(.inicio) { InicioView() }
            tabContent(.beneficios) { BeneficiosView() }
            tabContent(.ofertas) { OfertasView() }
            tabContent(.empreendimentos) { EmpreendimentosView() }
            tabContent(.perfil) { PerfilView() }
        }
        .environmentObject(router)
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
        // A barra entra como recuo de segurança de cada aba: assim o fim de toda rolagem,
        // inclusive das telas empilhadas, fica acima dela e nada é encoberto.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HrTabBar(selected: $router.selectedTab)
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
            case .certificados:
                CertificadosView()
            case .unityMilhas:
                UnityMilhasView()
            case .cartaoDigital:
                CartaoDigitalView()
            case .avisosNoticias:
                AvisosNoticiasView()
            case .politicaPrivacidade:
                PoliticaPrivacidadeView()
            case .sistema:
                SistemaView()
            case .detalhesObra(let venture):
                DetalhesObraView(venture: venture)
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
