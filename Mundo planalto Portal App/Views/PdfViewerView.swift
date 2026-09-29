//
//  PdfViewerView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct PdfViewerView: View {
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

                        Text("Visualizador PDF")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 60)

                // PDF Content
                ZStack {
                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentCyan))
                                .scaleEffect(1.5)
                            Text("Carregando PDF...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    } else if let error = error {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)

                            Text("Erro ao carregar PDF")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.bold)

                            Text(error)
                                .foregroundColor(.gray)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Button(action: {
                                loadPDF()
                            }) {
                                Text("Tentar Novamente")
                                    .foregroundColor(AppColors.accentCyan)
                                    .font(.headline)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.accentCyan, lineWidth: 1)
                                    )
                            }
                        }
                        .padding()
                    } else {
                        // PDF Viewer simulado
                        VStack(spacing: 24) {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 100))
                                .foregroundColor(AppColors.accentCyan)

                            Text("PDF Carregado com Sucesso")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            VStack(spacing: 8) {
                                Text("URL do documento:")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)

                                Text(pdfUrl)
                                    .foregroundColor(AppColors.accentCyan)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            Text("Funcionalidades disponíveis:")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding(.top, 16)

                            VStack(alignment: .leading, spacing: 12) {
                                FeatureItem(icon: "magnifyingglass", text: "Zoom e navegação")
                                FeatureItem(icon: "arrow.left.arrow.right", text: "Scroll horizontal")
                                FeatureItem(icon: "doc.text.viewfinder", text: "Busca no documento")
                                FeatureItem(icon: "square.and.arrow.up", text: "Compartilhar PDF")
                                FeatureItem(icon: "printer", text: "Imprimir documento")
                            }
                            .padding(.horizontal)

                            Spacer()
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
            // Simular sucesso - em produção seria carregamento real
            // Para demonstração, manter sem erro
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.accentCyan)
                .frame(width: 24, height: 24)

            Text(text)
                .foregroundColor(.white)
                .font(.body)

            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        PdfViewerView(pdfUrl: "https://example.com/document.pdf")
    }
}