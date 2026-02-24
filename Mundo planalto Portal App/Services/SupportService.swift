//
//  SupportService.swift
//  Mundo planalto Portal App
//
//  POST /api/customers/external-support-request (não requer autenticação).
//

import Foundation

struct ExternalSupportRequest: Codable {
    let cpf: String
    let message: String
}

struct ExternalSupportResponse: Codable {
    let success: Bool?
    let message: String?
    let data: ExternalSupportData?
}

struct ExternalSupportData: Codable {
    let success: Bool?
    let protocolNumber: String?
    let message: String?
    enum CodingKeys: String, CodingKey {
        case success, message
        case protocolNumber = "protocol"
    }
}

enum SupportError: Error {
    case networkError
    case invalidResponse
}

class SupportService {
    static let shared = SupportService()
    private init() {}

    private var baseURL: String { ApiConfig.baseURL + "/" }

    /// POST /api/customers/external-support-request - CPF e mensagem (sem auth).
    func sendExternalSupportRequest(cpf: String, message: String) async throws -> (success: Bool, protocolNumber: String?, message: String?) {
        guard let url = URL(string: baseURL + "customers/external-support-request") else { throw SupportError.networkError }
        let body = ExternalSupportRequest(cpf: CPFMask.unformat(cpf), message: message)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupportError.invalidResponse }
        let decoded = try? JSONDecoder().decode(ExternalSupportResponse.self, from: data)
        if http.statusCode == 200, let d = decoded, d.success == true {
            return (true, d.data?.protocolNumber, d.data?.message ?? d.message)
        }
        return (false, nil, decoded?.message ?? "Não foi possível enviar a solicitação.")
    }
}
