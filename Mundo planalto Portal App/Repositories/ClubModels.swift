//
//  ClubModels.swift
//  Mundo Planalto
//
//  Modelos da revisão de 01/10 (docs/revisao-ceo-01-10.md, seção 3): certificados por
//  cliente, campanhas, solicitações de alteração de dados e próxima viagem.
//  Nomes de campo iguais ao contrato para o decode do `Remote` ser direto.
//

import Foundation

// MARK: - Certificados (GET members/me/certificates)

enum CertificateKind: String, Codable {
    case rci, maisviagens, gift

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        self = CertificateKind(rawValue: raw) ?? .gift
    }

    /// Texto do HrTag: RCI / MAIS VIAGENS / BRINDE.
    var tag: String {
        switch self {
        case .rci: return "RCI"
        case .maisviagens: return "Mais Viagens"
        case .gift: return "Brinde"
        }
    }
}

enum CertificateState: String, Codable {
    case available, requested, released, used, expired

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        self = CertificateState(rawValue: raw) ?? .available
    }
}

struct Certificate: Codable, Identifiable, Equatable {
    let id: Int
    /// Nome exatamente como a Central de Contratos cadastrou.
    let name: String
    let type: CertificateKind
    let quantity: Int
    var status: CertificateState
    /// yyyy-MM-dd
    let expiresAt: String?
    var protocolNumber: String?
    let code: String?
    let useUrl: String?
    var requestedAt: String?
    let releasedAt: String?
    let usedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, type, quantity, status, expiresAt, code, useUrl, requestedAt, releasedAt, usedAt
        case protocolNumber = "protocol"
    }

    /// "1 certificado" / "2 certificados"
    var quantidadeTexto: String { quantity == 1 ? "1 certificado" : "\(quantity) certificados" }

    /// Faltam menos de 60 dias para expirar.
    var expiraEmBreve: Bool {
        guard let date = HrFormat.parseDate(expiresAt) else { return false }
        return date.timeIntervalSinceNow < 60 * 24 * 3600
    }

    /// Conta para o hero da Início ("2 certificados disponíveis").
    var contaComoDisponivel: Bool { status == .available || status == .released }
}

/// Resposta de POST certificates/{id}/request.
struct CertificateRequestResult: Codable, Equatable {
    let protocolNumber: String
    let slaHours: Int

    enum CodingKeys: String, CodingKey {
        case slaHours
        case protocolNumber = "protocol"
    }

    /// "em até 2 dias úteis" para 48 h.
    var prazoTexto: String {
        let dias = max(1, Int((Double(slaHours) / 24.0).rounded()))
        return dias == 1 ? "em até 1 dia útil" : "em até \(dias) dias úteis"
    }
}

// MARK: - Campanhas (GET campaigns)

enum CampaignCtaType: String, Codable {
    case online, postsales, whatsapp, link, certificate

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        self = CampaignCtaType(rawValue: raw) ?? .online
    }
}

struct Campaign: Codable, Identifiable, Equatable {
    let id: Int
    /// Categoria livre vinda do backend (Upgrade, Antecipação, Quitação, Indicação, Brinde, Viagem, Promoção...).
    let category: String
    let title: String
    let subtitle: String
    let imageUrl: String?
    /// yyyy-MM-dd
    let validUntil: String?
    let ctaLabel: String
    let ctaType: CampaignCtaType
    let ctaUrl: String?
    let whatsappNumber: String?
    let whatsappMessage: String?
    let ventureIds: [Int]?
    /// Card grande com foto (docs/telas.md: "destaque com foto grande se featured").
    let isFeatured: Bool?

    /// "Até 31 de outubro"
    var validadeTexto: String? { HrFormat.untilDayMonth(validUntil) }

    /// https://wa.me/{numero}?text={mensagem}
    var whatsappURL: URL? {
        guard let number = whatsappNumber?.filter(\.isNumber), !number.isEmpty else { return nil }
        var comps = URLComponents(string: "https://wa.me/\(number)")
        if let msg = whatsappMessage, !msg.isEmpty {
            comps?.queryItems = [URLQueryItem(name: "text", value: msg)]
        }
        return comps?.url
    }
}

// MARK: - Alteração de dados (POST/GET customers/change-requests)

enum ChangeRequestField: String, Codable, CaseIterable, Identifiable {
    case address, phone, email

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .address: return "Endereço"
        case .phone: return "Telefone"
        case .email: return "E-mail"
        }
    }
}

enum ChangeRequestStatus: String, Codable {
    case pending, approved, rejected

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        self = ChangeRequestStatus(rawValue: raw) ?? .pending
    }

    var texto: String {
        switch self {
        case .pending: return "Em análise"
        case .approved: return "Aprovada"
        case .rejected: return "Recusada"
        }
    }
}

struct ChangeRequest: Codable, Identifiable, Equatable {
    let id: Int
    let field: ChangeRequestField
    let newValue: String
    let status: ChangeRequestStatus
    /// ISO date-time ou yyyy-MM-dd
    let createdAt: String
}

struct ChangeRequestCreate: Codable {
    let field: ChangeRequestField
    let newValue: String
}

// MARK: - Próxima viagem (perfil de viagem)

enum NextTripWhen: String, Codable, CaseIterable, Identifiable {
    case within6Months = "within_6_months"
    case within1Year = "within_1_year"
    case moreThan1Year = "more_than_1_year"
    case unknown

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = NextTripWhen(rawValue: raw) ?? .unknown
    }

    var texto: String {
        switch self {
        case .within6Months: return "Em até 6 meses"
        case .within1Year: return "Em até 1 ano"
        case .moreThan1Year: return "Mais de 1 ano"
        case .unknown: return "Ainda não sei"
        }
    }
}

// MARK: - Atualização do empreendimento (vídeos da obra)

/// Lista de destinos oferecida na tela Perfil de viagem (docs/telas.md).
enum TravelDestinations {
    static let all = ["Gramado", "Orlando", "Cancún", "Lisboa", "Punta Cana", "Buenos Aires", "Paris", "Dubai"]
    static let maxSelected = 4
}
