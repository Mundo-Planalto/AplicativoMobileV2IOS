//
//  SistemaView.swift
//  Hard Rock Hotel & Vacation Club
//
//  Sistema/Configurações: notificações, política de privacidade e versão.
//

import SwiftUI

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
                HrListRow(icon: "hand.raised.fill", titulo: "Política de privacidade", subtitulo: "Como tratamos seus dados pessoais") {
                    router.push(.politicaPrivacidade)
                }
                HrListRow(icon: "doc.text.fill", titulo: "Termos de uso", subtitulo: "Leia nossos termos e condições") {
                    router.push(.politicaPrivacidade)
                }

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

#Preview {
    NavigationStack { SistemaView() }
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}
