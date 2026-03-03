//
//  SplashView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var opacity: Double = 0.6
    @State private var scale: Double = 0.95
    @State private var piscar: Bool = false
    @State private var blinkTimer: Timer?

    private var isDark: Bool { colorScheme == .dark }

    /// Gradiente conforme tema: claro = azul claro → branco; escuro = azul → cinza escuro
    private var gradientColors: [Color] {
        if isDark {
            return [
                AppColors.accentBlue.opacity(0.9),
                AppColors.accentCyan.opacity(0.5),
                AppColors.backgroundPrimaryDark
            ]
        }
        return [
            Color(hex: "#E3F2FD"),
            Color(hex: "#BBDEFB"),
            Color.white
        ]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            LogoMundoPlanaltoImageView(isDark: isDark, size: 120)
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
}
