//
//  AddressService.swift
//  Mundo planalto Portal App
//
//  GET/POST /api/address/change-requests
//

import Foundation

struct AddressChangeRequestDto: Codable {
    let id: Int
    let userId: Int
    let userName: String
    let userDocument: String
    let status: String
    let requestedAddress: String
    let adminNotes: String?
    let requestDate: String
    let processedDate: String?
}

struct CreateAddressChangeRequestDto: Codable {
    let street: String
    let number: String
    let complement: String?
    let neighborhood: String
    let city: String
    let state: String
    let zipCode: String
}

class AddressService {
    static let shared = AddressService()
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

    /// GET /api/address/change-requests
    func getMyChangeRequests() async throws -> [AddressChangeRequestDto] {
        guard let url = URL(string: baseURL + "address/change-requests") else { throw NSError(domain: "AddressService", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"]) }
        let request = createAuthorizedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return [] }
        let decoded = try? JSONDecoder().decode(ApiResponse<[AddressChangeRequestDto]>.self, from: data)
        return decoded?.data ?? []
    }

    /// POST /api/address/change-requests
    func createChangeRequest(street: String, number: String, complement: String?, neighborhood: String, city: String, state: String, zipCode: String) async throws -> AddressChangeRequestDto? {
        guard let url = URL(string: baseURL + "address/change-requests") else { return nil }
        let body = CreateAddressChangeRequestDto(street: street, number: number, complement: complement, neighborhood: neighborhood, city: city, state: state, zipCode: zipCode)
        let request = createAuthorizedRequest(url: url, method: "POST", body: try JSONEncoder().encode(body))
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (http.statusCode == 200 || http.statusCode == 201) else { return nil }
        let decoded = try? JSONDecoder().decode(ApiResponse<AddressChangeRequestDto>.self, from: data)
        return decoded?.data
    }
}
