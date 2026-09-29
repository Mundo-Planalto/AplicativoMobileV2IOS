//
//  CartaoDigitalCard.swift
//  Hard Rock Hotel & Vacation Club
//
//  Cartão do membro 1.6:1 (docs/telas.md, seção "Cartão digital").
//

import SwiftUI

struct CartaoDigitalCard: View {
    let nome: String
    let nivel: String
    let numeroMembro: String
    let desde: String
    var onTap: (() -> Void)? = nil

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
        ZStack(alignment: .topLeading) {
            // Gradiente preto → #1C1C1C com brilho diagonal dourado 15%.
            LinearGradient(colors: [.black, Color(hex: "#1C1C1C")], startPoint: .topLeading, endPoint: .bottomTrailing)
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.2),
                    .init(color: .hrGold.opacity(0.15), location: 0.5),
                    .init(color: .clear, location: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Marca d'água music.note 140pt a 25% à direita.
            HStack {
                Spacer()
                Image(systemName: "music.note")
                    .font(.system(size: 140, weight: .regular))
                    .foregroundColor(.hrGold.opacity(0.25))
                    .offset(x: 20, y: 10)
            }
            .clipped()

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    HrWordmark(compact: true, alignment: .leading)
                    Spacer()
                    Text("GOOD MUSIC · GREATER JOURNEYS")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(1)
                        .foregroundColor(.hrGold)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .frame(maxWidth: 130, alignment: .trailing)
                }

                Spacer()

                HrTag(text: "Membro")
                Text(nome)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.top, 6)

                Spacer()

                HStack(alignment: .bottom) {
                    Text("•••• \(numeroMembro)")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 8) {
                        Text("Desde \(desde)")
                            .font(HrFont.captionSmall)
                            .foregroundColor(.hrTextMuted)
                        HrTag(text: nivel, filled: true)
                    }
                }
            }
            .padding(18)
        }
        .aspectRatio(1.6, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.hrGold, lineWidth: 1)
        )
        .shadow(color: .hrGoldDark.opacity(0.25), radius: 16, x: 0, y: 8)
    }
}

#Preview {
    CartaoDigitalCard(nome: "José R. Castro", nivel: "Founder", numeroMembro: "8150", desde: "2026")
        .padding(HrMetrics.screenMargin)
        .hrScreen()
}
