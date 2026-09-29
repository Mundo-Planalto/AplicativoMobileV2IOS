//
//  PhotoBookView.swift
//  Mundo planalto Portal App
//
//  Book de fotos do empreendimento: YouTube, imagens e vídeos (incl. chunk).
//

import SwiftUI
import AVKit

struct PhotoBookView: View {
    let items: [PhotoBookItem]
    var isDark: Bool = true
    @Environment(\.dismiss) private var dismiss

    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }

    var body: some View {
        NavigationStack {
            ZStack {
                bg.ignoresSafeArea()
                if items.isEmpty {
                    Text("Nenhuma mídia no book.")
                        .foregroundColor(textS)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(items) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    if let yt = item.youtubeUrl, !yt.isEmpty {
                                        Link(destination: URL(string: yt) ?? URL(string: "https://youtube.com")!) {
                                            HStack {
                                                Image(systemName: "play.rectangle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.red)
                                                Text("Assistir no YouTube")
                                                    .foregroundColor(AppColors.accentBlue)
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(cardBg)
                                            .cornerRadius(12)
                                        }
                                    }
                                    if item.mediaType == "image" {
                                        RemoteImageView(urlString: item.photoUrl, useAuth: true)
                                            .frame(height: 220)
                                            .clipped()
                                            .cornerRadius(12)
                                    }
                                    if item.mediaType == "video" {
                                        VideoPlayerView(urlString: item.photoUrl)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Book de Fotos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                        .foregroundColor(AppColors.accentBlue)
                }
            }
        }
    }
}
