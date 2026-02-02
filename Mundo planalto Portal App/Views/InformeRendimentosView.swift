//
//  InformeRendimentosView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct InformeRendimentosView: View {
    @StateObject private var viewModel = InformeRendimentosViewModel()
    @State private var showReport = false

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopAppBar
                ZStack {
                    AppColors.backgroundPrimary
                        .ignoresSafeArea()

                    HStack {
                        Button(action: {
                            // Voltar será tratado pela NavigationStack
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }

                        Spacer()

                        Text("Informe de Rendimentos")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 60)

                ScrollView {
                    VStack(spacing: 24) {
                        // Seleção de ano
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Selecione o ano do informe")
                                .font(.headline)
                                .foregroundColor(.white)

                            Picker("Ano", selection: $viewModel.selectedYear) {
                                ForEach(viewModel.availableYears, id: \.self) { year in
                                    Text(year).tag(year)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // Informações sobre o informe
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Sobre o Informe de Rendimentos")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 12) {
                                InfoItem(
                                    icon: "doc.text.fill",
                                    title: "Documento Oficial",
                                    description: "Informe de rendimentos para declaração do Imposto de Renda"
                                )

                                InfoItem(
                                    icon: "calendar",
                                    title: "Ano Selecionado",
                                    description: "Dados do ano \(viewModel.selectedYear) conforme legislação"
                                )

                                InfoItem(
                                    icon: "checkmark.shield.fill",
                                    title: "Dados Seguros",
                                    description: "Informações protegidas conforme LGPD"
                                )
                            }
                        }
                        .padding(.horizontal)

                        // Botão gerar informe
                        VStack(spacing: 16) {
                            GradientButton(
                                title: "Gerar Informe",
                                action: {
                                    Task {
                                        await viewModel.generateReport()
                                    }
                                },
                                isLoading: viewModel.isLoading,
                                isEnabled: !viewModel.selectedYear.isEmpty
                            )
                            .padding(.horizontal)

                            // Mensagem de erro
                            if let error = viewModel.error {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            // Mensagem de sucesso
                            if viewModel.pdfUrl != nil {
                                Text("Informe gerado com sucesso!")
                                    .foregroundColor(AppColors.accentCyan)
                                    .font(.headline)
                                    .padding(.top, 8)
                            }
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.vertical)
                }
            }
        }
        .onChange(of: viewModel.pdfUrl) { _, newUrl in
            if newUrl != nil {
                showReport = true
            }
        }
        .navigationDestination(isPresented: $showReport) {
            IncomeTaxReportView(pdfUrl: viewModel.pdfUrl!)
        }
    }
}

struct InfoItem: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.accentCyan)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        InformeRendimentosView()
    }
}