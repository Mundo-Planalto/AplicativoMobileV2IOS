//
//  HardRockModels.swift
//  Mundo Planalto
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
    /// Nome do clube exibido no cartão (vem do backend; mock: "Mundo Planalto").
    let clubName: String?

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
    /// Até 2 parceiros em destaque com imagem (o Marketing troca no cadastro).
    let isFeatured: Bool?
    /// Empreendimentos a que o parceiro se aplica; a lista já vem filtrada pelo backend.
    let ventureIds: [Int]?
    /// Parceiro recém-cadastrado: o destaque mostra "PARCEIRO NOVO".
    let isNew: Bool?
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

// MARK: - Ofertas

enum OfferCategory: String, Codable, CaseIterable {
    case hospedagem, gastronomia, experiencias, outros

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

// MARK: - Perfil de viagem e preferências

struct TravelProfile: Codable, Equatable {
    var homeCity: String
    var homeState: String
    /// Até 4 destinos.
    var preferredDestinations: [String]
    var nextTripWhen: NextTripWhen?
    var nextTripDestination: String?
    /// "pep" (respostas da compra) ou "app" (editado pelo cliente).
    var source: String?

    /// "Goiânia • GO"
    var moradaTexto: String {
        [homeCity, homeState].filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.joined(separator: " • ")
    }

    /// "Em até 6 meses • Gramado"
    var proximaViagemTexto: String {
        let quando = (nextTripWhen ?? .unknown).texto
        let destino = (nextTripDestination ?? "").trimmingCharacters(in: .whitespaces)
        return destino.isEmpty ? quando : "\(quando) • \(destino)"
    }
}

/// Único opt-in do app (Perfil → Preferências), exigido por LGPD e App Store.
struct NotificationPreferences: Codable, Equatable {
    /// "Receber campanhas e novidades"
    var campaigns: Bool
    /// "Avisos do empreendimento"
    var announcements: Bool
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

    /// "Até 31 de outubro" a partir de yyyy-MM-dd.
    static func untilDayMonth(_ raw: String?) -> String? {
        guard let date = parseDate(raw) else { return nil }
        let f = DateFormatter()
        f.locale = ptBR
        f.dateFormat = "d 'de' MMMM"
        return "Até " + f.string(from: date)
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
