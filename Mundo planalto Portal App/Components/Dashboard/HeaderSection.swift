//
//  HeaderSection.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct HeaderSection: View {
    let greeting: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Spacer()

            Button(action: {
                // TODO: Implementar notificações
            }) {
                Image(systemName: "bell.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(AppColors.cardBackground.opacity(0.3))
                    )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    ZStack {
        AppColors.backgroundPrimary
            .ignoresSafeArea()
        HeaderSection(greeting: "Olá, João Silva")
    }
}