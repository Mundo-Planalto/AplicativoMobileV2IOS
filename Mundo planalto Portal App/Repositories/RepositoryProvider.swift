//
//  RepositoryProvider.swift
//  Hard Rock Hotel & Vacation Club
//
//  Escolhe Mock ou Remote:
//  - API nova (membros, benefícios, ofertas, certificados): AppConfig.useMockData
//    (true até o backend entrar em homologação) ou sessão de demonstração.
//  - Financeiro/empreendimento (API do portal já existente): Remote com login real,
//    Mock na demonstração.
//

import Foundation

enum RepositoryProvider {
    private static var isDemo: Bool { AppState.shared.isDemoSession }
    private static var mockNewApi: Bool { AppConfig.useMockData || isDemo }

    static var members: MembersRepository { mockNewApi ? MembersRepositoryMock.shared : MembersRepositoryRemote() }
    static var beneficios: BeneficiosRepository { mockNewApi ? BeneficiosRepositoryMock.shared : BeneficiosRepositoryRemote() }
    static var ofertas: OfertasRepository { mockNewApi ? OfertasRepositoryMock.shared : OfertasRepositoryRemote() }
    static var certificados: CertificadosRepository { mockNewApi ? CertificadosRepositoryMock.shared : CertificadosRepositoryRemote() }
    static var financeiro: FinanceiroRepository { isDemo ? FinanceiroRepositoryMock.shared : FinanceiroRepositoryRemote() }
}
