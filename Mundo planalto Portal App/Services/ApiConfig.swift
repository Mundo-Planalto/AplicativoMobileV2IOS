//
//  ApiConfig.swift
//  Mundo planalto Portal App
//
//  Centraliza a URL base da API.
//

import Foundation

enum ApiConfig {
    /// URL base da API (sem barra final).
    /// Produção: portal Mundo Planalto.
    static var baseURL: String {
        //"https://portal.mundoplanalto.com.br/api"
        "localhost:"
    }

    /// Constrói um path completo garantindo apenas uma barra entre base e caminho.
    static func fullPath(_ path: String) -> String {
        let p = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return "\(baseURL)/\(p)"
    }
}

