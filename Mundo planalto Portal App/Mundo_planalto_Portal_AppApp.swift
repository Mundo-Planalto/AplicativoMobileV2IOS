//
//  Mundo_planalto_Portal_AppApp.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

@main
struct Mundo_planalto_Portal_AppApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onDisappear {
                        AppState.shared.checkInitialLoginState()
                    }
            } else {
                ContentView()
            }
        }
    }

    init() {
        // Delay para mostrar splash por pelo menos 2 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showSplash = false
        }
    }
}
