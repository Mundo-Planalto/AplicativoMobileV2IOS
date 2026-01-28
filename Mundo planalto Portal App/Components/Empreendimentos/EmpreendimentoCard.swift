//
//  EmpreendimentoCard.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct EmpreendimentoCard: View {
    let venture: Venture

    var body: some View {
        ZStack(alignment: .bottom) {
            // Imagem de fundo
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 360)
                .overlay(
                    Image(systemName: venture.imageUrl)
                        .font(.system(size: 80))
                        .foregroundColor(.gray.opacity(0.5))
                )
                .cornerRadius(16)
                .contentShape(Rectangle())

            // Gradiente sobreposto
            LinearGradient(
                gradient: Gradient(colors: [
                    .clear,
                    .clear,
                    AppColors.backgroundPrimary.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(16)

            // Conteúdo sobreposto
            VStack(alignment: .leading, spacing: 16) {
                Spacer()

                Text(venture.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)

                // Card branco com progresso
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Progresso da obra")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        HStack(spacing: 12) {
                            ProgressView(value: venture.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accentCyan))
                                .frame(height: 6)

                            Text("\(Int(venture.progress * 100))%")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.accentCyan)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                .padding()
                .background(.white)
                .cornerRadius(12)
                .padding(.bottom, 8)
            }
            .padding()
        }
        .frame(height: 360)
        .cornerRadius(16)
    }
}

#Preview {
    EmpreendimentoCard(venture: Venture(
        id: "1",
        name: "Residencial Parque das Flores",
        imageUrl: "building.2.fill",
        progress: 0.75,
        lastUpdate: "Atualizado há 2 dias"
    ))
    .padding()
    .background(AppColors.backgroundPrimary)
}