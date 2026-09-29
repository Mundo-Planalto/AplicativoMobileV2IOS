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
    var onOpenDetails: (() -> Void)? = nil
    @State private var showPhotoBook = false

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
        VStack(spacing: 10) {
            ZStack(alignment: .topLeading) {
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
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()

                Text(venture.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)//estava 10
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.top, 14)
                    .padding(.leading, 14)
                    .offset(x: 20)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))

            // Uma linha, duas colunas: menos espaço entre os botões = cada um fica um pouco mais largo.
            HStack(spacing: 8) {
                Button {
                    if hasPhotoBook {
                        showPhotoBook = true
                    }
                } label: {
                    Text("Galeria de Fotos")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppColors.accentBlue.opacity(hasPhotoBook ? 1 : 0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                }
                .disabled(!hasPhotoBook)
                .frame(maxWidth: .infinity)

                Button {
                    onOpenDetails?()
                } label: {
                    Text("Acompanhamento de Obras")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.60)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppColors.accentBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 14)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
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
