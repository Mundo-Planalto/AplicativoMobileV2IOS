//
//  YouTubePlayerView.swift
//  Hard Rock Hotel & Vacation Club
//
//  Player do YouTube em WKWebView (embed), conforme docs/CLAUDE.md.
//

import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let url: URL

    /// Converte watch?v=, youtu.be/, shorts/ e embed/ para a URL de embed.
    static func embedURL(from url: URL) -> URL? {
        let s = url.absoluteString
        var id: String?
        if let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if comps.host?.contains("youtu.be") == true {
                id = comps.path.split(separator: "/").first.map(String.init)
            } else if let v = comps.queryItems?.first(where: { $0.name == "v" })?.value {
                id = v
            } else {
                let parts = comps.path.split(separator: "/").map(String.init)
                if let i = parts.firstIndex(where: { $0 == "embed" || $0 == "shorts" }), i + 1 < parts.count {
                    id = parts[i + 1]
                }
            }
        }
        guard let videoId = id, !videoId.isEmpty else { return s.contains("/embed/") ? url : nil }
        return URL(string: "https://www.youtube.com/embed/\(videoId)?playsinline=1&rel=0&modestbranding=1")
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = UIColor(Color.hrBlack)
        web.scrollView.isScrollEnabled = false
        web.scrollView.backgroundColor = UIColor(Color.hrBlack)
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {
        let target = Self.embedURL(from: url) ?? url
        guard context.coordinator.loaded != target else { return }
        context.coordinator.loaded = target
        // O player do YouTube exige um referer válido; carregar via HTML com baseURL resolve o erro 153.
        let html = """
        <!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1">
        <style>html,body{margin:0;padding:0;background:#0A0A0A;height:100%;overflow:hidden}
        iframe{position:absolute;top:0;left:0;width:100%;height:100%;border:0}</style></head>
        <body><iframe src="\(target.absoluteString)" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture; fullscreen" allowfullscreen></iframe></body></html>
        """
        web.loadHTMLString(html, baseURL: URL(string: "https://portal.mundoplanalto.com.br"))
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var loaded: URL?
    }
}
