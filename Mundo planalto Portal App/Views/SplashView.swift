//
//  SplashView.swift
//  Hard Rock Hotel & Vacation Club
//
//  Fundo preto com gradiente radial dourado sutil, marca Mundo Planalto pulsando
//  e linha dourada. O Hard Rock só aparece depois do login. A decisão Login/Início fica em SplashScreenWithTimer (2 s).
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

            VStack(spacing: 18) {
                MundoPlanaltoWordmark()
                    .opacity(pulse ? 1.0 : 0.5)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)

                Rectangle()
                    .fill(Color.hrGold)
                    .frame(width: 60, height: 1)

                Text("GOIÂNIA • GO")
                    .font(.system(size: 11, weight: .regular))
                    .tracking(4)
                    .foregroundColor(.hrTextMuted)
            }
        }
        .onAppear { pulse = true }
    }
}

#Preview {
    SplashView()
}
