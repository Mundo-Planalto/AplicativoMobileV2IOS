//
//  RepositoryProvider.swift
//  Mundo Planalto
//
//  Escolhe Mock ou Remote:
//  - API nova (certificados, parceiros, campanhas, membro, perfil de viagem, alteração de
//    dados): AppConfig.useMockData (true até o backend entrar em homologação) ou sessão demo.
//  - Empreendimentos e Financeiro (API do portal já existente): Remote com login real,
//    Mock na demonstração.
//

import Foundation

enum RepositoryProvider {
    private static var isDemo: Bool { AppState.shared.isDemoSession }
    private static var mockNewApi: Bool { AppConfig.useMockData || isDemo }

    /// Ações da API nova que ainda não chegam ao servidor (ativar certificado, interesse em
    /// campanha, salvar perfil de viagem, cupom): ficam travadas com "Disponível em breve".
    static var acoesSimuladas: Bool { mockNewApi }

    static var certificates: CertificatesRepository { mockNewApi ? CertificatesRepositoryMock.shared : CertificatesRepositoryRemote() }
    static var partners: PartnersRepository { mockNewApi ? PartnersRepositoryMock.shared : PartnersRepositoryRemote() }
    static var campaigns: CampaignsRepository { mockNewApi ? CampaignsRepositoryMock.shared : CampaignsRepositoryRemote() }
    static var member: MemberRepository { mockNewApi ? MemberRepositoryMock.shared : MemberRepositoryRemote() }
    static var travelProfile: TravelProfileRepository { mockNewApi ? TravelProfileRepositoryMock.shared : TravelProfileRepositoryRemote() }
    /// Demonstração: Mock. Login real: enquanto a API nova não existe, endereço usa o endpoint
    /// atual do portal (telefone e e-mail ficam indisponíveis); depois, o contrato novo.
    static var changeRequests: ChangeRequestsRepository {
        if isDemo { return ChangeRequestsRepositoryMock.shared }
        return AppConfig.useMockData ? ChangeRequestsRepositoryPortal() : ChangeRequestsRepositoryRemote()
    }
    static var ventures: VenturesRepository { isDemo ? VenturesRepositoryMock.shared : VenturesRepositoryRemote() }
    static var financeiro: FinanceiroRepository { isDemo ? FinanceiroRepositoryMock.shared : FinanceiroRepositoryRemote() }
}
