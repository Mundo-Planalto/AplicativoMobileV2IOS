//
//  AppColors.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct AppColors {
    // Tema escuro
    static let backgroundPrimaryDark = Color(hex: "#0F1419")
    static let cardBackgroundDark = Color(hex: "#1E2329")
    static let textPrimaryDark = Color.white
    static let textSecondaryDark = Color.gray

    // Tema claro (como nas fotos)
    static let backgroundPrimaryLight = Color(hex: "#F2F2F7")
    static let cardBackgroundLight = Color.white
    static let textPrimaryLight = Color(hex: "#1C1C1E")
    static let textSecondaryLight = Color(hex: "#8E8E93")

    // Accent (igual nos dois temas)
    static let accentBlue = Color(hex: "#0066FF")
    static let accentCyan = Color(hex: "#00D9FF")
    static let logoutRed = Color(hex: "#FF3B30")

    // Compatibilidade: usa tema escuro por padrão (será sobrescrito onde houver EnvironmentObject appState)
    static var backgroundPrimary: Color { backgroundPrimaryDark }
    static var cardBackground: Color { cardBackgroundDark }
    static var textPrimary: Color { textPrimaryDark }
    static var textSecondary: Color { textSecondaryDark }
    static var inputBackground: Color { Color.white.opacity(0.9) }

    static func backgroundPrimary(dark: Bool) -> Color { dark ? backgroundPrimaryDark : backgroundPrimaryLight }
    static func cardBackground(dark: Bool) -> Color { dark ? cardBackgroundDark : cardBackgroundLight }
    static func textPrimary(dark: Bool) -> Color { dark ? textPrimaryDark : textPrimaryLight }
    static func textSecondary(dark: Bool) -> Color { dark ? textSecondaryDark : textSecondaryLight }
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
