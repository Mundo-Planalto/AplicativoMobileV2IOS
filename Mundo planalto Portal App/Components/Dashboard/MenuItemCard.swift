//
//  MenuItemCard.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct MenuItemCard: View {
    let item: MenuItem

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.iconName)
                .font(.title2)
                .foregroundColor(AppColors.accentCyan)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .contentShape(Rectangle())
    }
}

#Preview {
    MenuItemCard(item: MenuItem(
        title: "Meus Empreendimentos",
        subtitle: "Acompanhe suas obras",
        iconName: "building.2.fill",
        destination: .ventures
    ))
    .padding()
    .background(AppColors.backgroundPrimary)
}