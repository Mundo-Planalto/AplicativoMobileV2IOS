//
//  AppConfig.swift
//  Mundo Planalto
//
//  Chaves de comportamento do app: modo mock da API nova e usuário de demonstração.
//

import Foundation

enum AppConfig {
    /// A API nova (docs/openapi-hardrock.yaml) ainda está em implementação.
    /// Enquanto `true`, os repositórios usam a implementação `Mock`.
    static let useMockData = true

    /// "Acessar demonstração" no Login: só em builds internos (debug); oculto no release de loja.
    #if DEBUG
    static let showDemoLogin = true
    #else
    static let showDemoLogin = false
    #endif

    /// Mensagem exibida no Login quando a API confirma que o token não vale mais.
    static let sessionExpiredMessage = "Sua sessão expirou, entre novamente"

    /// Token gravado no Keychain quando o usuário entra por "Acessar demonstração".
    static let demoToken = "DEMO-HRVC"

    /// URL pública de "esqueci minha senha" (docs/telas.md).
    static let forgotPasswordURL = "https://portal.mundoplanalto.com.br/Account/ForgotPassword"

    /// Programa Unity (docs/telas.md).
    static let unityURL = "https://www.hardrock.com/unity"
}

/// Dados do membro exibidos no cartão e nos headers.
struct MemberInfo: Equatable {
    let nome: String
    let numeroMembro: String
    let nivel: String
    let desde: String
    /// Sem API real ainda: `verifyUrl` de GET members/me/card.
    let verifyUrl: String

    /// Usuário fictício "Acessar demonstração" (idêntico ao Android).
    static let demo = MemberInfo(
        nome: "José R. Castro",
        numeroMembro: "8150",
        nivel: "Founder",
        desde: "2026",
        verifyUrl: "https://portal.mundoplanalto.com.br/card/HRVC-8150-DEMO"
    )
}
