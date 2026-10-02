//
//  AppRouter.swift
//  Mundo Planalto
//
//  Estado de navegação: aba selecionada e pilha (NavigationPath) de cada aba.
//  Injetado como EnvironmentObject a partir da MainTabView.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: TabItem = .inicio
    /// Navegador interno aberto sobre as abas (docs/telas.md, "Navegador interno").
    @Published var browser: HrBrowserDestination?
    /// Pedido de rolagem dentro da aba Benefícios (ex.: atalho Unity da Início rola até o card).
    @Published var beneficiosScrollTarget: String?
    @Published var paths: [TabItem: NavigationPath] = Dictionary(
        uniqueKeysWithValues: TabItem.allCases.map { ($0, NavigationPath()) }
    )

    init() {
        #if DEBUG
        // Atalhos de teste pelo simctl: `-hrTab ofertas` abre numa aba; `-hrRoute financeiro` empilha uma rota.
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-hrTab"), i + 1 < args.count,
           let tab = TabItem.allCases.first(where: { $0.debugKey == args[i + 1] }) {
            selectedTab = tab
        }
        if let i = args.firstIndex(of: "-hrRoute"), i + 1 < args.count,
           let route = AppRoute.debugRoute(named: args[i + 1]) {
            var p = paths[selectedTab] ?? NavigationPath()
            p.append(route)
            paths[selectedTab] = p
        }
        #endif
    }

    /// Binding da pilha de uma aba, para o NavigationStack.
    func path(for tab: TabItem) -> Binding<NavigationPath> {
        Binding(
            get: { self.paths[tab] ?? NavigationPath() },
            set: { self.paths[tab] = $0 }
        )
    }

    /// Empilha uma rota na aba atual (ou na aba informada, trocando para ela).
    func push(_ route: AppRoute, on tab: TabItem? = nil) {
        let target = tab ?? selectedTab
        if target != selectedTab { selectedTab = target }
        var p = paths[target] ?? NavigationPath()
        p.append(route)
        paths[target] = p
    }

    /// Abre uma URL externa dentro do app. WhatsApp, Instagram e YouTube tentam antes o app
    /// nativo (universal link); se não estiver instalado, caem no navegador interno.
    func open(_ url: URL?) {
        guard let url else { return }
        guard HrLinks.isWebURL(url) else {
            UIApplication.shared.open(url)
            return
        }
        if HrLinks.prefersNativeApp(url) {
            UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { [weak self] opened in
                if !opened {
                    Task { @MainActor in self?.browser = HrBrowserDestination(url: url) }
                }
            }
        } else {
            browser = HrBrowserDestination(url: url)
        }
    }

    func open(_ string: String?) { open(HrLinks.url(from: string)) }

    /// Troca de aba e volta à raiz dela.
    func switchTab(_ tab: TabItem, popToRoot: Bool = false) {
        selectedTab = tab
        if popToRoot { paths[tab] = NavigationPath() }
    }

    func pop(on tab: TabItem? = nil) {
        let target = tab ?? selectedTab
        var p = paths[target] ?? NavigationPath()
        if !p.isEmpty { p.removeLast() }
        paths[target] = p
    }

    func popToRoot(on tab: TabItem? = nil) {
        paths[tab ?? selectedTab] = NavigationPath()
    }
}

#if DEBUG
extension TabItem {
    var debugKey: String {
        switch self {
        case .inicio: return "inicio"
        case .beneficios: return "beneficios"
        case .campanhas: return "campanhas"
        case .empreendimentos: return "empreendimentos"
        case .perfil: return "perfil"
        }
    }
}

extension AppRoute {
    /// Empreendimento das rotas de teste: o real em cache no login real, o de demonstração na sessão demo.
    private static var debugVenture: Venture {
        if !AppState.shared.isDemoSession,
           let real = EmpreendimentosService.shared.getEmpreendimentosCached()?.empreendimentos.first {
            return real
        }
        return VenturesRepositoryMock.demoVenture
    }

    static func debugRoute(named name: String) -> AppRoute? {
        switch name {
        case "financeiro": return .financeiro
        case "extrato": return .extrato
        case "informe": return .informeRendimentos
        case "viagens": return .viagens
        case "cartao": return .cartaoDigital
        case "perfil-viagem": return .perfilViagem
        case "alteracao": return .alteracaoDados(.phone)
        case "avisos": return .avisosNoticias
        case "politica": return .politicaPrivacidade
        case "sistema": return .sistema
        case "obra": return .videosObra(debugVenture)
        case "hub": return .empreendimento(debugVenture)
        case "galeria": return .galeria(debugVenture)
        case "documentos": return .documentos(debugVenture)
        case "financeiro-hub": return .financeiroEmpreendimento(debugVenture)
        default: return nil
        }
    }
}
#endif
