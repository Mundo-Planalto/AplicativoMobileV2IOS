//
//  QuickActionButton.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct QuickActionButton: View {
    let action: DashboardQuickAction
    var isDark: Bool = true

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: action.iconName)
                .font(.system(size: 26))
                .foregroundColor(AppColors.accentBlue)

            Text(action.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(textP)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(cardBg)
        .cornerRadius(12)
    }
}

#Preview {
    QuickActionButton(action: .viewStatement, isDark: false)
        .padding()
        .background(AppColors.backgroundPrimaryLight)
}
