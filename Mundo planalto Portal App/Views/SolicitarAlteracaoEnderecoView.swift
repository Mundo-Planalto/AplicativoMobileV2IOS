//
//  SolicitarAlteracaoEnderecoView.swift
//  Mundo planalto Portal App
//
//  Formulário para POST /api/address/change-requests
//

import SwiftUI

struct SolicitarAlteracaoEnderecoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var logradouro = ""
    @State private var numero = ""
    @State private var complemento = ""
    @State private var bairro = ""
    @State private var cidade = ""
    @State private var estado = ""
    @State private var cep = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var success = false

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    private var isValid: Bool {
        !logradouro.trimmingCharacters(in: .whitespaces).isEmpty
            && !numero.trimmingCharacters(in: .whitespaces).isEmpty
            && !bairro.trimmingCharacters(in: .whitespaces).isEmpty
            && !cidade.trimmingCharacters(in: .whitespaces).isEmpty
            && !estado.trimmingCharacters(in: .whitespaces).isEmpty
            && cep.filter({ $0.isNumber }).count >= 8
    }

    var body: some View {
        NavigationStack {
            ZStack {
                bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Informe o novo endereço de correspondência. A alteração será analisada pela equipe.")
                            .font(.subheadline)
                            .foregroundColor(textS)
                            .padding(.bottom, 8)

                        field("Logradouro", text: $logradouro, placeholder: "Rua, Avenida...")
                        field("Número", text: $numero, placeholder: "Nº")
                        field("Complemento", text: $complemento, placeholder: "Apto, Bloco...")
                        field("Bairro", text: $bairro, placeholder: "Bairro")
                        HStack(spacing: 12) {
                            field("Cidade", text: $cidade, placeholder: "Cidade")
                            field("UF", text: $estado, placeholder: "SP")
                                .frame(maxWidth: 80)
                        }
                        field("CEP", text: $cep, placeholder: "00000-000")
                            .keyboardType(.numberPad)

                        if let msg = message {
                            Text(msg)
                                .font(.subheadline)
                                .foregroundColor(success ? .green : .red)
                                .padding(.top, 8)
                        }

                        Button {
                            submit()
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Enviar solicitação")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isValid && !isLoading ? AppColors.accentBlue : cardBg)
                            .foregroundColor(isValid && !isLoading ? .white : textS)
                            .cornerRadius(12)
                        }
                        .disabled(!isValid || isLoading)
                        .padding(.top, 16)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Solicitar alteração de endereço")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(AppColors.accentBlue)
                }
            }
        }
    }

    private func field(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(textP)
            TextField(placeholder, text: text)
                .padding(12)
                .background(cardBg)
                .cornerRadius(10)
                .foregroundColor(textP)
        }
    }

    private func submit() {
        let zip = cep.filter { $0.isNumber }
        guard zip.count >= 8 else {
            message = "CEP inválido."
            success = false
            return
        }
        isLoading = true
        message = nil
        Task {
            do {
                let result = try await AddressService.shared.createChangeRequest(
                    street: logradouro.trimmingCharacters(in: .whitespaces),
                    number: numero.trimmingCharacters(in: .whitespaces),
                    complement: complemento.isEmpty ? nil : complemento.trimmingCharacters(in: .whitespaces),
                    neighborhood: bairro.trimmingCharacters(in: .whitespaces),
                    city: cidade.trimmingCharacters(in: .whitespaces),
                    state: estado.trimmingCharacters(in: .whitespaces),
                    zipCode: zip
                )
                await MainActor.run {
                    isLoading = false
                    if result != nil {
                        success = true
                        message = "Solicitação enviada com sucesso. Acompanhe pelo app."
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                    } else {
                        success = false
                        message = "Não foi possível enviar. Tente novamente."
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    success = false
                    message = "Erro de conexão. Tente novamente."
                }
            }
        }
    }
}

#Preview {
    SolicitarAlteracaoEnderecoView()
        .environmentObject(AppState.shared)
}
