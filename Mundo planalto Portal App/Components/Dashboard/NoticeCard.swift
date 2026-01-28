//
//  NoticeCard.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct NoticeCard: View {
    let notice: Notice

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: notice.type == .notice ? "bell.fill" : "newspaper.fill")
                    .foregroundColor(notice.type == .notice ? .orange : AppColors.accentBlue)
                    .font(.title3)

                Spacer()

                Text(notice.date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Text(notice.title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)

            Text(notice.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding()
        .frame(width: 280)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    NoticeCard(notice: Notice(
        id: "1",
        title: "Reunião de Condôminos",
        description: "Reunião marcada para o dia 15/02 às 19h",
        date: "10/01/2025",
        type: .notice
    ))
    .padding()
    .background(AppColors.backgroundPrimary)
}