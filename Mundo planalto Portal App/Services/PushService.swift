//
//  PushService.swift
//  Mundo Planalto
//
//  Push pelo Firebase Messaging: tópicos (announcements e user_{id}, como o backend já envia)
//  e destino do toque na notificação, inclusive quando o app estava fechado.
//

import Foundation
import FirebaseMessaging

/// Tela aberta ao tocar na notificação. Vem da chave `screen` do payload de dados;
/// sem a chave (payload atual do portal), abre Avisos.
enum PushDestination: String {
    case avisos, empreendimentos, viagens, campanhas, financeiro

    init(userInfo: [AnyHashable: Any]) {
        let raw = ((userInfo["screen"] ?? userInfo["type"]) as? String)?.lowercased() ?? ""
        switch raw {
        case "ventures", "venture", "empreendimentos", "obra": self = .empreendimentos
        case "certificates", "certificate", "viagens": self = .viagens
        case "campaigns", "campaign", "campanhas": self = .campanhas
        case "financial", "financeiro", "boleto": self = .financeiro
        default: self = .avisos
        }
    }
}

extension Notification.Name {
    static let hrPushDestination = Notification.Name("HrPushDestination")
}

enum PushService {
    /// Destino de um toque recebido antes de a tela principal existir (app fechado ou no Login).
    private static var pending: PushDestination?

    static func handleTap(userInfo: [AnyHashable: Any]) {
        let destination = PushDestination(userInfo: userInfo)
        pending = destination
        NotificationCenter.default.post(name: .hrPushDestination, object: nil)
        #if DEBUG
        print("[Push] Toque na notificação → \(destination.rawValue)")
        #endif
    }

    /// Chamado pela tela principal ao aparecer e a cada toque: devolve o destino uma única vez.
    static func consumePending() -> PushDestination? {
        defer { pending = nil }
        return pending
    }

    /// Token do Firebase deste aparelho (para o diagnóstico em builds de teste).
    static var currentToken: String? { Messaging.messaging().fcmToken }

    /// Inscreve nos tópicos que o backend usa hoje: `announcements` (todos) e `user_{id}` (login real).
    static func syncTopics() {
        guard Messaging.messaging().fcmToken != nil else { return }
        subscribe("announcements")
        if !AppState.shared.isDemoSession, let id = PreferencesManager.shared.getUserId(), !id.isEmpty,
           PreferencesManager.shared.getAuthToken() != nil {
            subscribe("user_\(id)")
        }
    }

    /// Ao sair da conta, o aparelho deixa de receber os avisos daquele cliente.
    static func unsubscribeUser(id: String?) {
        guard let id, !id.isEmpty, id != "demo" else { return }
        Messaging.messaging().unsubscribe(fromTopic: "user_\(id)") { error in
            #if DEBUG
            print("[FCM] Saiu do tópico user_\(id)" + (error.map { ": \($0.localizedDescription)" } ?? ""))
            #endif
        }
    }

    private static func subscribe(_ topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            #if DEBUG
            if let e = error { print("[FCM] Erro ao inscrever em \(topic): \(e.localizedDescription)") }
            else { print("[FCM] Inscrito no tópico \(topic)") }
            #endif
        }
    }
}
