//
//  LogoMundoPlanaltoImageView.swift
//  Mundo planalto Portal App
//
//  Exibe o logo do app (imagem). Sem fundo para facilitar: no dark mode
//  o ícone usa tint azul (template) para trocar branco/cinza por azul.
//

import SwiftUI

struct LogoMundoPlanaltoImageView: View {
    var isDark: Bool = false
    var size: CGFloat = 100

    var body: some View {
        Image("LogoMundoPlanalto")
            .resizable()
            .renderingMode(isDark ? .template : .original)
            .foregroundColor(isDark ? AppColors.accentBlue : nil)
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        LogoMundoPlanaltoImageView(isDark: false, size: 80)
            .background(Color.white)
        LogoMundoPlanaltoImageView(isDark: true, size: 80)
            .background(Color.black)
    }
    .padding()
}
