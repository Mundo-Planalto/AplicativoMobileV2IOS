//
//  InformeRendimentosModels.swift
//  Mundo planalto Portal App
//
//  Estrutura preparada para ser preenchida pelo endpoint quando disponível.
//

import Foundation

/// Dados do informe de rendimentos (será preenchido pelo endpoint posteriormente).
struct InformeRendimentosData: Codable, Equatable {
    let anoBase: String
    let contribuinte: InformeContribuinte?
    let resumo: InformeResumo?
    let pagamentos: [InformePagamento]?
    let pdfUrl: String?
}

/// Informações do contribuinte (seção "Informações do Contribuinte").
struct InformeContribuinte: Codable, Equatable {
    let nome: String
    let cpf: String
    let anoBase: String
}

/// Resumo dos rendimentos (seção "Resumo dos Rendimentos").
struct InformeResumo: Codable, Equatable {
    let totalPagamentos: Int
    let valorTotalRendimentos: Double
}

/// Item do detalhamento de pagamentos (seção "Detalhamento dos Pagamentos").
struct InformePagamento: Codable, Identifiable, Equatable {
    let id: String
    let data: String
    let dataPagamento: String?
    let valor: Double
    let transacaoId: String
    let empresa: String
    let metodo: String
}
