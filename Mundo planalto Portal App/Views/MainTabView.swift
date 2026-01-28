//
//  MainTabView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            // Início
            DashboardView()
                .tabItem {
                    Label("Início", systemImage: "house.fill")
                }
                .tag(TabItem.home)

            // Empreendimentos
            NavigationStack {
                EmpreendimentosView()
            }
            .tabItem {
                Label("Empreendimentos", systemImage: "building.2.fill")
            }
            .tag(TabItem.ventures)

            // Notícias
            NavigationStack {
                AvisosNoticiasView()
            }
            .tabItem {
                Label("Notícias", systemImage: "bell.fill")
            }
            .tag(TabItem.news)

            // Perfil
            NavigationStack {
                PerfilView()
            }
            .tabItem {
                Label("Perfil", systemImage: "person.fill")
            }
            .tag(TabItem.profile)
        }
        .accentColor(AppColors.accentCyan)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToFinancial"))) { _ in
            selectedTab = .home // O ExtratoView pode ser acessado de outras formas
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToVentures"))) { _ in
            selectedTab = .ventures
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToNews"))) { _ in
            selectedTab = .news
        }
    }
}

#Preview {
    MainTabView()
}