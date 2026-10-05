//
//  ContentView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var appState = AppState.shared

    var body: some View {
        Group {
            if appState.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environmentObject(appState)
        .preferredColorScheme(.dark)
        .onAppear {
            // Firebase push: em momento separado do login do usuário para evitar timeout.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                AppDelegate.shared?.setupPushNotificationsIfNeeded()
            }
        }
    }
}

#Preview {
    ContentView()
}