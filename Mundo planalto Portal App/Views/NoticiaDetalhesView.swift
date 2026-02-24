//
//  NoticiaDetalhesView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct NoticiaDetalhesView: View {
    let noticeId: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NoticiaDetalhesViewModel

    init(noticeId: String) {
        self.noticeId = noticeId
        self._viewModel = StateObject(wrappedValue: NoticiaDetalhesViewModel(noticeId: noticeId))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopAppBar
                ZStack {
                    AppColors.backgroundPrimary
                        .ignoresSafeArea()

                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }

                        Spacer()

                        if let notice = viewModel.notice {
                            Text(notice.intelligentType == .notice ? "Aviso" : "Notícia")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 60)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentCyan))
                    Spacer()
                } else {
                    if let notice = viewModel.notice {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                // Badge tipo canto superior direito
                                HStack {
                                    Spacer()
                                    Text(notice.intelligentType == .notice ? "AVISO" : "NOTÍCIA")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(notice.intelligentType == .notice ? Color.orange : AppColors.accentBlue)
                                        )
                                }

                                // Header com tipo e data
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: notice.intelligentType == .notice ? "bell.fill" : "newspaper.fill")
                                            .foregroundColor(notice.intelligentType == .notice ? .orange : AppColors.accentBlue)

                                        Text(notice.intelligentType == .notice ? "Aviso" : "Notícia")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(notice.intelligentType == .notice ? .orange : AppColors.accentBlue)
                                    }

                                    Spacer()

                                    Text(notice.date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                // Título grande
                                Text(notice.title)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .lineSpacing(8)

                                // Conteúdo completo
                                Text(notice.description)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.leading)

                                // Espaço adicional no final
                                Spacer(minLength: 32)
                            }
                            .padding()
                        }
                    } else if let error = viewModel.error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            Text(error)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Button("Tentar Novamente") {
                                Task {
                                    await viewModel.loadNoticeDetails()
                                }
                            }
                            .foregroundColor(AppColors.accentCyan)
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadNoticeDetails()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        NoticiaDetalhesView(noticeId: "1")
    }
}