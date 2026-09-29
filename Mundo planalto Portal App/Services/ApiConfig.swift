//
//  ApiConfig.swift
//  Mundo planalto Portal App
//
//  Centraliza a URL base da API.
//  O valor vem de API_BASE_URL no Info.plist, preenchido pelos xcconfigs:
//  Development.xcconfig (Debug → homologação) e Production.xcconfig (Release → produção).
//

import Foundation

enum ApiConfig {
    /// Chave exposta no Info.plist como $(API_BASE_URL).
    private static let infoPlistKey = "API_BASE_URL"

    /// Usado apenas se o build não trouxer API_BASE_URL (xcconfig não aplicado).
    private static let fallbackBaseURL = "https://portal.mundoplanalto.com.br/api"

    /// URL base da API (sem barra final). Ex.: "https://portal.mundoplanalto.com.br/api"
    static var baseURL: String {
        let configured = (Bundle.main.object(forInfoDictionaryKey: infoPlistKey) as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var value = configured
        if value.isEmpty || !value.lowercased().hasPrefix("http") {
            #if DEBUG
            print("[ApiConfig] ⚠️ API_BASE_URL ausente ou inválida no Info.plist (\"\(configured)\"). Usando fallback: \(fallbackBaseURL)")
            #endif
            value = fallbackBaseURL
        }
        while value.hasSuffix("/") { value.removeLast() }
        return value
    }

    /// Constrói um path completo garantindo apenas uma barra entre base e caminho.
    static func fullPath(_ path: String) -> String {
        let p = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return "\(baseURL)/\(p)"
    }
}
