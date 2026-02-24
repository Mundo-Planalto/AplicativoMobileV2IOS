//
//  LoginRequest.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

struct LoginRequest: Codable {
    let document: String
    let password: String
}

struct UserDto: Codable {
    let id: Int
    let name: String?
    let email: String?
    let document: String
    let documentType: String?
    let siengeCustomerId: Int?
    let esolutionCustomerId: Int?
    let lastLoginAt: String?
}

struct LoginResponse: Codable {
    let token: String?
    let message: String?
    let success: Bool
    let user: UserDto?
}

struct RegisterRequest: Codable {
    let document: String
    let password: String
    let confirmPassword: String
}

struct RegisterResponse: Codable {
    let token: String?
    let message: String?
    let success: Bool
    let user: UserDto?
}

struct LogoutResponse: Codable {
    let message: String?
    let success: Bool
}

/// Resposta padrão da API (success, message?, data?)
struct ApiResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
}
