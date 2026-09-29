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
    @EnvironmentObject private var appState: AppState
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @StateObject private var viewModel: NoticiaDetalhesViewModel

    init(noticeId: String) {
        self.noticeId = noticeId
        self._viewModel = StateObject(wrappedValue: NoticiaDetalhesViewModel(noticeId: noticeId))
    }

    private func attributedDescription(from html: String) -> AttributedString {
        let trimmed = html.trimmingCharacters(in: .whitespacesAndNewlines)
        let textColor = UIColor(AppColors.textPrimary(dark: appState.isDarkTheme))
        let linkColor = UIColor(AppColors.accentCyan)
        let ns = SafeHTMLParser.attributedString(
            from: trimmed,
            font: .systemFont(ofSize: 16),
            textColor: textColor,
            linkColor: linkColor
        )
        if var attributed = try? AttributedString(ns, including: \.uiKit) {
            return attributed
        }
        return AttributedString(trimmed.plainTextFromHTML())
    }

    var body: some View {
        let isDark = appState.isDarkTheme
        let bg = AppColors.backgroundPrimary(dark: isDark)
        let textP = AppColors.textPrimary(dark: isDark)
        let textS = AppColors.textSecondary(dark: isDark)
        let cardBg = AppColors.cardBackground(dark: isDark)
        let isPad = UIDevice.current.userInterfaceIdiom == .pad || hSizeClass == .regular
        let titleFont: Font = isPad ? .title : .headline
        let titleSpacing: CGFloat = isPad ? 12 : 8
        let contentPadding: CGFloat = isPad ? 18 : 14
        let sidePadding: CGFloat = isPad ? 20 : 14
        let maxContentWidth: CGFloat = isPad ? 720 : .infinity
        let cardCorner: CGFloat = isPad ? 14 : 12

        ZStack {
            bg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopAppBar
                ZStack {
                    bg
                        .ignoresSafeArea()

                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(textP)
                                .font(.title2)
                        }

                        Spacer()

                        if let notice = viewModel.notice {
                            Text(notice.type == .notice ? "Aviso" : "Notícia")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(textP)
                        }

                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 60)

                if viewModel.isLoading {
                    ScrollView {
                        VStack(spacing: 12) {
                            ShimmerSkeletonCard(height: 220, isDark: isDark)
                            ShimmerSkeletonCard(height: 14, isDark: isDark)
                                .padding(.horizontal, 20)
                            ShimmerSkeletonCard(height: 14, isDark: isDark)
                                .padding(.horizontal, 20)
                            ShimmerSkeletonCard(height: 14, isDark: isDark)
                                .padding(.horizontal, 20)
                            ShimmerSkeletonCard(height: 180, isDark: isDark)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    }
                } else {
                    if let notice = viewModel.notice {
                        ScrollView {
                            VStack(alignment: .leading, spacing: titleSpacing) {
                                // Badge tipo canto superior direito
                                HStack {
                                    Spacer()
                                    Text(notice.type == .notice ? "AVISO" : "NOTÍCIA")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(notice.type == .notice ? Color.orange : AppColors.accentBlue)
                                        )
                                }

                                // Header com tipo e data
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: notice.type == .notice ? "bell.fill" : "newspaper.fill")
                                            .foregroundColor(notice.type == .notice ? .orange : AppColors.accentBlue)

                                        Text(notice.type == .notice ? "Aviso" : "Notícia")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(notice.type == .notice ? .orange : AppColors.accentBlue)
                                    }

                                    Spacer()

                                    Text(notice.date)
                                        .font(.subheadline)
                                        .foregroundColor(textS)
                                }

                                // Título (mais legível no celular)
                                Text(notice.title)
                                    .font(titleFont)
                                    .fontWeight(.bold)
                                    .foregroundColor(textP)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)

                                // Conteúdo no estilo antigo, com links clicáveis ("clique aqui").
                                Text(attributedDescription(from: notice.description))
                                    .font(.body)
                                    .foregroundColor(textP)
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Espaço adicional no final
                                Spacer(minLength: 32)
                            }
                            .padding(contentPadding)
                            .frame(maxWidth: maxContentWidth, alignment: .leading)
                            .background(cardBg)
                            .cornerRadius(cardCorner)
                            .padding(.horizontal, sidePadding)
                            .padding(.top, 12)
                            .padding(.bottom, 24)
                        }
                    } else if let error = viewModel.error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            Text(error)
                                .foregroundColor(textP)
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
    NavigationView {
        NoticiaDetalhesView(noticeId: "1")
    }
}