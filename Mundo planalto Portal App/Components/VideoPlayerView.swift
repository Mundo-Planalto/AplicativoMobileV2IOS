//
//  VideoPlayerView.swift
//  Mundo planalto Portal App
//
//  Reproduz vídeo por URL (suporta streaming em chunk).
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let urlString: String

    var body: some View {
        Group {
            if let url = URL(string: urlString), urlString.hasPrefix("http") {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 220)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 220)
                    .overlay(
                        Image(systemName: "video.slash")
                            .font(.title)
                            .foregroundColor(.gray)
                    )
            }
        }
    }
}
