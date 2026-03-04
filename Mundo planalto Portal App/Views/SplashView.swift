//
//  SplashView.swift
//  Mundo planalto Portal App
//
//  Fundo e logo adaptados ao tema (claro/escuro). Suporte a iPhone e iPad.
//

import SwiftUI
import UIKit

struct SplashView: View {
    @EnvironmentObject private var appState: AppState
    @State private var opacity: Double = 0.6
    @State private var scale: Double = 0.95
    @State private var piscar: Bool = false
    @State private var blinkTimer: Timer?
    /// Tema lido na hora para garantir que a splash reflita a preferência salva (evita tema errado no dark).
    private var isDark: Bool {
        PreferencesManager.shared.getThemeMode()
    }

    /// Fundo: tema dark = só preto; tema claro = gradiente azul claro → branco
    private var gradientColors: [Color] {
        if isDark {
            return [Color.black, Color.black]
        }
        return [
            Color(hex: "#E3F2FD"),
            Color(hex: "#BBDEFB"),
            Color.white
        ]
    }

    private var logoSize: CGFloat {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? 160 : 120
        #else
        return 120
        #endif
    }

    var body: some View {
        ZStack {
            if isDark {
                Color.black
                    .ignoresSafeArea(edges: .all)
            } else {
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .all)
            }

            LogoMundoPlanaltoImageView(isDark: isDark, size: logoSize)
                .scaleEffect(scale)
                .opacity(opacity * (piscar ? 0.78 : 1.0))
                .animation(.easeInOut(duration: 1.0), value: piscar)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8)) {
                        opacity = 1.0
                        scale = 1.0
                    }
                    blinkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                        piscar.toggle()
                    }
                }
                .onDisappear {
                    blinkTimer?.invalidate()
                    blinkTimer = nil
                }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState.shared)
}
