//
//  HardRockModels.swift
//  Hard Rock Hotel & Vacation Club
//
//  Modelos da API nova (docs/openapi-hardrock.yaml) e dos dados de demonstração.
//  Nomes de campo iguais ao contrato para o decode do `Remote` ser direto.
//

import Foundation

// MARK: - Membro / cartão

enum MemberLevel: String, Codable, CaseIterable {
    case founder = "Founder"
    case legacy = "Legacy"
    case discovery = "Discovery"

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = MemberLevel.allCases.first { $0.rawValue.lowercased() == raw.lowercased() } ?? .discovery
    }
}

enum MemberStatus: String, Codable {
    case active, inactive

    var texto: String { self == .active ? "Ativo" : "Inativo" }
}

struct MemberCard: Codable, Equatable {
    let name: String
    let level: MemberLevel
    let memberNumber: String
    /// Data ISO (yyyy-MM-dd) ou só o ano.
    let memberSince: String
    let status: MemberStatus
    let cardToken: String
    let verifyUrl: String
    let benefitUsageCount: Int

    /// "2026" a partir de memberSince.
    var anoDesde: String { String(memberSince.prefix(4)) }
}

struct BenefitRedemption: Codable, Identifiable, Equatable {
    let id: Int
    let partnerId: Int
    let partnerName: String
    let discountText: String
    /// ISO date-time.
    let usedAt: String
    let source: String
}

// MARK: - Parceiros e cupons

enum PartnerCategory: String, Codable, CaseIterable {
    case gastronomia, hospedagem, experiencias, compras, outros

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        self = PartnerCategory(rawValue: raw) ?? .outros
    }
}

struct Partner: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let category: PartnerCategory
    let city: String
    let state: String
    let discountPercent: Int
    let discountText: String
    let terms: String?
    let validationType: String
    let logoUrl: String?
    let imageUrl: String?
    let address: String?
    let usageLimitPerCustomer: Int?
    let validUntil: String?
    let isActive: Bool
}

struct Coupon: Codable, Equatable {
    let partnerId: Int
    let partnerName: String
    let code: String
    let discountText: String
    let validUntil: String?
    let remainingUses: Int?
    let instructions: String
}

// MARK: - Certificados

enum CertificateType: String, Codable, CaseIterable {
    case nacional, internacional

    var tag: String { rawValue.uppercased() }
}

enum CertificateStatus: String, Codable {
    case requested, inProgress = "in_progress", issued, cancelled

    var texto: String {
        switch self {
        case .requested: return "Solicitado"
        case .inProgress: return "Em andamento"
        case .issued: return "Emitido"
        case .cancelled: return "Cancelado"
        }
    }
}

struct CertificateRequest: Codable, Identifiable, Equatable {
    let id: Int
    let type: CertificateType
    let status: CertificateStatus
    let protocolNumber: String
    let certificateCode: String?
    let requestedAt: String

    enum CodingKeys: String, CodingKey {
        case id, type, status, certificateCode, requestedAt
        case protocolNumber = "protocol"
    }
}

struct CertificateRequestCreate: Codable {
    let type: CertificateType
    let preferredDestination: String?
    let preferredPeriod: String?
    let notes: String?
}

/// Opção de certificado exibida na tela (texto fixo em docs/telas.md).
struct CertificateOption: Identifiable, Equatable {
    var id: CertificateType { type }
    let type: CertificateType
    let titulo: String
    let descricao: String
    let imageUrl: String
}

// MARK: - Ofertas

enum OfferCategory: String, Codable, CaseIterable {
    case hospedagem, gastronomia, experiencias, milhas, outros

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        self = OfferCategory(rawValue: raw) ?? .outros
    }

    var tag: String { rawValue.uppercased() }

    var chip: String {
        switch self {
        case .hospedagem: return "Hospedagem"
        case .gastronomia: return "Gastronomia"
        case .experiencias: return "Experiências"
        case .milhas: return "Milhas"
        case .outros: return "Outras"
        }
    }
}

struct Offer: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let subtitle: String
    let description: String?
    let category: OfferCategory
    let imageUrl: String?
    let isFeatured: Bool
    let ctaLabel: String
    let ctaUrl: String?
    let partnerId: Int?
    let validFrom: String?
    let validUntil: String?
}

// MARK: - Milhas

struct MilesEntry: Codable, Identifiable, Equatable {
    let id: Int
    let amount: Int
    let description: String
    /// ISO date-time ou dd/MM/yyyy (mock).
    let createdAt: String
}

struct MilesAccount: Codable, Equatable {
    let balance: Int
    let entries: [MilesEntry]
}

struct MilesOffer: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let summary: String
    let destination: String?
    let program: String?
    let url: String?
    let capturedAt: String
    let expiresAt: String?
}

// MARK: - Perfil de viagem e preferências

struct TravelProfile: Codable, Equatable {
    var homeCity: String
    var homeState: String
    var preferredDestinations: [String]
}

struct NotificationPreferences: Codable, Equatable {
    var milesOffers: Bool
    var announcements: Bool
}

// MARK: - Collection

enum CollectionItemStatus: String, Codable {
    case locked, unlocked, sent

    var legenda: String {
        switch self {
        case .locked: return "Bloqueada"
        case .unlocked: return "Liberada"
        case .sent: return "Enviada"
        }
    }
}

struct CollectionItem: Codable, Identifiable, Equatable {
    var id: Int { index }
    let index: Int
    let status: CollectionItemStatus
}

struct CollectionStatus: Codable, Equatable {
    let contractNumber: String?
    let eligible: Bool
    let items: [CollectionItem]

    var desbloqueadas: Int { items.filter { $0.status != .locked }.count }
}

// MARK: - Financeiro (tela Financeiro / card da Início)

struct ParcelaResumo: Identifiable, Equatable {
    let id: String
    /// "15 OUT 2026"
    let vencimento: String
    /// "R$ 2.480,00"
    let valor: String
    let status: ParcelaStatus
}

enum ParcelaStatus: Equatable {
    case aVencer, vencida, paga

    var texto: String {
        switch self {
        case .aVencer: return "A vencer"
        case .vencida: return "Vencida"
        case .paga: return "Paga"
        }
    }
}

struct FinanceiroResumo: Equatable {
    let empreendimentoNome: String
    let empreendimentoLocal: String
    let empreendimentoImagem: String?
    let situacao: String
    let situacaoEmDia: Bool
    let proximoVencimento: String
    let proximoValor: String
    let saldoContrato: String
    let parcelasPagas: String
    let parcelasRestantes: String
    let proximasParcelas: [ParcelaResumo]
}

// MARK: - Empreendimento (card da Início)

struct MeuEmpreendimentoResumo: Equatable {
    let nome: String
    let unidade: String
    let imageUrl: String?
}

// MARK: - Datas / moeda

enum HrFormat {
    private static let ptBR = Locale(identifier: "pt_BR")

    static func currency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = ptBR
        return f.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    static func integer(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = ptBR
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// "15 OUT 2026" a partir de dd/MM/yyyy, yyyy-MM-dd ou ISO 8601.
    static func shortDate(_ raw: String?) -> String {
        guard let date = parseDate(raw) else { return raw ?? "-" }
        let f = DateFormatter()
        f.locale = ptBR
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: date).replacingOccurrences(of: ".", with: "").uppercased()
    }

    /// "20/09/2026"
    static func dayMonthYear(_ raw: String?) -> String {
        guard let date = parseDate(raw) else { return raw ?? "-" }
        let f = DateFormatter()
        f.locale = ptBR
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: date)
    }

    static func parseDate(_ raw: String?) -> Date? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: raw) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: raw) { return d }
        for pattern in ["yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd", "dd/MM/yyyy"] {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = pattern
            if let d = f.date(from: String(raw.prefix(pattern.count))) { return d }
        }
        return nil
    }
}
