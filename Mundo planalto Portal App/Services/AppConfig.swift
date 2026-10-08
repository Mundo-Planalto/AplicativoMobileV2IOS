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

    /// Política de privacidade e Termos de uso: URLs públicas definidas pelo jurídico
    /// (docs/app-store-bloqueadores.md, itens 2 e 3). Vazias = tela "em breve".
    static let privacyPolicyURL = ""
    static let termsOfUseURL = ""

    /// Áreas que dependem da API nova. `false` tira a aba/atalho do app (build de loja sem
    /// conteúdo de exemplo; docs/app-store-bloqueadores.md, item 4). Decidir até 15/11.
    enum Features {
        static let viagens = true
        static let beneficios = true
        static let campanhas = true
        static let cartao = true
        static let perfilViagem = true
    }
}

/// Dados do membro exibidos no cartão e nos headers.
struct MemberInfo: Equatable {
    let nome: String
    let numeroMembro: String
    let nivel: String
    let desde: String
    /// Sem API real ainda: `verifyUrl` de GET members/me/card.
    let verifyUrl: String
    /// Nome do clube no cartão (`clubName` do backend).
    var clube: String = "Mundo Planalto"

    /// Usuário fictício "Acessar demonstração" (idêntico ao Android).
    static let demo = MemberInfo(
        nome: "José R. Castro",
        numeroMembro: "8150",
        nivel: "Founder",
        desde: "2026",
        verifyUrl: "https://portal.mundoplanalto.com.br/card/HRVC-8150-DEMO"
    )
}
