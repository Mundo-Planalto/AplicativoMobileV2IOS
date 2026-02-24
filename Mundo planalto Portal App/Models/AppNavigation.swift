//
//  AppNavigation.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

enum TabItem: String, CaseIterable {
    case home = "Início"
    case ventures = "Empreendimentos"
    case news = "Notícias"
    case profile = "Perfil"

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .ventures: return "building.2.fill"
        case .news: return "bell.fill"
        case .profile: return "person.fill"
        }
    }
}

/// Ações rápidas do Dashboard, na ordem do anexo: 4 linhas x 2 colunas.
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