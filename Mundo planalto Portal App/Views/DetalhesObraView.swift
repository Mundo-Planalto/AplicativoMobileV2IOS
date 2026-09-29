//
//  DetalhesObraView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct DetalhesObraView: View {
    let venture: Venture
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @StateObject private var viewModel: DetalhesObraViewModel

    private var isDark: Bool { appState.isDarkTheme }
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad || hSizeClass == .regular }
    private var contentSidePadding: CGFloat { isPad ? 0 : 12 }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    init(venture: Venture) {
        self.venture = venture
        self._viewModel = StateObject(wrappedValue: DetalhesObraViewModel(venture: venture))
    }

    var body: some View {
        ZStack {
            bg
                .ignoresSafeArea()

            VStack(spacing: 0) {
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

                        Text(venture.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(textP)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 60)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentBlue))
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            if venture.progress > 0 {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Progresso da Obra")
                                            .font(.headline)
                                            .foregroundColor(textP)
                                        Spacer()
                                        Text("\(Int(venture.progress * 100))%")
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.accentBlue)
                                    }
                                    .padding(.horizontal)

                                    ProgressView(value: venture.progress)
                                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accentBlue))
                                        .padding(.horizontal)
                                }
                                .padding(.vertical)
                            }

                            if viewModel.updates.isEmpty && !viewModel.isLoading {
                                Text("Nenhuma atualização disponível no momento.")
                                    .font(.subheadline)
                                    .foregroundColor(textS)
                                    .padding()
                            }

                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.updates) { update in
                                    TimelineMarcoItem(update: update, isDark: isDark)
                                }
                            }
                            .padding(.horizontal, max(16, contentSidePadding))
                            .padding(.vertical, 16)
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.loadVentureDetails()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadVentureDetails()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct TimelineMarcoItem: View {
    let update: VentureUpdate
    var isDark: Bool = true

    private var cardBg: Color {
        isDark ? Color(red: 0.21, green: 0.20, blue: 0.26) : Color(red: 0.93, green: 0.89, blue: 0.95)
    }
    private var videoCardBg: Color {
        isDark ? Color.white.opacity(0.08) : Color.white
    }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }
    private var accent: Color { AppColors.accentBlue }
    private var dateTint: Color { AppColors.accentCyan }

    private func isYouTubeLink(_ value: String) -> Bool {
        let lowered = value.lowercased()
        return lowered.contains("youtube.com") || lowered.contains("youtu.be")
    }

    /// `videoUrl` ou `youtubeUrl` da API, ou URL YouTube no texto do `content`.
    private var resolvedYouTubeURL: URL? {
        if let v = update.videoUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty,
           let u = URL(string: v), isYouTubeLink(v) {
            return u
        }
        if let y = update.youtubeUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !y.isEmpty,
           let u = URL(string: y), isYouTubeLink(y) {
            return u
        }
        return Self.extractFirstYouTubeURL(from: update.description)
    }

    private static func extractFirstYouTubeURL(from html: String) -> URL? {
        let pattern = #"https?://(?:www\.)?(?:youtube\.com/(?:watch\?[^\"\s<>]+|embed/[\w-]+|shorts/[\w-]+)|youtu\.be/[^\"\s<>]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let range = NSRange(html.startIndex..., in: html)
        guard let match = regex.firstMatch(in: html, options: [], range: range),
              let r = Range(match.range, in: html) else { return nil }
        let substr = String(html[r])
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"'.,);"))
        return URL(string: substr)
    }

    private static let youtubeRedTop = Color(red: 1, green: 0.2, blue: 0.18)
    private static let youtubeRedBottom = Color(red: 0.72, green: 0.05, blue: 0.07)

    @ViewBuilder
    private func youtubeCard(_ externalURL: URL) -> some View {
        Link(destination: externalURL) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Self.youtubeRedTop, Self.youtubeRedBottom],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .shadow(color: Color.red.opacity(isDark ? 0.45 : 0.35), radius: 8, x: 0, y: 3)

                    Image(systemName: "play.fill")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 1)
                        .offset(x: 2)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Assistir no YouTube")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textP)
                        .tracking(0.2)
                    Text("Abrir no app ou no navegador")
                        .font(.caption)
                        .foregroundColor(textS)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(textS.opacity(0.55))
                    .padding(10)
                    .background(
                        Circle()
                            .fill(textP.opacity(isDark ? 0.08 : 0.06))
                    )
            }
            .padding(.leading, 14)
            .padding(.trailing, 12)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(videoCardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                textP.opacity(isDark ? 0.14 : 0.08),
                                textP.opacity(isDark ? 0.06 : 0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(isDark ? 0.45 : 0.14), radius: isDark ? 14 : 12, x: 0, y: isDark ? 6 : 5)
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(YoutubeLinkButtonStyle())
    }

    private struct YoutubeLinkButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.985 : 1)
                .opacity(configuration.isPressed ? 0.92 : 1)
                .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(update.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(textP)
                .fixedSize(horizontal: false, vertical: true)

            Text(update.date)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(dateTint)

            if let ytURL = resolvedYouTubeURL {
                youtubeCard(ytURL)
            }

            if let imageUrl = update.imageUrl, !imageUrl.isEmpty {
                RemoteImageView(urlString: imageUrl, useAuth: true)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
            }

            let descriptionTrimmed = update.description.trimmingCharacters(in: .whitespacesAndNewlines)
            if !descriptionTrimmed.isEmpty {
                Text(descriptionTrimmed)
                    .font(.body)
                    .foregroundColor(textS)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let videoUrl = update.videoUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !videoUrl.isEmpty,
               resolvedYouTubeURL == nil {
                if let externalURL = URL(string: videoUrl),
                   videoUrl.lowercased().hasPrefix("http"),
                   !isYouTubeLink(videoUrl) {
                    Link(destination: externalURL) {
                        HStack(spacing: 10) {
                            Image(systemName: "link.circle.fill")
                                .font(.title2)
                                .foregroundColor(accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Abrir link do vídeo")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(textP)
                                Text("Toque para abrir no navegador")
                                    .font(.subheadline)
                                    .foregroundColor(textS)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(textS.opacity(0.75))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(videoCardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(isDark ? 0 : 0.06), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(isDark ? 0.35 : 0.12), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    VideoPlayerView(urlString: videoUrl)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBg)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(isDark ? 0.25 : 0.1), radius: 12, x: 0, y: 5)
    }
}

#Preview {
    NavigationView {
        DetalhesObraView(venture: Venture(
            id: "1",
            name: "Residencial Parque das Flores",
            imageUrl: "venture1",
            progress: 0.75,
            lastUpdate: "Atualizado há 2 dias"
        ))
        .environmentObject(AppState.shared)
    }
}