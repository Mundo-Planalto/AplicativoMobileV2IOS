//
//  InformeRendimentosView.swift
//  Mundo planalto Portal App
//
//  Layout conforme anexo. Documento será gerado com informações do endpoint quando disponível.
//

import SwiftUI

struct InformeRendimentosView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = InformeRendimentosViewModel()
    @State private var showDetail = false

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        ZStack {
            bg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HrBackHeader(titulo: "Informe de rendimentos", subtitulo: "Selecione o ano para gerar o informe de rendimentos")

                        Group {
                            if viewModel.isLoadingYears {
                                VStack(alignment: .leading, spacing: 14) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(0..<8, id: \.self) { _ in
                                                ShimmerSkeletonCard(height: 44, isDark: isDark)
                                                    .frame(width: 76)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            }
                                        }
                                        .padding(.horizontal, 2)
                                    }
                                    HStack(spacing: 10) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentBlue))
                                        Text("Buscando anos no seu extrato…")
                                            .font(.subheadline)
                                            .foregroundColor(textS)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 4)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Carregando anos disponíveis")
                            } else if viewModel.availableYears.isEmpty {
                                if viewModel.error == nil {
                                    Text("Nenhum ano encontrado no extrato. Abra o extrato financeiro ou tente novamente em instantes.")
                                        .font(.subheadline)
                                        .foregroundColor(textS)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.availableYears, id: \.self) { year in
                                            HrChip(text: year, selected: viewModel.selectedYear == year) {
                                                viewModel.selectYear(year)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }

                        if let status = viewModel.statusMessage, viewModel.error == nil {
                            Text(status)
                                .font(.subheadline)
                                .foregroundColor(AppColors.accentBlue)
                        }

                        if let error = viewModel.error {
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.12))
                                .cornerRadius(12)
                        }

                        HrGoldButton(text: "Gerar informe", isLoading: viewModel.isLoading, isEnabled: !viewModel.selectedYear.isEmpty) {
                            Task { await viewModel.generateReport() }
                        }
                        .padding(.top, 8)
                    }
                    .padding(HrMetrics.screenMargin)
                }
            }
        }
        .task {
            await viewModel.loadAvailableYears(forceRefresh: true)
        }
        .onChange(of: viewModel.generatedData) { _, newValue in
            if newValue != nil { showDetail = true }
        }
        .navigationDestination(isPresented: $showDetail) {
            if let data = viewModel.generatedData {
                InformeRendimentosDetailView(data: data)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationView {
        InformeRendimentosView()
            .environmentObject(AppState.shared)
    }
}
