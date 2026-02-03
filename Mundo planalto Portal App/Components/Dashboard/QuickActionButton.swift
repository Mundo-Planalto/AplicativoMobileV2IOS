//
//  QuickActionButton.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct QuickActionButton: View {
    let action: DashboardQuickAction

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: action.color))
                    .frame(width: 56, height: 56)

                Image(systemName: action.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            Text(action.rawValue)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 30)
        }
        .frame(width: 80)
    }
}

#Preview {
    QuickActionButton(action: .viewStatement)
        .padding()
        .background(AppColors.backgroundPrimary)
}