//
//  FinancialOverviewCard.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

struct FinancialOverviewCard: View {
    let summary: FinancialSummary?
    var isDark: Bool = true
    var onVerExtrato: (() -> Void)? = nil
    
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
                .foregroundColor(AppColors.textPrimary(dark: isDark))
            
            VStack(spacing: 12) {
                FinancialItemView(
                    title: "Dívidas Vencidas",
                    value: summary?.overdueAmount ?? 0,
                    subtitle: nil,
                    color: .red,
                    isDark: isDark
                )
                
                FinancialItemView(
                    title: "A Vencer",
                    value: summary?.upcomingAmount ?? 0,
                    subtitle: nil,
                    color: Color(hex: "#E68A00"),
                    isDark: isDark
                )
                
                HStack {
                    Text("Parcelas Atrasadas")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary(dark: isDark))
                    Spacer()
                    Text("\(summary?.overdueInstallments ?? 0) parcelas")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary(dark: isDark))
                }
                .padding()
                .background(AppColors.cardBackground(dark: isDark).opacity(0.6))
                .cornerRadius(12)
                
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Próximo Vencimento")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary(dark: isDark))
                        Text(summary?.nextDueDate ?? "-")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.accentBlue)
                    }
                    Spacer(minLength: 8)
                    Text(formatCurrency(summary?.nextDueValue ?? 0))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary(dark: isDark))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.cardBackground(dark: isDark).opacity(0.6))
                .cornerRadius(12)

                Button(action: {
                    onVerExtrato?()
                }) {
                    Text("Segunda Via de Boleto")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.accentBlue)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(AppColors.cardBackground(dark: isDark))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    struct FinancialItemView: View {
        let title: String
        let value: Double
        let subtitle: String?
        let color: Color
        var isDark: Bool = true
        
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
                        .foregroundColor(AppColors.textSecondary(dark: isDark))
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(color.opacity(0.8))
                    }
                }
                
                Spacer()
                
                Text(formatCurrency(value))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            .padding()
            .background(AppColors.cardBackground(dark: isDark).opacity(0.6))
            .cornerRadius(12)
        }
    }
}
    #Preview {
        FinancialOverviewCard(summary: FinancialSummary(
            overdueAmount: 2500.50,
            upcomingAmount: 1800.75,
            overdueInstallments: 2,
            totalAmount: 15750.25,
            nextDueDate: "15/02/2025",
            nextDueValue: 1250.00
        ))
        .padding()
        .background(AppColors.backgroundPrimary)
    }
    
    

