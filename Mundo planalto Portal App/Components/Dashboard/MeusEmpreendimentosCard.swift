//
//  MeusEmpreendimentosCard.swift
//  Mundo planalto Portal App
//

import SwiftUI

struct MeusEmpreendimentosCard: View {
    var isDark: Bool = true
    var count: Int = 2

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "building.2.fill")
                .font(.title2)
                .foregroundColor(AppColors.accentBlue)

            VStack(alignment: .leading, spacing: 2) {
                Text("Meus Empreendimentos")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(textP)
                Text("\(count) empreendimentos")
                    .font(.subheadline)
                    .foregroundColor(textS)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundColor(textS)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBg)
        .cornerRadius(12)
    }
}

#Preview {
    MeusEmpreendimentosCard(isDark: false, count: 2)
        .padding()
        .background(AppColors.backgroundPrimaryLight)
}
