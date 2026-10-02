//
//  DetalhesObraView.swift
//  Mundo Planalto
//
//  Vídeos da obra: atualizações do empreendimento com player do YouTube (WKWebView),
//  título, data e descrição.
//  Sem percentual/evolução da obra (decisão da diretoria).
//

import SwiftUI

struct DetalhesObraView: View {
    let venture: Venture
    @StateObject private var viewModel: DetalhesObraViewModel

    init(venture: Venture) {
        self.venture = venture
        self._viewModel = StateObject(wrappedValue: DetalhesObraViewModel(venture: venture))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Vídeos da obra", subtitulo: venture.name)

                if viewModel.isLoading {
                    HrCard { HStack { Spacer(); ProgressView().tint(.hrGold); Spacer() } }
                } else {
                    if let error = viewModel.error {
                        HrCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(error).font(HrFont.body).foregroundColor(.white)
                                HrOutlineButton(text: "Tentar novamente") { Task { await viewModel.loadVentureDetails(forceRefresh: true) } }
                            }
                        }
                    } else if viewModel.semConteudo {
                        HrCard {
                            HStack(spacing: 12) {
                                HrIconBox(icon: "video.slash")
                                Text("Nenhuma atualização disponível no momento.")
                                    .font(HrFont.body)
                                    .foregroundColor(.hrTextMuted)
                            }
                        }
                    }
                    ForEach(viewModel.updates) { update in
                        TimelineMarcoItem(update: update)
                    }
                    // Vídeos cadastrados no book do empreendimento no portal.
                    if !viewModel.videosDoBook.isEmpty {
                        if !viewModel.updates.isEmpty {
                            HrSectionTitle(titulo: "Vídeos do empreendimento").padding(.top, 8)
                        }
                        ForEach(viewModel.videosDoBook) { video in
                            TimelineMarcoItem(update: video, tag: "Vídeo")
                        }
                    }
                }
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .refreshable { await viewModel.loadVentureDetails(forceRefresh: true) }
        .hrScreen()
        .task { await viewModel.loadVentureDetails() }
    }
}

/// Card de uma atualização: título, data, player do YouTube, imagem e descrição.
struct TimelineMarcoItem: View {
    let update: VentureUpdate
    var tag = "Atualização"

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
        let substr = String(html[r]).trimmingCharacters(in: CharacterSet(charactersIn: "\"'.,);"))
        return URL(string: substr)
    }

    var body: some View {
        HrCard {
            VStack(alignment: .leading, spacing: 12) {
                HrTag(text: tag)
                Text(update.title)
                    .font(HrFont.sectionTitle)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                if !update.date.isEmpty {
                    Text(update.date)
                        .font(HrFont.caption)
                        .foregroundColor(.hrGoldLight)
                }

                if let ytURL = resolvedYouTubeURL {
                    YouTubePlayerView(url: ytURL)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.hrGoldBorder, lineWidth: 1))
                    Link(destination: ytURL) {
                        HStack(spacing: 6) {
                            Image(systemName: "play.rectangle.fill").font(.system(size: 13, weight: .semibold))
                            Text("Assistir no YouTube").font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.hrGoldLight)
                    }
                }

                if let imageUrl = update.imageUrl, !imageUrl.isEmpty {
                    Color.clear
                        .overlay(RemoteImageView(urlString: imageUrl, useAuth: true))
                        .frame(height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                let descriptionTrimmed = update.description.plainTextFromHTML().trimmingCharacters(in: .whitespacesAndNewlines)
                if !descriptionTrimmed.isEmpty {
                    Text(descriptionTrimmed)
                        .font(HrFont.body)
                        .foregroundColor(.hrTextMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let videoUrl = update.videoUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !videoUrl.isEmpty,
                   resolvedYouTubeURL == nil {
                    if let externalURL = URL(string: videoUrl), videoUrl.lowercased().hasPrefix("http"), !isYouTubeLink(videoUrl) {
                        HrListRow(icon: "link", titulo: "Abrir link do vídeo", subtitulo: "Toque para abrir no navegador") {
                            UIApplication.shared.open(externalURL)
                        }
                    } else {
                        VideoPlayerView(urlString: videoUrl)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetalhesObraView(venture: EmpreendimentosViewModel.demoVenture)
    }
    .environmentObject(AppState.shared)
}
