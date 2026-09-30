//
//  MundoPlanaltoWordmark.swift
//  Hard Rock Hotel & Vacation Club
//
//  Marca da Mundo Planalto para as telas antes do login (Splash e Login):
//  símbolo do logo + "MUNDO PLANALTO" + "PORTAL DO CLIENTE", no tema preto e dourado.
//  O Hard Rock é um dos empreendimentos e só aparece depois do login.
//

import SwiftUI

struct MundoPlanaltoWordmark: View {
    var compact: Bool = false
    var symbolColor: Color = .hrGold

    var body: some View {
        VStack(spacing: compact ? 6 : 14) {
            Image("LogoMundoPlanalto")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(symbolColor)
                .aspectRatio(contentMode: .fit)
                .frame(width: compact ? 44 : 84, height: compact ? 44 : 84)
                .accessibilityHidden(true)
            VStack(spacing: compact ? 1 : 4) {
                Text("MUNDO PLANALTO")
                    .font(.system(size: compact ? 20 : 30, weight: .black))
                    .tracking(3)
                    .foregroundColor(.hrGold)
                Text("PORTAL DO CLIENTE")
                    .font(.system(size: compact ? 9 : 12, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.hrGoldLight)
            }
            .fixedSize()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Mundo Planalto, Portal do Cliente")
    }
}

#Preview {
    VStack(spacing: 40) {
        MundoPlanaltoWordmark()
        MundoPlanaltoWordmark(compact: true)
    }
    .padding()
    .hrScreen()
}
