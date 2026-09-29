//
//  AppRouter.swift
//  Hard Rock Hotel & Vacation Club
//
//  Estado de navegação: aba selecionada e pilha (NavigationPath) de cada aba.
//  Injetado como EnvironmentObject a partir da MainTabView.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: TabItem = .inicio
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
        case .ofertas: return "ofertas"
        case .empreendimentos: return "empreendimentos"
        case .perfil: return "perfil"
        }
    }
}

extension AppRoute {
    static func debugRoute(named name: String) -> AppRoute? {
        switch name {
        case "financeiro": return .financeiro
        case "extrato": return .extrato
        case "informe": return .informeRendimentos
        case "certificados": return .certificados
        case "unity": return .unityMilhas
        case "cartao": return .cartaoDigital
        case "avisos": return .avisosNoticias
        case "politica": return .politicaPrivacidade
        case "sistema": return .sistema
        case "obra": return .detalhesObra(EmpreendimentosViewModel.demoVenture)
        default: return nil
        }
    }
}
#endif
