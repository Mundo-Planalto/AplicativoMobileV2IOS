//
//  SplashView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct SplashView: View {
    @State private var opacity: Double = 0.3
    @State private var scale: Double = 0.8

    var body: some View {
        ZStack {
            // Gradiente de fundo
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.accentBlue.opacity(0.8),
                    AppColors.accentCyan.opacity(0.6),
                    AppColors.backgroundPrimary
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                // Logo animado
                ZStack {
                    Circle()
                        .fill(AppColors.accentCyan.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Text("MP")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.accentCyan)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        opacity = 1.0
                        scale = 1.0
                    }
                }

                Spacer()

                // Nome do app
                Text("Mundo Planalto Portal")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    SplashView()
}