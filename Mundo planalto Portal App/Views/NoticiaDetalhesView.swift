//
//  NoticiaDetalhesView.swift
//  Hard Rock Hotel & Vacation Club
//

import SwiftUI

struct NoticiaDetalhesView: View {
    let noticeId: String
    @StateObject private var viewModel: NoticiaDetalhesViewModel

    init(noticeId: String) {
        self.noticeId = noticeId
        self._viewModel = StateObject(wrappedValue: NoticiaDetalhesViewModel(noticeId: noticeId))
    }

    private func attributedDescription(from html: String) -> AttributedString {
        let trimmed = html.trimmingCharacters(in: .whitespacesAndNewlines)
        let ns = SafeHTMLParser.attributedString(
            from: trimmed,
            font: .systemFont(ofSize: 15),
            textColor: .white,
            linkColor: UIColor(Color.hrGoldLight)
        )
        if let attributed = try? AttributedString(ns, including: \.uiKit) {
            return attributed
        }
        return AttributedString(trimmed.plainTextFromHTML())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                let isAviso = viewModel.notice?.type == .notice
                HrBackHeader(titulo: isAviso ? "Aviso" : "Notícia", subtitulo: viewModel.notice?.date)

                if viewModel.isLoading {
                    ShimmerSkeletonCard(height: 220, isDark: true)
                } else if let notice = viewModel.notice {
                    HrCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                HrTag(text: isAviso ? "Aviso" : "Notícia", color: isAviso ? .hrWarning : .hrGold)
                                Spacer()
                                Text(notice.date).font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                            }
                            Text(notice.title)
                                .font(HrFont.heroTitle)
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(attributedDescription(from: notice.description))
                                .font(HrFont.body)
                                .foregroundColor(.white)
                                .lineSpacing(5)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .tint(.hrGoldLight)
                        }
                    }
                } else if let error = viewModel.error {
                    HrCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(error).font(HrFont.body).foregroundColor(.white)
                            HrOutlineButton(text: "Tentar novamente") { Task { await viewModel.loadNoticeDetails() } }
                        }
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
        .task { await viewModel.loadNoticeDetails() }
    }
}

#Preview {
    NavigationStack { NoticiaDetalhesView(noticeId: "demo-1") }
        .environmentObject(AppState.shared)
}
