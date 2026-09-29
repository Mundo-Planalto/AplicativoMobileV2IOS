//
//  EmpreendimentoCard.swift
//  Hard Rock Hotel & Vacation Club
//
//  Card do empreendimento: foto full-bleed 320pt, nome em badge preto translúcido com
//  borda dourada, botões "Galeria de fotos" (outline) e "Acompanhamento de obras" (dourado).
//

import SwiftUI

struct EmpreendimentoCard: View {
    let venture: Venture
    var onOpenDetails: (() -> Void)? = nil
    @State private var showPhotoBook = false

    private var hasPhotoBook: Bool { !(venture.photoBook ?? []).isEmpty }
    private var imageUrlIsRemote: Bool { venture.imageUrl.hasPrefix("http") }

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topLeading) {
                Group {
                    if imageUrlIsRemote {
                        if venture.imageUrl.contains("mundoplanalto") {
                            // Mídia do portal exige Bearer.
                            Color.clear.overlay(RemoteImageView(urlString: venture.imageUrl, useAuth: true)).clipped()
                        } else {
                            HrPhoto(url: venture.imageUrl, height: 320, darkenBottom: true, placeholderIcon: "building.2.fill")
                        }
                    } else {
                        ZStack {
                            HrGradient.photoPlaceholder
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.hrGoldLight.opacity(0.5))
                        }
                    }
                }
                .frame(height: 320)
                .frame(maxWidth: .infinity)
                .clipped()

                HrGradient.photoOverlay
                    .frame(height: 320)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 6) {
                    Text(venture.name)
                        .font(HrFont.sectionTitle)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    if let unit = venture.unit, !unit.isEmpty {
                        Text(unit)
                            .font(HrFont.captionSmall)
                            .foregroundColor(.hrGoldLight)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.55))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.hrGold, lineWidth: 1)
                )
                .padding(14)
            }
            .clipShape(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous)
                    .stroke(Color.hrGoldBorder, lineWidth: 1)
            )

            HStack(spacing: 8) {
                HrOutlineButton(text: "Galeria de fotos", icon: "photo.on.rectangle", isEnabled: hasPhotoBook) {
                    showPhotoBook = true
                }
                HrGoldButton(text: "Acompanhamento de obras") {
                    onOpenDetails?()
                }
            }
        }
        .sheet(isPresented: $showPhotoBook) {
            PhotoBookView(items: venture.photoBook ?? [])
        }
    }
}

#Preview {
    EmpreendimentoCard(venture: EmpreendimentosViewModel.demoVenture)
        .padding(HrMetrics.screenMargin)
        .hrScreen()
}
