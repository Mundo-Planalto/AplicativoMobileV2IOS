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
    @Environment(\.dismiss) private var dismiss

    private var bg: Color { Color.hrBlack }
    private var textP: Color { Color.white }
    private var textS: Color { Color.hrTextMuted }
    private var cardBg: Color { Color.hrSurface }

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
                                        Color.clear
                                            .overlay(RemoteImageView(urlString: item.photoUrl, useAuth: true))
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
            .navigationTitle("Galeria de fotos")
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
