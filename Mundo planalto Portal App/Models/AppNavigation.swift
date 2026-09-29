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

/// Ações rápidas da Início antiga (mantidas até a tela nova entrar).
enum DashboardQuickAction: String, Identifiable, CaseIterable {
    case viewStatement = "Ver Extrato"
    case trackWorks = "Acompanhar Obras"
    case newsAlerts = "Avisos e Notícias"
    case irReport = "Informe IR"
    case chatAI = "Atendimento IA"
    case requestService = "Solicitar Atendimento"
    case sendEmail = "Enviar E-mail"
    case whatsappCall = "Chamar no WhatsApp"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .viewStatement: return "doc.text.fill"
        case .trackWorks: return "building.2.fill"
        case .newsAlerts: return "bell.fill"
        case .irReport: return "doc.text.fill"
        case .chatAI: return "message.circle.fill"
        case .requestService: return "headphones"
        case .sendEmail: return "envelope.fill"
        case .whatsappCall: return "message.fill"
        }
    }
}
