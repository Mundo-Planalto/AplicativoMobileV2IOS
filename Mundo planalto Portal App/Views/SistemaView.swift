//
//  SistemaView.swift
//  Mundo Planalto
//
//  Sistema/Configurações: notificações, política de privacidade e versão.
//

import SwiftUI
import UserNotifications

struct SistemaView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @State private var notificacoes = true

    private var versao: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return b.isEmpty ? v : "\(v) (\(b))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
                HrBackHeader(titulo: "Sistema", subtitulo: "Notificações, política e versão")

                HrSectionTitle(titulo: "Notificações")
                HrCard {
                    Toggle(isOn: $notificacoes) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Notificações push").font(HrFont.itemTitle).foregroundColor(.white)
                            Text("Avisos do empreendimento e novidades do clube").font(HrFont.captionSmall).foregroundColor(.hrTextMuted)
                        }
                    }
                    .tint(.hrGold)
                }

                HrSectionTitle(titulo: "Legal").padding(.top, 8)
                // Com URL oficial definida em AppConfig abre no navegador interno; sem ela, tela "em breve".
                HrListRow(icon: "hand.raised.fill", titulo: "Política de privacidade", subtitulo: "Como tratamos seus dados pessoais") {
                    if let url = HrLinks.url(from: AppConfig.privacyPolicyURL) { router.open(url) } else { router.push(.politicaPrivacidade) }
                }
                HrListRow(icon: "doc.text.fill", titulo: "Termos de uso", subtitulo: "Leia nossos termos e condições") {
                    if let url = HrLinks.url(from: AppConfig.termsOfUseURL) { router.open(url) } else { router.push(.termosUso) }
                }

                #if DEBUG
                PushDiagnosticoCard().padding(.top, 8)
                #endif

                HStack {
                    Spacer()
                    Text("Mundo Planalto • Versão \(versao)")
                        .font(HrFont.captionSmall)
                        .foregroundColor(.hrTextMuted)
                    Spacer()
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, HrMetrics.screenMargin)
            .padding(.bottom, HrMetrics.scrollBottomInset)
        }
        .hrScreen()
        .onAppear { notificacoes = appState.notificationsEnabled }
        .onChange(of: notificacoes) { _, on in appState.setNotificationsEnabled(on) }
    }
}

#if DEBUG
/// Só em builds de teste: situação do push neste aparelho e cópia do token para enviar
/// uma mensagem de teste pelo console do Firebase.
private struct PushDiagnosticoCard: View {
    @State private var permissao = "…"
    @State private var token: String?
    @State private var copiado = false

    var body: some View {
        VStack(alignment: .leading, spacing: HrMetrics.cardSpacing) {
            HrSectionTitle(titulo: "Diagnóstico de push", subtitulo: "Visível só no build de teste")
            HrCard {
                VStack(alignment: .leading, spacing: 8) {
                    linha("Permissão", permissao)
                    linha("Registro na Apple (APNs)", UIApplication.shared.isRegisteredForRemoteNotifications ? "Registrado" : "Não registrado")
                    linha("Token do Firebase", token == nil ? "Ainda não recebido" : "Recebido")
                    linha("Tópicos", topicos)
                    HrOutlineButton(text: copiado ? "Token copiado" : "Copiar token de push", icon: "doc.on.doc", isEnabled: token != nil) {
                        UIPasteboard.general.string = token
                        copiado = true
                    }
                    .padding(.top, 4)
                }
            }
        }
        .task { await atualizar() }
    }

    private var topicos: String {
        var t = ["announcements"]
        if !AppState.shared.isDemoSession, let id = PreferencesManager.shared.getUserId(), !id.isEmpty { t.append("user_\(id)") }
        return t.joined(separator: ", ")
    }

    private func linha(_ titulo: String, _ valor: String) -> some View {
        HStack(alignment: .top) {
            Text(titulo).font(HrFont.caption).foregroundColor(.hrTextMuted)
            Spacer()
            Text(valor).font(HrFont.caption).foregroundColor(.white).multilineTextAlignment(.trailing)
        }
    }

    private func atualizar() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized: permissao = "Concedida"
        case .denied: permissao = "Negada (ative em Ajustes)"
        case .notDetermined: permissao = "Ainda não perguntada"
        case .provisional: permissao = "Provisória"
        case .ephemeral: permissao = "Temporária"
        @unknown default: permissao = "Desconhecida"
        }
        token = PushService.currentToken
    }
}
#endif

#Preview {
    NavigationStack { SistemaView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
