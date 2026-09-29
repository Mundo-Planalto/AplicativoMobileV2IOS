//
//  ProfileService.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

enum ProfileError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

struct UserProfile: Codable {
    let id: String
    let name: String
    let cpf: String
    let email: String?
    let phone: String?
    let address: String?
    /// Linhas separadas para exibição no perfil (quando vêm de `customers/data`).
    let addressLine1: String?
    let addressLine2: String?
    let addressZipLine: String?
    let registrationDate: String
    let status: String

    init(
        id: String,
        name: String,
        cpf: String,
        email: String?,
        phone: String?,
        address: String?,
        addressLine1: String? = nil,
        addressLine2: String? = nil,
        addressZipLine: String? = nil,
        registrationDate: String,
        status: String
    ) {
        self.id = id
        self.name = name
        self.cpf = cpf
        self.email = email
        self.phone = phone
        self.address = address
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressZipLine = addressZipLine
        self.registrationDate = registrationDate
        self.status = status
    }
}

// MARK: - GET /api/customers/data

private struct CustomerPhoneDto: Codable {
    let type: String?
    let number: String?
    let isMain: Bool?
}

private struct CustomerAddressDto: Codable {
    let type: String?
    let streetName: String?
    let number: String?
    let complement: String?
    let neighborhood: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let mail: Bool?
}

private struct CustomerDataDto: Codable {
    let customerDocument: String?
    let customerName: String?
    let customerEmail: String?
    let phones: [CustomerPhoneDto]?
    let addresses: [CustomerAddressDto]?
}

struct UpdateProfileRequest: Codable {
    let name: String?
    let email: String?
    let phone: String?
    let address: String?
}

struct ProfileResponse: Codable {
    let profile: UserProfile
    let success: Bool
    let message: String?
}

struct UpdateProfileResponse: Codable {
    let success: Bool
    let message: String?
}

class ProfileService {
    static let shared = ProfileService()

    private var baseURL: String { ApiConfig.baseURL + "/" }

    private init() {}

    private func createAuthorizedRequest(url: URL, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization header if token exists
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    /// GET /api/auth/me - retorna perfil do usuário atual
    func getProfile() async throws -> ProfileResponse {
        guard let url = URL(string: baseURL + "auth/me") else { throw ProfileError.networkError }
        var request = createAuthorizedRequest(url: url)
        var (data, response) = try await URLSession.shared.data(for: request)
        guard var http = response as? HTTPURLResponse else { throw ProfileError.invalidResponse }
        if http.statusCode == 401 {
            let recovered = await AuthService.shared.recoverSessionIfNeeded()
            guard recovered else { throw ProfileError.invalidCredentials }
            request = createAuthorizedRequest(url: url)
            let retry = try await URLSession.shared.data(for: request)
            data = retry.0
            response = retry.1
            guard let retryHttp = response as? HTTPURLResponse else { throw ProfileError.invalidResponse }
            http = retryHttp
        }
        if http.statusCode == 401 { throw ProfileError.invalidCredentials }
        guard http.statusCode == 200 else { throw ProfileError.invalidResponse }
        let decoded = try JSONDecoder().decode(ApiResponse<UserDto>.self, from: data)
        guard let user = decoded.data else { throw ProfileError.invalidResponse }

        let customer = await fetchCustomerData()

        let name = Self.nonEmpty(customer?.customerName) ?? user.name ?? ""
        let document = Self.nonEmpty(customer?.customerDocument) ?? user.document
        let email = Self.nonEmpty(customer?.customerEmail) ?? user.email

        let phone = Self.mainPhone(from: customer)

        let addrLines = Self.formattedAddress(from: customer)
        let singleAddress: String? = {
            guard let lines = addrLines else { return nil }
            return [lines.line1, lines.line2, lines.zipLine].filter { !$0.isEmpty }.joined(separator: "\n")
        }()

        let profile = UserProfile(
            id: "\(user.id)",
            name: name,
            cpf: document,
            email: email,
            phone: phone,
            address: singleAddress,
            addressLine1: addrLines?.line1,
            addressLine2: addrLines?.line2,
            addressZipLine: addrLines?.zipLine,
            registrationDate: "",
            status: "Ativo"
        )
        return ProfileResponse(profile: profile, success: true, message: nil)
    }

    /// GET /api/customers/data — telefone principal (`isMain`) e endereços.
    private func fetchCustomerData() async -> CustomerDataDto? {
        guard let url = URL(string: baseURL + "customers/data") else { return nil }
        var request = createAuthorizedRequest(url: url)
        var dataResponse = try? await URLSession.shared.data(for: request)
        if let http = dataResponse?.1 as? HTTPURLResponse, http.statusCode == 401 {
            let recovered = await AuthService.shared.recoverSessionIfNeeded()
            guard recovered else { return nil }
            request = createAuthorizedRequest(url: url)
            dataResponse = try? await URLSession.shared.data(for: request)
        }
        guard let (data, response) = dataResponse,
              let http = response as? HTTPURLResponse,
              http.statusCode == 200 else { return nil }
        let decoder = JSONDecoder()
        guard let wrapped = try? decoder.decode(ApiResponse<CustomerDataDto>.self, from: data) else { return nil }
        return wrapped.data
    }

    private static func nonEmpty(_ s: String?) -> String? {
        guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return t
    }

    private static func mainPhone(from data: CustomerDataDto?) -> String? {
        guard let phones = data?.phones, !phones.isEmpty else { return nil }
        let chosen = phones.first(where: { $0.isMain == true }) ?? phones.first
        guard let raw = chosen?.number?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        return raw
    }

    private static func formattedAddress(from data: CustomerDataDto?) -> (line1: String, line2: String, zipLine: String)? {
        guard let list = data?.addresses, !list.isEmpty else { return nil }
        let a = list.first(where: { $0.mail == true }) ?? list.first!

        let street = (a.streetName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let num = (a.number ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let comp = (a.complement ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let bairro = (a.neighborhood ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let city = (a.city ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let state = (a.state ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cep = (a.zipCode ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        var parts: [String] = []
        let streetPart: String = {
            if street.isEmpty { return "" }
            if num.isEmpty { return street }
            return "\(street), \(num)"
        }()
        if !streetPart.isEmpty { parts.append(streetPart) }
        if !comp.isEmpty { parts.append(comp) }
        let line1 = parts.joined(separator: " — ")

        var cityParts: [String] = []
        if !bairro.isEmpty { cityParts.append(bairro) }
        let cityState: String = {
            if city.isEmpty && state.isEmpty { return "" }
            if city.isEmpty { return state }
            if state.isEmpty { return city }
            return "\(city)/\(state)"
        }()
        if !cityState.isEmpty { cityParts.append(cityState) }
        let line2 = cityParts.joined(separator: " — ")

        let zipLine = cep.isEmpty ? "" : "CEP: \(cep)"

        if line1.isEmpty && line2.isEmpty && zipLine.isEmpty { return nil }
        return (line1, line2, zipLine)
    }

    func updateProfile(updates: UpdateProfileRequest) async throws -> UpdateProfileResponse {
        guard let url = URL(string: baseURL + "profile") else {
            throw ProfileError.networkError
        }

        let body = try JSONEncoder().encode(updates)
        let request = createAuthorizedRequest(url: url, method: "PUT", body: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ProfileError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                let updateResponse = try JSONDecoder().decode(UpdateProfileResponse.self, from: data)
                return updateResponse
            } else if httpResponse.statusCode == 401 {
                throw ProfileError.invalidCredentials
            } else {
                throw ProfileError.invalidResponse
            }
        } catch {
            throw ProfileError.networkError
        }
    }

    /// POST /api/auth/change-password
    func changePassword(currentPassword: String, newPassword: String, confirmPassword: String) async throws -> UpdateProfileResponse {
        guard let url = URL(string: baseURL + "auth/change-password") else { throw ProfileError.networkError }
        let requestBody = ["currentPassword": currentPassword, "newPassword": newPassword, "confirmPassword": confirmPassword]
        let body = try JSONEncoder().encode(requestBody)
        let request = createAuthorizedRequest(url: url, method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ProfileError.invalidResponse }
        if http.statusCode == 401 { throw ProfileError.invalidCredentials }
        guard http.statusCode == 200 else {
            if let api = try? JSONDecoder().decode(ApiResponse<Empty>.self, from: data), api.message != nil {
                throw ProfileError.invalidResponse
            }
            throw ProfileError.invalidResponse
        }
        return UpdateProfileResponse(success: true, message: nil)
    }
}

private struct Empty: Codable {}