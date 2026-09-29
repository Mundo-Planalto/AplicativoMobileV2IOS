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
    @State private var filtro: AvisosNoticiasFiltro = .todos

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }

    private var filteredNotices: [AppNotice] {
        switch filtro {
        case .todos: return viewModel.notices
        case .avisos: return viewModel.notices.filter { $0.type == .notice }
        case .noticias: return viewModel.notices.filter { $0.type == .news }
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
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { _ in
                                ShimmerSkeletonCard(height: 150, isDark: isDark)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 8)
                    }
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
                    if filteredNotices.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "bell.slash")
                                .font(.system(size: 44))
                                .foregroundColor(AppColors.accentBlue)
                            Text("Nenhum aviso/notícia disponível")
                                .foregroundColor(textP)
                                .font(.headline)
                        }
                        .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredNotices) { notice in
                                    NavigationLink(value: notice.id) {
                                        NoticeDetailCard(
                                            notice: notice,
                                            isDark: isDark,
                                            isUnread: appState.isNoticeUnread(notice.id)
                                        )
                                        .padding(.horizontal, 20)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: String.self) { noticeId in
            NoticiaDetalhesView(noticeId: noticeId)
        }
        .onAppear {
            Task {
                await viewModel.loadNotices()
                await appState.refreshUnreadNoticeCount()
            }
        }
    }
}

struct NoticeDetailCard: View {
    let notice: Notice
    var isDark: Bool = true
    var isUnread: Bool = false

    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: notice.type == .notice ? "bell.fill" : "newspaper.fill")
                        .foregroundColor(notice.type == .notice ? .orange : AppColors.accentBlue)
                    Text(notice.type == .notice ? "Aviso" : "Notícia")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(notice.type == .notice ? .orange : AppColors.accentBlue)
                    if isUnread {
                        Text("Novo")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppColors.accentBlue)
                            .clipShape(Capsule())
                    }
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
            Text(notice.description.plainTextFromHTML())
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
