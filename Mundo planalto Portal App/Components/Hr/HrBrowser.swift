//
//  HrBrowser.swift
//  Mundo Planalto
//
//  Navegador interno: toda URL externa abre dentro do app (SFSafariViewController em sheet,
//  com o botão de fechar do sistema). Exceções: wa.me, Instagram e YouTube podem abrir o
//  app nativo quando instalado.
//

import SwiftUI
import SafariServices

/// Destino do navegador interno (usado como item de sheet).
struct HrBrowserDestination: Identifiable, Equatable {
    let id = UUID()
    let url: URL
}

struct HrSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(Color.hrBlack)
        vc.preferredControlTintColor = UIColor(Color.hrGoldLight)
        vc.dismissButtonStyle = .close
        return vc
    }

    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}

enum HrLinks {
    /// Hosts que podem abrir o app nativo (WhatsApp, Instagram, YouTube).
    private static let nativeHosts = ["wa.me", "api.whatsapp.com", "whatsapp.com", "instagram.com", "youtube.com", "youtu.be"]

    static func prefersNativeApp(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        return nativeHosts.contains { host == $0 || host.hasSuffix("." + $0) }
    }

    /// SFSafariViewController só aceita http/https.
    static func isWebURL(_ url: URL) -> Bool {
        let scheme = url.scheme?.lowercased()
        return scheme == "http" || scheme == "https"
    }

    static func url(from string: String?) -> URL? {
        guard let s = string?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty, s != "#" else { return nil }
        return URL(string: s)
    }
}

extension View {
    /// Apresenta o navegador interno quando `destination` é definido.
    func hrBrowser(_ destination: Binding<HrBrowserDestination?>) -> some View {
        sheet(item: destination) { dest in
            HrSafariView(url: dest.url)
                .ignoresSafeArea()
        }
    }
}
