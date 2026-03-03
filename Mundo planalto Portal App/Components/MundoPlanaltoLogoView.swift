//
//  MundoPlanaltoLogoView.swift
//  Mundo planalto Portal App
//
//  Logo do app: ponto azul + linhas radiantes (como nos anexos).
//

import SwiftUI

struct MundoPlanaltoLogoView: View {
    var color: Color = AppColors.accentBlue
    var size: CGFloat = 80

    var body: some View {
        ZStack(alignment: .center) {
            // Linhas radiantes (estrela/asterisco)
            ForEach([0, 1, 2, 3, 4], id: \.self) { i in
                let angle = Angle.degrees(Double(i) * 72 - 90)
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: size * 0.35, height: 4)
                    .offset(x: size * 0.18)
                    .rotationEffect(angle)
            }
            // Ponto circular à direita
            Circle()
                .fill(color)
                .frame(width: size * 0.32, height: size * 0.32)
                .offset(x: size * 0.22)
        }
        .frame(width: size * 1.0, height: size)
    }
}

#Preview {
    VStack(spacing: 24) {
        MundoPlanaltoLogoView(size: 60)
        MundoPlanaltoLogoView(color: .blue, size: 100)
    }
    .padding()
}
