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
            // Dashboard
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
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
        }
        .accentColor(AppColors.accentCyan)
    }
}

#Preview {
    MainTabView()
}