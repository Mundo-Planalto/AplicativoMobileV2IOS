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
                HStack(spacing: 16) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(isDark ? .white : .primary)
                    }
                    Spacer()
                    Text("Informe de Rendimentos")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(textP)
                    Spacer()
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(bg)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Informe de Rendimentos")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(textP)

                        Text("Selecione o ano para gerar o informe de rendimentos")
                            .font(.subheadline)
                            .foregroundColor(textS)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.availableYears, id: \.self) { year in
                                    Button {
                                        viewModel.selectYear(year)
                                    } label: {
                                        Text(year)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(viewModel.selectedYear == year ? .white : textP)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(viewModel.selectedYear == year ? AppColors.accentBlue : cardBg)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(viewModel.selectedYear == year ? Color.clear : textS.opacity(0.4), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 4)
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

                        Button {
                            Task { await viewModel.generateReport() }
                        } label: {
                            Text("Gerar Informe")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.accentBlue, AppColors.accentBlue.opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading || viewModel.selectedYear.isEmpty)
                        .opacity(viewModel.isLoading ? 0.7 : 1)
                        .overlay {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                }
            }
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
    NavigationStack {
        InformeRendimentosView()
            .environmentObject(AppState.shared)
    }
}
