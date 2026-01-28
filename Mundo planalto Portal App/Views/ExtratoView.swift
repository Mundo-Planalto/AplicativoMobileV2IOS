//
//  ExtratoView.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct ExtratoView: View {
    @StateObject private var viewModel = ExtratoViewModel()

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    private func statusColor(_ status: PaymentStatus) -> Color {
        switch status {
        case .paid:
            return .green
        case .upcoming:
            return .orange
        case .overdue:
            return .red
        }
    }

    private func statusText(_ status: PaymentStatus) -> String {
        switch status {
        case .paid:
            return "Pago"
        case .upcoming:
            return "A Vencer"
        case .overdue:
            return "Vencido"
        }
    }

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

                        Text("Extrato Financeiro")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 60)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentCyan))
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Button("Tentar Novamente") {
                            Task {
                                await viewModel.loadFinancialStatement()
                            }
                        }
                        .foregroundColor(AppColors.accentCyan)
                    }
                    .padding()
                    Spacer()
                } else {
                    VStack(spacing: 0) {
                        // Filtros horizontais
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.filterOptions, id: \.self) { filter in
                                    FilterChip(
                                        text: filter,
                                        isSelected: filter == viewModel.selectedFilterText
                                    ) {
                                        viewModel.setFilter(filter)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 16)
                        }

                        // Lista de parcelas
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.filteredItems) { item in
                                    ParcelaCard(item: item)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadFinancialStatement()
            }
        }
    }
}

struct FilterChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : AppColors.accentCyan)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? AppColors.accentCyan : AppColors.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.accentCyan, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

struct ParcelaCard: View {
    let item: FinancialStatementItem

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    private func statusColor(_ status: PaymentStatus) -> Color {
        switch status {
        case .paid:
            return .green
        case .upcoming:
            return .orange
        case .overdue:
            return .red
        }
    }

    private func statusText(_ status: PaymentStatus) -> String {
        switch status {
        case .paid:
            return "Pago"
        case .upcoming:
            return "A Vencer"
        case .overdue:
            return "Vencido"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.ventureName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("Parcela \(item.installmentNumber)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Vence em \(item.dueDate)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(item.amount))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(statusText(item.status))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor(item.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(statusColor(item.status).opacity(0.2))
                    )
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        ExtratoView()
    }
}