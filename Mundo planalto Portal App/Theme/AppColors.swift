//
//  AppColors.swift
//  Hard Rock Hotel & Vacation Club
//
//  Paleta legada usada pelas telas herdadas do portal, agora mapeada para o
//  design system preto e dourado (Theme/HrTheme.swift). Não há mais tema claro:
//  as variantes "light" devolvem as mesmas cores do tema escuro.
//

import SwiftUI

struct AppColors {
    // Tema escuro (único)
    static let backgroundPrimaryDark = Color.hrBlack
    static let cardBackgroundDark = Color.hrSurface
    static let textPrimaryDark = Color.hrTextPrimary
    static let textSecondaryDark = Color.hrTextMuted

    // Variantes "claras" mantidas só por compatibilidade: iguais ao tema escuro.
    static let backgroundPrimaryLight = Color.hrBlack
    static let cardBackgroundLight = Color.hrSurface
    static let textPrimaryLight = Color.hrTextPrimary
    static let textSecondaryLight = Color.hrTextMuted

    // Accent: azul → dourado.
    static let accentBlue = Color.hrGold
    static let accentCyan = Color.hrGoldLight
    static let logoutRed = Color.hrError

    static var backgroundPrimary: Color { backgroundPrimaryDark }
    static var cardBackground: Color { cardBackgroundDark }
    static var textPrimary: Color { textPrimaryDark }
    static var textSecondary: Color { textSecondaryDark }
    static var inputBackground: Color { Color.hrSurfaceElevated }

    static func backgroundPrimary(dark: Bool) -> Color { backgroundPrimaryDark }
    static func cardBackground(dark: Bool) -> Color { cardBackgroundDark }
    static func textPrimary(dark: Bool) -> Color { textPrimaryDark }
    static func textSecondary(dark: Bool) -> Color { textSecondaryDark }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
