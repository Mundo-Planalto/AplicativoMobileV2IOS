//
//  FinancialOverviewCard.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct FinancialOverviewCard: View {
    let summary: FinancialSummary?

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumo Financeiro")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                // Dívidas vencidas
                FinancialItemView(
                    title: "Dívidas Vencidas",
                    value: summary?.overdueAmount ?? 0,
                    subtitle: "\(summary?.overdueInstallments ?? 0) parcelas atrasadas",
                    color: .red
                )

                // Dívidas a vencer
                FinancialItemView(
                    title: "Dívidas a Vencer",
                    value: summary?.upcomingAmount ?? 0,
                    subtitle: "Próximas parcelas",
                    color: .orange
                )

                // Próximo vencimento
                VStack(alignment: .leading, spacing: 4) {
                    Text("Próximo Vencimento")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("15/02/2025")
                        .font(.headline)
                        .foregroundColor(AppColors.accentCyan)
                    Text("R$ 1.250,00")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)

                // Botão Ver Extrato
                Button(action: {
                    // Navegação será tratada pelo DashboardView
                    NotificationCenter.default.post(name: NSNotification.Name("SwitchToFinancial"), object: nil)
                }) {
                    Text("Ver Extrato")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.accentBlue, AppColors.accentCyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: AppColors.accentBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct FinancialItemView: View {
    let title: String
    let value: Double
    let subtitle: String
    let color: Color

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(color.opacity(0.8))
            }

            Spacer()

            Text(formatCurrency(value))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(AppColors.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    FinancialOverviewCard(summary: FinancialSummary(
        overdueAmount: 2500.50,
        upcomingAmount: 1800.75,
        overdueInstallments: 2,
        totalAmount: 15750.25
    ))
    .padding()
    .background(AppColors.backgroundPrimary)
}