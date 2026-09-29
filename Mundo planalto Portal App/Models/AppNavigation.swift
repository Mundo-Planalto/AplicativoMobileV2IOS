//
//  AppNavigation.swift
//  Hard Rock Hotel & Vacation Club
//
//  Abas e rotas empilhadas (docs/telas.md, seção "Navegação").
//

import Foundation

/// As 5 abas da tab bar.
enum TabItem: String, CaseIterable, Identifiable {
    case inicio = "Início"
    case beneficios = "Benefícios"
    case ofertas = "Ofertas"
    case empreendimentos = "Empreendimentos"
    case perfil = "Perfil"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .inicio: return "house.fill"
        case .beneficios: return "gift.fill"
        case .ofertas: return "tag.fill"
        case .empreendimentos: return "building.2.fill"
        case .perfil: return "person.fill"
        }
    }
}

/// Telas empilhadas (push) sobre uma aba.
enum AppRoute: Hashable {
    case financeiro
    case extrato
    case informeRendimentos
    case certificados
    case unityMilhas
    case cartaoDigital
    case avisosNoticias
    case politicaPrivacidade
    case sistema
    case detalhesObra(Venture)
}
