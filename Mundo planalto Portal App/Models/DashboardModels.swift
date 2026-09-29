//
//  DashboardModels.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

struct FinancialSummary: Codable {
    let overdueAmount: Double
    let upcomingAmount: Double
    let overdueInstallments: Int
    let totalAmount: Double
    let nextDueDate: String?
    let nextDueValue: Double

    init(overdueAmount: Double, upcomingAmount: Double, overdueInstallments: Int, totalAmount: Double, nextDueDate: String? = nil, nextDueValue: Double = 0) {
        self.overdueAmount = overdueAmount
        self.upcomingAmount = upcomingAmount
        self.overdueInstallments = overdueInstallments
        self.totalAmount = totalAmount
        self.nextDueDate = nextDueDate
        self.nextDueValue = nextDueValue
    }
}

struct Venture: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let imageUrl: String
    let progress: Double // 0.0 to 1.0
    let lastUpdate: String
    /// Book de fotos/vídeos do empreendimento (YouTube, imagem, vídeo)
    let photoBook: [PhotoBookItem]?
    /// Unidade do cliente (ex.: "Unidade 1208 • Torre A"). A API `ventures` ainda não devolve.
    let unit: String?

    init(id: String, name: String, imageUrl: String, progress: Double, lastUpdate: String, photoBook: [PhotoBookItem]? = nil, unit: String? = nil) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.progress = progress
        self.lastUpdate = lastUpdate
        self.photoBook = photoBook
        self.unit = unit
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Venture, rhs: Venture) -> Bool {
        lhs.id == rhs.id
    }
}

/// Item do book de fotos: imagem, vídeo ou link YouTube
struct PhotoBookItem: Identifiable, Codable, Hashable {
    let id: Int
    let photoUrl: String
    let mediaType: String
    let youtubeUrl: String?
    let createdAt: String?
}

struct Notice: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let date: String
    let type: NoticeType

    // Classificação inteligente baseada em keywords
    var intelligentType: NoticeType {
        let warningKeywords = ["aviso", "atenção", "importante", "urgente", "reunião", "manutenção", "obrigatório"]
        let newsKeywords = ["notícia", "lançamento", "novo", "inauguração", "campanha", "parceria", "atualização"]

        let combinedText = (title + description).lowercased()

        if warningKeywords.contains(where: { combinedText.contains($0) }) {
            return .notice
        } else if newsKeywords.contains(where: { combinedText.contains($0) }) {
            return .news
        } else {
            return type // Fallback para tipo da API
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Notice, rhs: Notice) -> Bool {
        lhs.id == rhs.id
    }
}

enum NoticeType: String, Codable {
    case notice
    case news
}

/// Alias para desambiguar o tipo Notice em contextos onde há conflito
typealias AppNotice = Notice

struct VentureUpdate: Identifiable, Codable {
    let id: String
    let date: String
    let title: String
    let description: String
    let images: [String]
    let imageUrl: String?
    let videoUrl: String?
    /// Link direto do YouTube quando a API envia em campo separado (`youtubeUrl`).
    let youtubeUrl: String?
    let isCompleted: Bool
}

struct FinancialStatementItem: Identifiable, Codable {
    let id: String
    let ventureName: String
    let installmentNumber: String // "1/24"
    let parcela: String // Mesmo que installmentNumber para compatibilidade
    let dueDate: String
    let paymentDate: String?
    let amount: Double
    let status: PaymentStatus
    /// Número do contrato (ex: CT-5235) para exibição e link WhatsApp.
    let contractNumber: String?
    /// Para chamar API de boleto: Sienge usa billReceivableId + installmentId; Esolution usa esolutionBoletoId.
    let billReceivableId: Int?
    let installmentId: Int?
    let isEsolution: Bool?
    let esolutionBoletoId: Int?
    /// Indica se o boleto já foi gerado pelo sistema (false/nil = precisa solicitar no WhatsApp, não exibir).
    let generatedBillet: Bool?

    init(id: String, ventureName: String, installmentNumber: String, parcela: String, dueDate: String, paymentDate: String? = nil, amount: Double, status: PaymentStatus, contractNumber: String? = nil, billReceivableId: Int? = nil, installmentId: Int? = nil, isEsolution: Bool? = nil, esolutionBoletoId: Int? = nil, generatedBillet: Bool? = nil) {
        self.id = id
        self.ventureName = ventureName
        self.installmentNumber = installmentNumber
        self.parcela = parcela
        self.dueDate = dueDate
        self.paymentDate = paymentDate
        self.amount = amount
        self.status = status
        self.contractNumber = contractNumber
        self.billReceivableId = billReceivableId
        self.installmentId = installmentId
        self.isEsolution = isEsolution
        self.esolutionBoletoId = esolutionBoletoId
        self.generatedBillet = generatedBillet
    }
}

enum PaymentStatus: String, Codable {
    case paid
    case upcoming
    case overdue
}
