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
        NavigationView {
            ZStack {
                bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Preencha os dados do novo endereço. A alteração será enviada para aprovação.")
                            .font(.subheadline)
                            .foregroundColor(textS)
                            .padding(.bottom, 8)

                        field("Rua", text: $logradouro, placeholder: "Rua")
                        field("Número", text: $numero, placeholder: "Número")
                        field("Bairro", text: $bairro, placeholder: "Bairro")
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Cidade - UF")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(textP)
                            HStack(spacing: 12) {
                                TextField("Cidade", text: $cidade)
                                    .padding(12)
                                    .background(cardBg)
                                    .cornerRadius(10)
                                    .foregroundColor(textP)
                                TextField("UF", text: $estado)
                                    .padding(12)
                                    .background(cardBg)
                                    .cornerRadius(10)
                                    .foregroundColor(textP)
                                    .frame(maxWidth: 80)
                            }
                        }
                        field("CEP", text: $cep, placeholder: "00000-000")
                            .keyboardType(.numberPad)

                        if let msg = message {
                            Text(msg)
                                .font(.subheadline)
                                .foregroundColor(success ? .green : .red)
                                .padding(.top, 8)
                        }

                        HStack(spacing: 12) {
                            Button("Cancelar") {
                                dismiss()
                            }
                            .font(.headline)
                            .foregroundColor(AppColors.accentBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)

                            Button {
                                submit()
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Enviar Solicitação")
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
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 16)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Solicitar Alteração de Endereço")
            .navigationBarTitleDisplayMode(.inline)
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
                    complement: nil,
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
