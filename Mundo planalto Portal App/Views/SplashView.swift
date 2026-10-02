//
//  SplashView.swift
//  Mundo Planalto
//
//  Fundo preto com gradiente radial dourado sutil (12%), MundoPlanaltoLogo pulsando
//  (opacidade 0.5↔1, 1 s) e linha dourada de 60pt. A decisão Login/Início fica em
//  SplashScreenWithTimer (2 s).
//

import SwiftUI

struct SplashView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color.hrBlack.ignoresSafeArea()

            RadialGradient(
                colors: [Color.hrGold.opacity(0.12), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 260
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                MundoPlanaltoLogo()
                    .opacity(pulse ? 1.0 : 0.5)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)

                Rectangle()
                    .fill(HrGradient.gold)
                    .frame(width: 60, height: 1)
            }
            .padding(.horizontal, HrMetrics.screenMargin)
        }
        .onAppear { pulse = true }
    }
}

#Preview {
    SplashView()
}
