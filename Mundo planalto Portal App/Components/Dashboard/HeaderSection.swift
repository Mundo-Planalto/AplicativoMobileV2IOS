//
//  HeaderSection.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct HeaderSection: View {
    let greeting: String
    var isDark: Bool = true
    @EnvironmentObject private var appState: AppState

    private var notificationsOn: Bool { appState.notificationsEnabled }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary(dark: isDark))
                    .lineLimit(2)
            }
            Spacer()

            Button {
                appState.setNotificationsEnabled(!notificationsOn)
            } label: {
                Image(systemName: notificationsOn ? "bell.fill" : "bell.slash.fill")
                    .foregroundColor(AppColors.textPrimary(dark: isDark))
                    .font(.title2)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(AppColors.cardBackground(dark: isDark).opacity(0.3))
                    )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    ZStack {
        AppColors.backgroundPrimary(dark: true)
            .ignoresSafeArea()
        HeaderSection(greeting: "Olá, João Silva", isDark: true)
            .environmentObject(AppState.shared)
    }
}