//
//  AppNavigation.swift
//  Mundo Planalto
//
//  Abas e rotas empilhadas (docs/telas.md, seção "Navegação").
//

import Foundation

/// As 5 abas da tab bar.
enum TabItem: String, CaseIterable, Identifiable {
    case inicio = "Início"
    case beneficios = "Benefícios"
    case campanhas = "Campanhas"
    case empreendimentos = "Empreendimentos"
    case perfil = "Perfil"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .inicio: return "house.fill"
        case .beneficios: return "gift.fill"
        case .campanhas: return "megaphone.fill"
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
    case viagens
    case cartaoDigital
    case avisosNoticias
    case politicaPrivacidade
    case sistema
    case detalhesObra(Venture)
}
