//
//  ExtratoService.swift
//  Mundo planalto Portal App
//
//  GET /api/financial/extrato, informe via /api/incometax (ver IncomeTaxService).
//

import Foundation

enum ExtratoError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

/// Item do extrato retornado por GET /api/financial/extrato
struct ExtratoItemDto: Codable {
    let billReceivableId: Int
    let installmentId: Int
    let installmentNumber: String?
    let contractNumber: String?
    let enterpriseName: String
    let dueDate: String
    let originalValue: Double
    let currentBalance: Double
    let latePaymentInterest: Double?
    let isPaid: Bool
    let isOverdue: Bool
    let generatedBillet: Bool?
    let billetStatusKnown: Bool?
    let isEsolution: Bool?
    let esolutionBoletoId: Int?
}

struct ExtratoResponseDto: Codable {
    let items: [ExtratoItemDto]
    let totalOverdue: Double?
    let totalDue: Double?
    let overdueCount: Int?
    let dueCount: Int?
    let paidCount: Int?
    let totalPaid: Double?
}

struct PDFExtratoResponse: Codable {
    let pdfUrl: String
    let success: Bool
    let message: String?
}

class ExtratoService {
    static let shared = ExtratoService()
    private init() {}

    private var baseURL: String { ApiConfig.baseURL + "/" }

    private func createAuthorizedRequest(url: URL, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body { request.httpBody = body }
        return request
    }

    /// GET /api/financial/extrato?showPaid=&showOverdue=&showDue=
    func getExtrato(showPaid: Bool = true, showOverdue: Bool = true, showDue: Bool = true) async throws -> [FinancialStatementItem] {
        var components = URLComponents(string: baseURL + "financial/extrato")
        components?.queryItems = [
            URLQueryItem(name: "showPaid", value: showPaid ? "true" : "false"),
            URLQueryItem(name: "showOverdue", value: showOverdue ? "true" : "false"),
            URLQueryItem(name: "showDue", value: showDue ? "true" : "false")
        ]
        guard let url = components?.url else { throw ExtratoError.networkError }
        let request = createAuthorizedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            if (response as? HTTPURLResponse)?.statusCode == 401 { throw ExtratoError.invalidCredentials }
            throw ExtratoError.invalidResponse
        }
        let decoded = try JSONDecoder().decode(ApiResponse<ExtratoResponseDto>.self, from: data)
        guard let dto = decoded.data else { return [] }
        return dto.items.map { item in
            let status: PaymentStatus = item.isPaid ? .paid : (item.isOverdue ? .overdue : .upcoming)
            let id = item.isEsolution == true && item.esolutionBoletoId != nil
                ? "esolution-\(item.esolutionBoletoId!)"
                : "\(item.billReceivableId)-\(item.installmentId)"
            let parcela = item.installmentNumber ?? "\(item.installmentId)"
            return FinancialStatementItem(
                id: id,
                ventureName: item.enterpriseName,
                installmentNumber: parcela,
                parcela: parcela,
                dueDate: item.dueDate,
                amount: item.currentBalance > 0 ? item.currentBalance : item.originalValue,
                status: status,
                contractNumber: item.contractNumber,
                billReceivableId: item.isEsolution == true ? nil : item.billReceivableId,
                installmentId: item.isEsolution == true ? nil : item.installmentId,
                isEsolution: item.isEsolution,
                esolutionBoletoId: item.esolutionBoletoId
            )
        }
    }

    /// Resposta do endpoint de dados do boleto (usamos apenas pdfUrl).
    private struct BoletoDataDto: Codable {
        let pdfUrl: String?
    }

    /// Obtém a URL do PDF do boleto para "Ver Boleto" / "Gerar 2ª Via". Retorna nil se falhar ou não aplicável.
    func getBoletoPdfUrl(item: FinancialStatementItem) async -> URL? {
        if item.isEsolution == true, let id = item.esolutionBoletoId {
            guard let url = URL(string: baseURL + "financial/boleto-data/esolution/\(id)") else { return nil }
            let request = createAuthorizedRequest(url: url)
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
            let decoded = try? JSONDecoder().decode(ApiResponse<BoletoDataDto>.self, from: data)
            guard let pdfUrlString = decoded?.data?.pdfUrl, let pdfUrl = URL(string: pdfUrlString) else { return nil }
            return pdfUrl
        }
        guard let brId = item.billReceivableId, let instId = item.installmentId else { return nil }
        guard let url = URL(string: baseURL + "financial/boleto-data/\(brId)/\(instId)") else { return nil }
        let request = createAuthorizedRequest(url: url)
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
        let decoded = try? JSONDecoder().decode(ApiResponse<BoletoDataDto>.self, from: data)
        guard let pdfUrlString = decoded?.data?.pdfUrl, let pdfUrl = URL(string: pdfUrlString) else { return nil }
        return pdfUrl
    }
}