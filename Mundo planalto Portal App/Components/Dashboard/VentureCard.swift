//
//  VentureCard.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct VentureCard: View {
    let venture: Venture?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Imagem de fundo
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                )
                .cornerRadius(16)

            // Gradiente sobreposto
            LinearGradient(
                gradient: Gradient(colors: [
                    .clear,
                    .clear,
                    AppColors.backgroundPrimary.opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(16)

            // Conteúdo sobreposto
            VStack(alignment: .leading, spacing: 8) {
                Spacer()

                if let venture = venture {
                    Text(venture.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)

                    HStack {
                        ProgressView(value: venture.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accentCyan))
                            .frame(height: 6)

                        Text("\(Int(venture.progress * 100))%")
                            .font(.caption)
                            .foregroundColor(AppColors.accentCyan)
                    }

                    Text(venture.lastUpdate)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("Carregando obra...")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .frame(height: 200)
        .cornerRadius(16)
    }
}

#Preview {
    VentureCard(venture: Venture(
        id: "1",
        name: "Residencial Parque das Flores",
        imageUrl: "venture1",
        progress: 0.75,
        lastUpdate: "Atualizado há 2 dias"
    ))
    .padding()
    .background(AppColors.backgroundPrimary)
}