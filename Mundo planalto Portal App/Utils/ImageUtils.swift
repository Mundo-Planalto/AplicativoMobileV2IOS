//
//  ImageUtils.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

class ImageUtils {
    static let shared = ImageUtils()

    // URL base da API - em produção seria configurável
    private let apiBaseUrl = "https://api.mundoplanalto.com.br"

    private init() {}

    /// Converte URLs relativas para absolutas
    /// - Parameter imageUrl: URL relativa ou absoluta
    /// - Returns: URL absoluta completa
    func toAbsoluteUrl(_ imageUrl: String?) -> String? {
        guard let imageUrl = imageUrl, !imageUrl.isEmpty else {
            return nil
        }

        // Se já é uma URL absoluta (começa com http/https), retorna como está
        if imageUrl.hasPrefix("http://") || imageUrl.hasPrefix("https://") {
            return imageUrl
        }

        // Se é uma URL relativa, adiciona a base
        if imageUrl.hasPrefix("/") {
            return apiBaseUrl + imageUrl
        } else {
            return apiBaseUrl + "/" + imageUrl
        }
    }

    /// Trata URLs inválidas retornando uma URL padrão
    /// - Parameter imageUrl: URL a ser validada
    /// - Returns: URL válida ou URL padrão
    func safeImageUrl(_ imageUrl: String?) -> String? {
        guard let url = toAbsoluteUrl(imageUrl) else {
            return nil
        }

        // Validação básica de URL
        guard URL(string: url) != nil else {
            return nil
        }

        return url
    }

    /// Converte array de URLs relativas para absolutas
    /// - Parameter imageUrls: Array de URLs
    /// - Returns: Array de URLs absolutas válidas
    func toAbsoluteUrls(_ imageUrls: [String]?) -> [String] {
        return imageUrls?.compactMap { safeImageUrl($0) } ?? []
    }

    /// Gera URL placeholder baseada no tipo de conteúdo
    /// - Parameter type: Tipo de placeholder
    /// - Returns: URL do placeholder
    func placeholderUrl(for type: PlaceholderType) -> String {
        switch type {
        case .userAvatar:
            return "https://via.placeholder.com/80x80/0066FF/FFFFFF?text=U"
        case .ventureImage:
            return "https://via.placeholder.com/360x200/1E2329/FFFFFF?text=MP"
        case .noticeImage:
            return "https://via.placeholder.com/120x90/0066FF/FFFFFF?text=N"
        }
    }

    enum PlaceholderType {
        case userAvatar
        case ventureImage
        case noticeImage
    }
}