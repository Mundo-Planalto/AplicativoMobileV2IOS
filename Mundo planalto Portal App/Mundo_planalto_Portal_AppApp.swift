//
//  Mundo_planalto_Portal_AppApp.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

@main
struct Mundo_planalto_Portal_AppApp: App {
    
    var body: some Scene {
        WindowGroup {
            SplashScreenWithTimer()   // nova view que gerencia o timer
        }
    }
}

// Nova view que cuida do splash + timer
struct SplashScreenWithTimer: View {
    @State private var isSplashVisible = true
    
    var body: some View {
        if isSplashVisible {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            isSplashVisible = false
                        }
                    }
                }
                .onDisappear {
                    AppState.shared.checkInitialLoginState()
                }
        } else {
            ContentView()
        }
    }
}
