//
//  MundoPlanaltoBrand.swift
//  Mundo Planalto
//
//  Componentes de marca (docs/marca.md): símbolo oficial e logo.
//  O símbolo nunca recebe gradiente, sombra, contorno nem outra cor além do dourado
//  (ou sua opacidade, quando usado como marca d'água).
//

import SwiftUI

/// Símbolo vetorial da marca (asterisco de 8 pontas com ponto), tingível.
struct MundoPlanaltoSymbol: View {
    let size: CGFloat
    var color: Color = .hrGold

    init(_ size: CGFloat = 24, color: Color = .hrGold) {
        self.size = size
        self.color = color
    }

    init(size: CGFloat, color: Color = .hrGold) {
        self.init(size, color: color)
    }

    /// Área de proteção do brandbook: X = diâmetro do ponto = 22,7% da largura do símbolo.
    static func protectionMargin(for size: CGFloat) -> CGFloat { size * 0.227 }

    var body: some View {
        Image("MundoPlanaltoSymbol")
            .resizable()
            .renderingMode(.template)
            .aspectRatio(1, contentMode: .fit)
            .foregroundColor(color)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// Símbolo à esquerda + wordmark em texto "MUNDO PLANALTO" e, abaixo, "VACATION CLUB".
/// Compacto: símbolo 24pt + "MUNDO PLANALTO" 14 bold.
/// Quando a logo horizontal oficial chegar, só este componente muda.
struct MundoPlanaltoLogo: View {
    var compact: Bool = false

    private var symbolSize: CGFloat { compact ? 24 : 52 }

    var body: some View {
        HStack(alignment: .center, spacing: max(MundoPlanaltoSymbol.protectionMargin(for: symbolSize), 8)) {
            MundoPlanaltoSymbol(symbolSize)
            if compact {
                Text("MUNDO PLANALTO")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(.hrGold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                VStack(alignment: .leading, spacing: 3) {
                    Text("MUNDO PLANALTO")
                        .font(.system(size: 34, weight: .black))
                        .tracking(3)
                        .foregroundColor(.hrGold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text("VACATION CLUB")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(2)
                        .foregroundColor(.hrGoldLight)
                        .lineLimit(1)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Mundo Planalto Vacation Club")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 40) {
        MundoPlanaltoLogo()
        MundoPlanaltoLogo(compact: true)
        HStack(spacing: 16) {
            MundoPlanaltoSymbol(18)
            MundoPlanaltoSymbol(size: 64)
            MundoPlanaltoSymbol(140, color: .hrGold.opacity(0.12))
        }
    }
    .padding(HrMetrics.screenMargin)
    .hrScreen()
}
