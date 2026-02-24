//
//  IncomeTaxService.swift
//  Mundo planalto Portal App
//
//  GET /api/incometax/years, POST /api/incometax/generate/{year}
//

import Foundation

struct IncomeTaxYearDto: Codable {
    let year: Int
}

struct IncomeTaxPaymentDto: Codable {
    let date: String
    let description: String?
    let contractNumber: String?
    let installmentNumber: String?
    let enterpriseName: String
    let value: Double
    let paymentMethod: String?
}

struct IncomeTaxReportDto: Codable {
    let customerName: String
    let document: String
    let year: Int
    let generatedAt: String?
    let totalPaid: Double
    let payments: [IncomeTaxPaymentDto]?
}

enum IncomeTaxError: Error {
    case networkError
    case invalidResponse
    case noData
}

class IncomeTaxService {
    static let shared = IncomeTaxService()
    private init() {}

    private var baseURL: String { ApiConfig.baseURL + "/" }

    private func createAuthorizedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// GET /api/incometax/years
    func getAvailableYears() async throws -> [Int] {
        guard let url = URL(string: baseURL + "incometax/years") else { throw IncomeTaxError.networkError }
        let request = createAuthorizedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw IncomeTaxError.invalidResponse }
        let decoded = try JSONDecoder().decode(ApiResponse<[IncomeTaxYearDto]>.self, from: data)
        return (decoded.data ?? []).map { $0.year }
    }

    /// POST /api/incometax/generate/{year} -> mapeia para InformeRendimentosData
    func generateReport(year: Int) async throws -> InformeRendimentosData {
        guard let url = URL(string: baseURL + "incometax/generate/\(year)") else { throw IncomeTaxError.networkError }
        var request = createAuthorizedRequest(url: url, method: "POST")
        request.httpBody = "{}".data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        let http = response as? HTTPURLResponse
        if http?.statusCode == 404 {
            if let api = try? JSONDecoder().decode(ApiResponse<IncomeTaxReportDto>.self, from: data), let msg = api.message {
                throw IncomeTaxError.noData
            }
            throw IncomeTaxError.noData
        }
        guard http?.statusCode == 200 else { throw IncomeTaxError.invalidResponse }
        let decoded = try JSONDecoder().decode(ApiResponse<IncomeTaxReportDto>.self, from: data)
        guard let report = decoded.data else { throw IncomeTaxError.noData }
        let contribuinte = InformeContribuinte(
            nome: report.customerName,
            cpf: report.document,
            anoBase: "\(report.year)"
        )
        let resumo = InformeResumo(
            totalPagamentos: report.payments?.count ?? 0,
            valorTotalRendimentos: report.totalPaid
        )
        let pagamentos: [InformePagamento]? = report.payments?.map { p in
            let desc = p.description ?? "\(p.contractNumber ?? "")/\(p.installmentNumber ?? "")"
            return InformePagamento(
                data: p.date,
                valor: p.value,
                transacaoId: desc,
                empresa: p.enterpriseName,
                metodo: p.paymentMethod ?? "Boleto"
            )
        }
        return InformeRendimentosData(
            anoBase: "\(report.year)",
            contribuinte: contribuinte,
            resumo: resumo,
            pagamentos: pagamentos,
            pdfUrl: nil
        )
    }
}
