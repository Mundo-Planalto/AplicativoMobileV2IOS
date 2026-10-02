//
//  HrTheme.swift
//  Mundo Planalto
//
//  Design system: cores (paleta de docs/marca.md), gradientes, tipografia e espaçamentos.
//  Tema único, sempre escuro (preto e dourado).
//

import SwiftUI
import UIKit

// MARK: - Cores

extension Color {
    /// Fundo de todas as telas e da tab bar.
    static let hrBlack = Color(hex: "#0A0A0A")
    /// Cards.
    static let hrSurface = Color(hex: "#161616")
    /// Cards em destaque, campos de texto, chips não selecionados.
    static let hrSurfaceElevated = Color(hex: "#1F1F1F")
    /// Ações principais, ícones ativos, bordas fortes.
    static let hrGold = Color(hex: "#9E8033")
    /// Destaques, links, texto sobre dourado escuro.
    static let hrGoldLight = Color(hex: "#C9A84C")
    /// Fim do gradiente dourado, sombras.
    static let hrGoldDark = Color(hex: "#6E5A22")
    /// Borda padrão dos cards.
    static let hrGoldBorder = Color(hex: "#9E8033").opacity(0.4)
    /// Só para a variante clara do ícone e materiais impressos; não usar em telas.
    static let hrCream = Color(hex: "#F2F1EA")
    /// Texto secundário.
    static let hrTextMuted = Color(hex: "#A6A6A6")
    /// "Em dia", "Disponível", "Ativo".
    static let hrSuccess = Color(hex: "#7CCB6A")
    /// "Solicitado", "A vencer".
    static let hrWarning = Color(hex: "#E0A72E")
    /// Vencido, erro, "Sair".
    static let hrError = Color(hex: "#E05252")
    /// Texto principal.
    static let hrTextPrimary = Color.white
}

// MARK: - Gradientes

enum HrGradient {
    /// Horizontal hrGoldLight → hrGold → hrGoldDark. Só na linha do splash e no brilho do cartão;
    /// botões não usam gradiente (docs/marca.md).
    static let gold = LinearGradient(
        colors: [.hrGoldLight, .hrGold, .hrGoldDark],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Vertical hrSurfaceElevated → hrSurface (card em destaque).
    static let card = LinearGradient(
        colors: [.hrSurfaceElevated, .hrSurface],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Por trás de toda foto remota, enquanto carrega ou se falhar.
    static let photoPlaceholder = LinearGradient(
        colors: [.hrSurfaceElevated, .hrGoldDark, .hrBlack],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Por cima da metade inferior das fotos, para o texto ficar legível.
    static let photoOverlay = LinearGradient(
        stops: [
            .init(color: .clear, location: 0.0),
            .init(color: .clear, location: 0.45),
            .init(color: .black.opacity(0.85), location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Card Unity: escuro → dourado.
    static let unity = LinearGradient(
        colors: [.hrSurfaceElevated, .hrGoldDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Tipografia (SF Pro, sistema)

enum HrFont {
    /// Título de tela (ex.: "Seus benefícios").
    static let screenTitle = Font.system(size: 30, weight: .bold)
    /// Título de tela empilhada (HrBackHeader).
    static let backTitle = Font.system(size: 22, weight: .bold)
    /// Título de card hero ("Gramado te espera").
    static let heroTitle = Font.system(size: 24, weight: .bold)
    /// Título de seção.
    static let sectionTitle = Font.system(size: 16, weight: .bold)
    /// Título de item de lista.
    static let itemTitle = Font.system(size: 14, weight: .semibold)
    /// Corpo.
    static let body = Font.system(size: 14, weight: .regular)
    /// Subtítulo / legenda.
    static let caption = Font.system(size: 12, weight: .regular)
    static let captionSmall = Font.system(size: 11, weight: .regular)
    /// Tag: 9 bold, uppercase, letter spacing 1.
    static let tag = Font.system(size: 9, weight: .bold)
    /// Valor monetário em destaque.
    static let money = Font.system(size: 34, weight: .bold)
    /// Botão principal.
    static let buttonPrimary = Font.system(size: 14, weight: .bold)
    /// Botão secundário.
    static let buttonSecondary = Font.system(size: 13, weight: .semibold)
}

// MARK: - Formas e espaçamento

enum HrMetrics {
    static let screenMargin: CGFloat = 20
    static let cardSpacing: CGFloat = 12
    static let cardRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let buttonRadius: CGFloat = 12
    static let primaryButtonHeight: CGFloat = 46
    static let secondaryButtonHeight: CGFloat = 42
    static let chipRadius: CGFloat = 20
    static let iconBoxSize: CGFloat = 38
    static let iconBoxRadius: CGFloat = 10
    /// Espaço final da rolagem (sem contar a safe area da tab bar).
    static let scrollBottomInset: CGFloat = 24
}

// MARK: - Helpers

enum HrNames {
    /// Primeiro nome exibido nos headers: primeira palavra do nome, capitalizada ("ROBSON SILVA" → "Robson").
    static func firstName(from fullName: String?) -> String {
        let trimmed = (fullName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.split(separator: " ").first, !first.isEmpty else { return "" }
        return first.lowercased(with: Locale(identifier: "pt_BR")).capitalized(with: Locale(identifier: "pt_BR"))
    }
}

/// Fundo padrão de tela: hrBlack cobrindo a safe area.
struct HrScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.hrBlack.ignoresSafeArea()
            content
        }
    }
}

extension View {
    func hrScreen() -> some View { modifier(HrScreenBackground()) }
}

// MARK: - Aparência UIKit (tab bar, navigation bar, alerts)

enum HrAppearance {
    /// Aplica o tema preto e dourado nos componentes UIKit usados pelo SwiftUI.
    static func apply() {
        let black = UIColor(Color.hrBlack)
        let gold = UIColor(Color.hrGold)
        let muted = UIColor(Color.hrTextMuted)

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = black
        tab.shadowColor = UIColor(Color.hrGoldBorder)
        for item in [tab.stackedLayoutAppearance, tab.inlineLayoutAppearance, tab.compactInlineLayoutAppearance] {
            item.selected.iconColor = gold
            item.selected.titleTextAttributes = [.foregroundColor: gold, .font: UIFont.systemFont(ofSize: 9, weight: .semibold)]
            item.normal.iconColor = muted
            item.normal.titleTextAttributes = [.foregroundColor: muted, .font: UIFont.systemFont(ofSize: 9, weight: .regular)]
        }
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().tintColor = gold
        UITabBar.appearance().unselectedItemTintColor = muted

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = black
        nav.shadowColor = .clear
        nav.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = gold

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = gold
        UISwitch.appearance().onTintColor = gold
        UIRefreshControl.appearance().tintColor = gold
        UIPageControl.appearance().currentPageIndicatorTintColor = gold
        UIPageControl.appearance().pageIndicatorTintColor = muted
    }
}
