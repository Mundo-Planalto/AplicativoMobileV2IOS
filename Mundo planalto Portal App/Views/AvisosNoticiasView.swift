//
//  AvisosNoticiasView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct AvisosNoticiasView: View {
    @StateObject private var viewModel = AvisosNoticiasViewModel()
    @State private var selectedNoticeId: String?

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentCyan))
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Button("Tentar Novamente") {
                            Task {
                                await viewModel.loadNotices()
                            }
                        }
                        .foregroundColor(AppColors.accentCyan)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.notices) { notice in
                                NoticeDetailCard(notice: notice)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        selectedNoticeId = notice.id
                                    }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationDestination(item: $selectedNoticeId) { noticeId in
            NoticiaDetalhesView(noticeId: noticeId)
        }
        .onAppear {
            Task {
                await viewModel.loadNotices()
            }
        }
    }
}

struct NoticeDetailCard: View {
    let notice: Notice

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header com tipo e data
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: notice.intelligentType == .notice ? "bell.fill" : "newspaper.fill")
                        .foregroundColor(notice.intelligentType == .notice ? .orange : AppColors.accentBlue)

                    Text(notice.intelligentType == .notice ? "Aviso" : "Notícia")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(notice.intelligentType == .notice ? .orange : AppColors.accentBlue)
                }

                Spacer()

                Text(notice.date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Título
            Text(notice.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(2)

            // Descrição
            Text(notice.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        AvisosNoticiasView()
    }
}