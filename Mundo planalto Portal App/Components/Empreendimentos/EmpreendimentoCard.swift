//
//  EmpreendimentoCard.swift
//  Mundo Planalto
//
//  Card do empreendimento na lista: foto full-bleed 320pt, nome em badge preto translúcido
//  com borda dourada, cidade/UF e um único botão "Abrir" (o toque no card também abre).
//

import SwiftUI

/// Foto do empreendimento: mídia do portal exige Bearer; demais URLs usam HrPhoto.
struct VenturePhoto: View {
    let venture: Venture
    var height: CGFloat
    var darkenBottom = true

    var body: some View {
        Group {
            if venture.imageUrl.hasPrefix("http") {
                if venture.imageUrl.contains("mundoplanalto") {
                    ZStack {
                        HrGradient.photoPlaceholder
                        Color.clear.overlay(RemoteImageView(urlString: venture.imageUrl, useAuth: true)).clipped()
                        if darkenBottom { HrGradient.photoOverlay }
                    }
                } else {
                    HrPhoto(url: venture.imageUrl, height: height, darkenBottom: darkenBottom, placeholderIcon: "building.2.fill")
                }
            } else {
                HrPhoto(url: nil, height: height, darkenBottom: darkenBottom)
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

struct EmpreendimentoCard: View {
    let venture: Venture
    var onOpen: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Button { onOpen?() } label: {
                ZStack(alignment: .topLeading) {
                    VenturePhoto(venture: venture, height: 320)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(venture.name)
                            .font(HrFont.sectionTitle)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        if !venture.localTexto.isEmpty {
                            Text(venture.localTexto)
                                .font(HrFont.caption)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        if let unit = venture.unit, !unit.isEmpty {
                            Text(unit)
                                .font(HrFont.captionSmall)
                                .foregroundColor(.hrGoldLight)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.black.opacity(0.55)))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.hrGold, lineWidth: 1))
                    .padding(14)
                }
                .clipShape(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous).stroke(Color.hrGoldBorder, lineWidth: 1))
            }
            .buttonStyle(HrPressStyle())

            HrGoldButton(text: "Abrir") { onOpen?() }
        }
    }
}

#Preview {
    EmpreendimentoCard(venture: VenturesRepositoryMock.demoVenture)
        .padding(HrMetrics.screenMargin)
        .hrScreen()
}
