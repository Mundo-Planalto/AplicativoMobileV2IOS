//
//  MainTabView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: TabItem = .home

    private var isDark: Bool { appState.isDarkTheme }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Início", systemImage: "house.fill")
            }
            .tag(TabItem.home)

            NavigationStack {
                EmpreendimentosView()
            }
            .tabItem {
                Label("Empreendimentos", systemImage: "building.2.fill")
            }
            .tag(TabItem.ventures)

            NavigationStack {
                AvisosNoticiasView()
            }
            .tabItem {
                Label("Notícias", systemImage: "bell.fill")
            }
            .badge(appState.unreadNoticeCount > 0 ? appState.unreadNoticeCount : 0)
            .tag(TabItem.news)

            NavigationStack {
                PerfilView()
            }
            .tabItem {
                Label("Perfil", systemImage: "person.fill")
            }
            .tag(TabItem.profile)
        }
        .tint(AppColors.accentBlue)
        .task {
            await appState.refreshAllUnreadBadges()
        }
        .onReceive(NotificationCenter.default.publisher(for: .noticeUnreadCountShouldRefresh)) { _ in
            Task { await appState.refreshAllUnreadBadges() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToNews"))) { _ in
            selectedTab = .news
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToVentures"))) { _ in
            selectedTab = .ventures
        }
        .onChange(of: selectedTab) { _, tab in
            if tab == .news {
                Task { await appState.refreshUnreadNoticeCount() }
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState.shared)
}