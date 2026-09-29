//
//  AvisosNoticiasView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

enum AvisosNoticiasFiltro: String, CaseIterable {
    case todos = "Todos"
    case avisos = "Avisos"
    case noticias = "Notícias"
}

struct AvisosNoticiasView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = AvisosNoticiasViewModel()
    @State private var filtro: String = AvisosNoticiasFiltro.todos.rawValue

    private var filteredNotices: [AppNotice] {
        switch AvisosNoticiasFiltro(rawValue: filtro) ?? .todos {
        case .todos: return viewModel.notices
        case .avisos: return viewModel.notices.filter { $0.type == .notice }
        case .noticias: return viewModel.notices.filter { $0.type == .news }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Avisos e notícias", subtitulo: "Comunicados e novidades do seu clube")

                HrChipRow(options: AvisosNoticiasFiltro.allCases.map(\.rawValue), selected: $filtro)

                if viewModel.isLoading {
                    ForEach(0..<3, id: \.self) { _ in
                        ShimmerSkeletonCard(height: 120, isDark: true)
                    }
                } else if let error = viewModel.error {
                    HrCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(error).font(HrFont.body).foregroundColor(.white)
                            HrOutlineButton(text: "Tentar novamente") { Task { await viewModel.loadNotices() } }
                        }
                    }
                } else if filteredNotices.isEmpty {
                    HrCard {
                        HStack(spacing: 12) {
                            HrIconBox(icon: "bell.slash")
                            Text("Nenhum aviso ou notícia disponível").font(HrFont.itemTitle).foregroundColor(.white)
                        }
                    }
                } else {
                    ForEach(filteredNotices) { notice in
                        NavigationLink(value: notice.id) {
                            NoticeDetailCard(notice: notice, isUnread: appState.isNoticeUnread(notice.id))
                        }
                        .buttonStyle(HrPressStyle())
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
        .navigationDestination(for: String.self) { noticeId in
            NoticiaDetalhesView(noticeId: noticeId)
        }
        .task {
            await viewModel.loadNotices()
            await appState.refreshUnreadNoticeCount()
        }
    }
}

struct NoticeDetailCard: View {
    let notice: Notice
    var isUnread: Bool = false

    private var isAviso: Bool { notice.type == .notice }

    var body: some View {
        HrCard(highlighted: isUnread) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HrTag(text: isAviso ? "Aviso" : "Notícia", color: isAviso ? .hrWarning : .hrGold)
                    if isUnread {
                        HrTag(text: "Novo", filled: true, color: .hrGoldLight)
                    }
                    Spacer()
                    Text(notice.date)
                        .font(HrFont.captionSmall)
                        .foregroundColor(.hrTextMuted)
                }
                Text(notice.title)
                    .font(HrFont.sectionTitle)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(notice.description.plainTextFromHTML())
                    .font(HrFont.body)
                    .foregroundColor(.hrTextMuted)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AvisosNoticiasView()
            .environmentObject(AppState.shared)
    }
}
