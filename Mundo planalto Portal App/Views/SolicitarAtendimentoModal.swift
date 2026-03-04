//
//  SolicitarAtendimentoModal.swift
//  Mundo planalto Portal App
//
//  Modal conforme anexo: título, descrição, campo Mensagem, Cancelar e Enviar.
//

import SwiftUI

struct SolicitarAtendimentoModal: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var message: String
    var isDark: Bool = true
    var onSend: ((String) async -> Void)?

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Solicitar Atendimento")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(textP)

            Text("Preencha os dados abaixo para solicitar atendimento. Nossa equipe entrará em contato em breve.")
                .font(.subheadline)
                .foregroundColor(textS)

            TextField("Mensagem", text: $message, axis: .vertical)
                .lineLimit(3...6)
                .padding(10)
                .background(cardBg)
                .cornerRadius(10)
                .foregroundColor(textP)

            HStack(spacing: 10) {
                Button("Cancelar") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(AppColors.accentBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

                Button("Enviar") {
                    Task {
                        await onSend?(message.trimmingCharacters(in: .whitespacesAndNewlines))
                        await MainActor.run { dismiss() }
                    }
                }
                .font(.headline)
                .foregroundColor(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? textS : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? cardBg : AppColors.accentBlue)
                .cornerRadius(10)
                .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(AppColors.backgroundPrimary(dark: isDark))
    }
}
