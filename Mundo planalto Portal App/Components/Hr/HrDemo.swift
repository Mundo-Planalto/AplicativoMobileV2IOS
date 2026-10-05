//
//  HrDemo.swift
//  Mundo Planalto
//
//  Avisos para builds de teste: faixa fixa da sessão de demonstração e marcações das
//  funções que ainda não estão ligadas ao servidor (docs/PENDENCIAS.md).
//

import SwiftUI

/// Faixa fixa no topo de todas as telas da sessão de demonstração.
struct HrDemoBanner: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "eye.fill").font(.system(size: 11, weight: .bold))
            Text("DEMONSTRAÇÃO • dados de exemplo")
                .font(.system(size: 12, weight: .bold))
                .tracking(0.5)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundColor(.hrBlack)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.hrGoldLight.ignoresSafeArea(edges: .top))
        .accessibilityLabel("Sessão de demonstração. Os dados são de exemplo.")
    }
}

/// Botão desabilitado de uma função que ainda não chega ao servidor.
struct HrEmBreveButton: View {
    var body: some View {
        HrOutlineButton(text: "Disponível em breve", icon: "clock", isEnabled: false) {}
            // Fundo escuro para o rótulo continuar legível sobre fotos claras.
            .background(RoundedRectangle(cornerRadius: HrMetrics.buttonRadius, style: .continuous).fill(Color.black.opacity(0.6)))
    }
}

/// Linha de aviso: explica que nada é enviado ou que o conteúdo é de exemplo.
struct HrAvisoPendente: View {
    let texto: String

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 12, weight: .semibold))
                .padding(.top, 1)
            Text(texto)
                .font(HrFont.captionSmall)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundColor(.hrWarning)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Aviso das telas cujo conteúdo ainda é de exemplo no login real (na demonstração a faixa já avisa).
struct HrConteudoExemploAviso: View {
    var body: some View {
        if RepositoryProvider.acoesSimuladas, !AppState.shared.isDemoSession {
            HrAvisoPendente(texto: "Conteúdo de exemplo: esta tela ainda não recebe os seus dados do servidor.")
        }
    }
}

enum HrPendente {
    /// Texto único para qualquer tentativa de ação que ainda não existe no servidor.
    static let nadaEnviado = "Função disponível em breve. Nada foi enviado ao servidor."
}
