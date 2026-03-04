//
//  EmpreendimentoCard.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct EmpreendimentoCard: View {
    let venture: Venture
    var isDark: Bool = true
    @State private var showPhotoBook = false

    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    private var hasPhotoBook: Bool {
        guard let book = venture.photoBook else { return false }
        return !book.isEmpty
    }

    private var imageUrlIsRemote: Bool {
        venture.imageUrl.hasPrefix("http")
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Imagem de fundo (URL do servidor ou ícone) — ocupa toda a largura do card
            Group {
                if imageUrlIsRemote {
                    RemoteImageView(urlString: venture.imageUrl, useAuth: true)
                } else {
                    Rectangle()
                        .fill(textS.opacity(0.15))
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 80))
                                .foregroundColor(textS.opacity(0.4))
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(height: 260)
            .clipped()
            .cornerRadius(16)
            .contentShape(Rectangle())

            LinearGradient(
                gradient: Gradient(colors: [.clear, .clear, bg.opacity(0.95)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(16)

            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)

                // Caixa de overlay (cantos superiores arredondados) — nome do empreendimento + botão
                VStack(alignment: .center, spacing: 12) {
                    Text(venture.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(textP)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    if hasPhotoBook {
                        Button {
                            showPhotoBook = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.caption)
                                Text("Ver Galeria de Fotos")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(AppColors.accentBlue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(cardBg)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.accentBlue, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(cardBg)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 16,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 16
                    )
                )
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .cornerRadius(16)
        .sheet(isPresented: $showPhotoBook) {
            PhotoBookView(items: venture.photoBook ?? [], isDark: isDark)
        }
    }
}

#Preview {
    EmpreendimentoCard(venture: Venture(
        id: "1",
        name: "Residencial Parque das Flores",
        imageUrl: "building.2.fill",
        progress: 0.75,
        lastUpdate: "Atualizado há 2 dias"
    ), isDark: false)
    .padding()
    .background(AppColors.backgroundPrimary(dark: false))
}
