//
//  ExtratoView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct ExtratoView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ExtratoViewModel()

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
                // Barra superior: voltar + título
                HStack(spacing: 16) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(isDark ? .white : .primary)
                    }
                    Spacer()
                    Text("Extrato Financeiro")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(textP)
                    Spacer()
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(bg)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentBlue))
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(textP)
                            .multilineTextAlignment(.center)
                        Button("Tentar Novamente") {
                            Task { await viewModel.loadFinancialStatement() }
                        }
                        .foregroundColor(AppColors.accentBlue)
                    }
                    .padding()
                    Spacer()
                } else {
                    // Abas: A Vencer | Pagas | Vencidas  +  Filtros
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(viewModel.tabOptions, id: \.rawValue) { tab in
                            Button {
                                viewModel.setFilter(tab)
                            } label: {
                                VStack(spacing: 6) {
                                    Text(tab.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(viewModel.selectedFilter == tab ? .semibold : .regular)
                                        .foregroundColor(viewModel.selectedFilter == tab ? AppColors.accentBlue : textS)
                                    Rectangle()
                                        .fill(viewModel.selectedFilter == tab ? AppColors.accentBlue : Color.clear)
                                        .frame(height: 2)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Button {
                            viewModel.showFilterModal = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.body)
                                Text("Filtros")
                                    .font(.subheadline)
                            }
                            .foregroundColor(AppColors.accentBlue)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColors.textSecondary(dark: isDark).opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(bg)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredItems) { item in
                                ParcelaCardExtrato(item: item, isDark: isDark)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showFilterModal) {
            FiltrarParcelasModal(
                empreendimento: $viewModel.filtroEmpreendimento,
                periodo: $viewModel.filtroPeriodo,
                onCancel: { viewModel.showFilterModal = false },
                onApply: { viewModel.applyFiltersFromModal() },
                isDark: isDark
            )
        }
        .onAppear {
            Task { await viewModel.loadFinancialStatement() }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Card no layout do anexo: descrição, tag, Vencimento, Valor, Ver Boleto, Gerar 2ª Via
struct ParcelaCardExtrato: View {
    let item: FinancialStatementItem
    var isDark: Bool = true
    @State private var loadingBoleto = false
    @State private var boletoError: String?
    @State private var showBoletoAlert = false

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    private func statusText(_ status: PaymentStatus) -> String {
        switch status {
        case .paid: return "Pagas"
        case .upcoming: return "A Vencer"
        case .overdue: return "Vencidas"
        }
    }

    private func statusTagColor(_ status: PaymentStatus) -> Color {
        switch status {
        case .paid: return .green
        case .upcoming: return Color(hex: "#E68A00")
        case .overdue: return .red
        }
    }

    private func openBoleto() {
        guard item.billReceivableId != nil || item.esolutionBoletoId != nil else {
            boletoError = "Boleto não disponível para esta parcela."
            showBoletoAlert = true
            return
        }
        loadingBoleto = true
        boletoError = nil
        Task {
            let url = await ExtratoService.shared.getBoletoPdfUrl(item: item)
            await MainActor.run {
                loadingBoleto = false
                if let url = url {
                    UIApplication.shared.open(url)
                } else {
                    boletoError = "Não foi possível carregar o boleto. Tente novamente."
                    showBoletoAlert = true
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Linha 1: nome + " - 30/"  |  tag (A Vencer / Vencidas / Pagas)
            HStack(alignment: .top) {
                Text("\(item.ventureName) - \(item.parcela)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(textP)
                    .lineLimit(2)
                Spacer()
                Text(statusText(item.status))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(statusTagColor(item.status))
                    )
            }

            // Linha 2: Vencimento (esq)  |  Valor (dir)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vencimento")
                        .font(.caption)
                        .foregroundColor(textS)
                    Text(item.dueDate)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(textP)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Valor")
                        .font(.caption)
                        .foregroundColor(textS)
                    Text(formatCurrency(item.amount))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(textP)
                }
            }

            // Botões: Ver Boleto  |  Gerar 2ª Via
            HStack(spacing: 12) {
                Button {
                    openBoleto()
                } label: {
                    HStack(spacing: 6) {
                        if loadingBoleto {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "eye.fill")
                                .font(.caption)
                        }
                        Text("Ver Boleto")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.accentBlue)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(loadingBoleto)

                Button {
                    openBoleto()
                } label: {
                    Text("Gerar 2ª Via")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.accentBlue)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(loadingBoleto)
            }
            .alert("Boleto", isPresented: $showBoletoAlert) {
                Button("OK") { boletoError = nil }
            } message: {
                if let msg = boletoError { Text(msg) }
            }
        }
        .padding()
        .background(cardBg)
        .cornerRadius(12)
    }
}

// MARK: - Modal Filtrar Parcelas
struct FiltrarParcelasModal: View {
    @Binding var empreendimento: FiltroEmpreendimento
    @Binding var periodo: FiltroPeriodo
    var onCancel: () -> Void
    var onApply: () -> Void
    var isDark: Bool = true

    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    var body: some View {
        VStack(spacing: 0) {
            Text("Filtrar Parcelas")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(textP)
                .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 16) {
                Text("Empreendimento")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(textP)
                ForEach(FiltroEmpreendimento.allCases, id: \.rawValue) { opt in
                    Button {
                        empreendimento = opt
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: empreendimento == opt ? "circle.inset.filled" : "circle")
                                .foregroundColor(AppColors.accentBlue)
                            Text(opt.rawValue)
                                .font(.subheadline)
                                .foregroundColor(textP)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 16) {
                Text("Período")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(textP)
                ForEach(FiltroPeriodo.allCases, id: \.rawValue) { opt in
                    Button {
                        periodo = opt
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: periodo == opt ? "circle.inset.filled" : "circle")
                                .foregroundColor(AppColors.accentBlue)
                            Text(opt.rawValue)
                                .font(.subheadline)
                                .foregroundColor(textP)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.bottom, 24)

            HStack(spacing: 12) {
                Button("Cancelar") {
                    onCancel()
                }
                .font(.headline)
                .foregroundColor(AppColors.accentBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.accentBlue, lineWidth: 1)
                )

                Button("Aplicar Filtros") {
                    onApply()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.accentBlue)
                .cornerRadius(10)
            }
        }
        .padding(24)
        .background(cardBg)
        .cornerRadius(16)
        .padding(40)
    }
}

#Preview {
    NavigationStack {
        ExtratoView()
            .environmentObject(AppState.shared)
    }
}
