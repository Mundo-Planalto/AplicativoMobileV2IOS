//
//  FinancialSummaryCard.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct FinancialSummaryCard: View {
    let summary: FinancialSummary?

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Resumo Financeiro")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                // Vencidas
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vencidas")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(formatCurrency(summary?.overdueAmount ?? 0))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("\(summary?.overdueInstallments ?? 0) parcelas")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)

                // A Vencer
                VStack(alignment: .leading, spacing: 8) {
                    Text("A Vencer")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(formatCurrency(summary?.upcomingAmount ?? 0))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)

                // Total
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(formatCurrency(summary?.totalAmount ?? 0))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accentCyan)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }

            GradientButton(
                title: "Ver Extrato Completo",
                action: {
                    // TODO: Navegar para extrato completo
                }
            )
            .padding(.top, 8)
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    FinancialSummaryCard(summary: FinancialSummary(
        overdueAmount: 2500.50,
        upcomingAmount: 1800.75,
        overdueInstallments: 2,
        totalAmount: 15750.25
    ))
    .padding()
    .background(AppColors.backgroundPrimary)
}