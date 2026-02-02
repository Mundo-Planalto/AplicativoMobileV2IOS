//
//  AppNavigation.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

enum TabItem: String, CaseIterable {
    case home = "Dashboard"
    case ventures = "Empreendimentos"

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .ventures: return "building.2.fill"
        }
    }
}

enum QuickAction: String, Identifiable, CaseIterable {
    case viewStatement = "Ver Extrato"
    case trackWorks = "Acompanhar Obras"
    case newsAlerts = "Avisos e Notícias"
    case irReport = "Informe IR"
    case changeAddress = "Mudar Endereço"
    case requestService = "Solicitar Atendimento"
    case sendEmail = "Enviar E-mail"
    case whatsappCall = "Chamar no WhatsApp"
    case profile = "Perfil"
    case chatAI = "Atendimento IA"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .viewStatement: return "doc.text.fill"
        case .trackWorks: return "wrench.and.screwdriver.fill"
        case .newsAlerts: return "bell.badge.fill"
        case .irReport: return "chart.pie.fill"
        case .changeAddress: return "mappin.and.ellipse"
        case .requestService: return "headphones"
        case .sendEmail: return "envelope.fill"
        case .whatsappCall: return "message.fill"
        case .profile: return "person.fill"
        case .chatAI: return "message.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .viewStatement: return "#0066FF" // Azul
        case .trackWorks: return "#00D9FF" // Ciano
        case .newsAlerts: return "#FF6B35" // Laranja
        case .irReport: return "#4CAF50" // Verde
        case .changeAddress: return "#9C27B0" // Roxo
        case .requestService: return "#FF9800" // Laranja escuro
        case .sendEmail: return "#2196F3" // Azul claro
        case .whatsappCall: return "#25D366" // Verde WhatsApp
        case .profile: return "#607D8B" // Azul acinzentado
        case .chatAI: return "#FF5722" // Laranja avermelhado
        }
    }
}