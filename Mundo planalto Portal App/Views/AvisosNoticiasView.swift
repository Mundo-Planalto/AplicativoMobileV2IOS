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
    @State private var selectedNoticeId: String?
    @State private var filtro: AvisosNoticiasFiltro = .todos

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }

    private var filteredNotices: [AppNotice] {
        switch filtro {
        case .todos: return viewModel.notices
        case .avisos: return viewModel.notices.filter { $0.intelligentType == .notice }
        case .noticias: return viewModel.notices.filter { $0.intelligentType == .news }
        }
    }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            VStack(spacing: 0) {
                Text("Avisos e Notícias")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(textP)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                HStack(spacing: 12) {
                    ForEach(AvisosNoticiasFiltro.allCases, id: \.rawValue) { opcao in
                        Button {
                            filtro = opcao
                        } label: {
                            Text(opcao.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(filtro == opcao ? .white : textP)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(filtro == opcao ? AppColors.accentBlue : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(textS.opacity(0.5), lineWidth: filtro == opcao ? 0 : 1)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentBlue))
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(textP)
                            .multilineTextAlignment(.center)
                        Button("Tentar Novamente") {
                            Task { await viewModel.loadNotices() }
                        }
                        .foregroundColor(AppColors.accentBlue)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredNotices) { notice in
                                NoticeDetailCard(notice: notice, isDark: isDark)
                                    .padding(.horizontal, 20)
                                    .onTapGesture { selectedNoticeId = notice.id }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationDestination(item: $selectedNoticeId) { noticeId in
            NoticiaDetalhesView(noticeId: noticeId)
        }
        .onAppear {
            Task { await viewModel.loadNotices() }
        }
    }
}

struct NoticeDetailCard: View {
    let notice: Notice
    var isDark: Bool = true

    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                    .foregroundColor(textS)
            }
            Text(notice.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(textP)
                .lineLimit(2)
            Text(notice.description)
                .font(.body)
                .foregroundColor(textS)
                .lineSpacing(4)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBg)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        AvisosNoticiasView()
            .environmentObject(AppState.shared)
    }
}
