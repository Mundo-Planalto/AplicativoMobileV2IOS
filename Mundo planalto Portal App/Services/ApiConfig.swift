//
//  ApiConfig.swift
//  Mundo planalto Portal App
//
//  URL base da API conforme documentação.
//  Desenvolvimento: http://localhost:5198/api ou http://10.0.2.2:5198/api (emulador)
//  Produção: configurar quando disponível.
//

import Foundation

enum ApiConfig {
    /// URL base da API (sem barra final). Alterar para desenvolvimento local se necessário.
    /// Ex.: "http://localhost:5198/api" ou "https://portal.mundoplanalto.com.br/api"
    static var baseURL: String {
        "https://portal.mundoplanalto.com.br/api"
    }

    static func fullPath(_ path: String) -> String {
        let p = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return "\(baseURL)/\(p)"
    }
}
