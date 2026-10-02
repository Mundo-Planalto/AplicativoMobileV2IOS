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

    static var certificates: CertificatesRepository { mockNewApi ? CertificatesRepositoryMock.shared : CertificatesRepositoryRemote() }
    static var partners: PartnersRepository { mockNewApi ? PartnersRepositoryMock.shared : PartnersRepositoryRemote() }
    static var campaigns: CampaignsRepository { mockNewApi ? CampaignsRepositoryMock.shared : CampaignsRepositoryRemote() }
    static var member: MemberRepository { mockNewApi ? MemberRepositoryMock.shared : MemberRepositoryRemote() }
    static var travelProfile: TravelProfileRepository { mockNewApi ? TravelProfileRepositoryMock.shared : TravelProfileRepositoryRemote() }
    static var changeRequests: ChangeRequestsRepository { mockNewApi ? ChangeRequestsRepositoryMock.shared : ChangeRequestsRepositoryRemote() }
    static var ventures: VenturesRepository { isDemo ? VenturesRepositoryMock.shared : VenturesRepositoryRemote() }
    static var financeiro: FinanceiroRepository { isDemo ? FinanceiroRepositoryMock.shared : FinanceiroRepositoryRemote() }

    // Legado, removido conforme as telas migram (itens 5 e 7 da revisão).
    static var ofertas: OfertasRepository { mockNewApi ? OfertasRepositoryMock.shared : OfertasRepositoryRemote() }
    static var certificados: CertificadosRepository { mockNewApi ? CertificadosRepositoryMock.shared : CertificadosRepositoryRemote() }
}
