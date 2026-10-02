//
//  CartaoDigitalCard.swift
//  Mundo Planalto
//
//  Cartão do membro 1.6:1 (docs/telas.md, seção "Cartão digital").
//

import SwiftUI

struct CartaoDigitalCard: View {
    let nome: String
    let nivel: String
    let numeroMembro: String
    let desde: String
    /// `clubName` do backend (mock: "Mundo Planalto"). Não escrever Hard Rock nem The Orb aqui.
    var clube: String = "Mundo Planalto"
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

            // Marca d'água: símbolo da marca 140pt a 12% à direita.
            HStack {
                Spacer()
                MundoPlanaltoSymbol(140, color: .hrGold.opacity(0.12))
                    .offset(x: 24, y: 14)
            }
            .clipped()

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    MundoPlanaltoLogo(compact: true)
                    Spacer(minLength: 8)
                    Text(clube.uppercased())
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(1)
                        .foregroundColor(.hrGold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
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
        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    CartaoDigitalCard(nome: "José R. Castro", nivel: "Founder", numeroMembro: "8150", desde: "2026")
        .padding(HrMetrics.screenMargin)
        .hrScreen()
}
