//
//  IncomeTaxReportView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct IncomeTaxReportView: View {
    let pdfUrl: String
    @State private var isLoading = true
    @State private var error: String?

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

                // PDF Viewer placeholder (em produção seria um componente real de PDF)
                ZStack {
                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentCyan))
                            Text("Carregando PDF...")
                                .foregroundColor(.white)
                        }
                    } else if let error = error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            Text("Erro ao carregar PDF")
                                .foregroundColor(.white)
                            Text(error)
                                .foregroundColor(.gray)
                                .font(.caption)
                            Button("Tentar Novamente") {
                                loadPDF()
                            }
                            .foregroundColor(AppColors.accentCyan)
                        }
                        .padding()
                    } else {
                        // PDF Viewer simulado
                        VStack(spacing: 20) {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 80))
                                .foregroundColor(AppColors.accentCyan)

                            Text("PDF do Informe de Rendimentos")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("URL: \(pdfUrl)")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text("Em uma implementação real, este seria um visualizador de PDF completo com zoom, navegação de páginas e todas as funcionalidades necessárias.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            loadPDF()
        }
    }

    private func loadPDF() {
        isLoading = true
        error = nil

        // Simular carregamento do PDF
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoading = false
            // Simular erro para demonstração
            // error = "Erro de rede - tente novamente"
        }
    }
}

#Preview {
    NavigationView {
        IncomeTaxReportView(pdfUrl: "https://example.com/informe-2024.pdf")
    }
}