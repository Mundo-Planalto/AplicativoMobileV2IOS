//
//  HrCards.swift
//  Hard Rock Hotel & Vacation Club
//
//  HrCard (container padrão) e HrPhoto (imagem remota sobre gradiente).
//

import SwiftUI

/// Container padrão: raio 16, borda 1pt hrGoldBorder (hrGold quando em destaque), padding 16.
struct HrCard<Content: View>: View {
    var highlighted: Bool = false
    var padding: CGFloat = HrMetrics.cardPadding
    var onTap: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) { card }
                    .buttonStyle(HrPressStyle())
            } else {
                card
            }
        }
    }

    private var card: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Group {
                    if highlighted {
                        HrGradient.card
                    } else {
                        Color.hrSurface
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous)
                    .stroke(highlighted ? Color.hrGold : Color.hrGoldBorder, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous))
    }
}

/// Foto remota: AsyncImage por cima de um gradiente escuro/dourado; opcionalmente
/// escurece a metade inferior para o texto ficar legível.
struct HrPhoto: View {
    let url: String?
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = 0
    var darkenBottom: Bool = false
    var placeholderIcon: String = "photo"

    var body: some View {
        ZStack {
            HrGradient.photoPlaceholder
            if let url, let parsed = URL(string: url) {
                // Color.clear define o tamanho do layout; a imagem em scaledToFill só desenha
                // por cima e é recortada, sem alargar o card além da largura proposta.
                Color.clear
                    .overlay(
                        AsyncImage(url: parsed, transaction: Transaction(animation: .easeIn(duration: 0.25))) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                placeholder
                            case .empty:
                                ProgressView().tint(.hrGoldLight)
                            @unknown default:
                                placeholder
                            }
                        }
                    )
                    .clipped()
            } else {
                placeholder
            }
            if darkenBottom {
                HrGradient.photoOverlay
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var placeholder: some View {
        Image(systemName: placeholderIcon)
            .font(.system(size: 28))
            .foregroundColor(.hrGoldLight.opacity(0.6))
    }
}

/// Card com foto de fundo e conteúdo sobreposto (hero da Início, Financeiro, Certificados).
struct HrPhotoCard<Content: View>: View {
    let url: String?
    var height: CGFloat = 220
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HrPhoto(url: url, height: height, darkenBottom: true)
            content()
                .padding(HrMetrics.cardPadding)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HrMetrics.cardRadius, style: .continuous)
                .stroke(Color.hrGoldBorder, lineWidth: 1)
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            HrCard {
                Text("Card padrão").foregroundColor(.white)
            }
            HrCard(highlighted: true) {
                Text("Card em destaque").foregroundColor(.white)
            }
            HrPhotoCard(url: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800") {
                Text("Gramado te espera").font(HrFont.heroTitle).foregroundColor(.white)
            }
        }
        .padding()
    }
    .hrScreen()
}
