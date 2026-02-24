//
//  InformeRendimentosDetailView.swift
//  Mundo planalto Portal App
//
//  Exibe o informe gerado. Dados vêm de InformeRendimentosData (por enquanto mock; depois do endpoint).
//

import SwiftUI
import UIKit

struct InformeRendimentosDetailView: View {
    let data: InformeRendimentosData
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var shareItem: Any? = nil
    @State private var showShareSheet = false
    @State private var showSaveAlert = false
    @State private var saveMessage = ""

    private var isDark: Bool { appState.isDarkTheme }
    private var bg: Color { AppColors.backgroundPrimary(dark: isDark) }
    private var cardBg: Color { AppColors.cardBackground(dark: isDark) }
    private var textP: Color { AppColors.textPrimary(dark: isDark) }
    private var textS: Color { AppColors.textSecondary(dark: isDark) }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    private func formatCPF(_ cpf: String) -> String {
        let digits = cpf.filter { $0.isNumber }
        guard digits.count == 11 else { return cpf }
        return "\(digits.prefix(3)).\(digits.dropFirst(3).prefix(3)).\(digits.dropFirst(6).prefix(3))-\(digits.suffix(2))"
    }

    private func informeAsText() -> String {
        var lines: [String] = []
        lines.append("INFORME DE RENDIMENTOS \(data.anoBase)")
        if let c = data.contribuinte {
            lines.append("Contribuinte: \(c.nome)")
            lines.append("CPF: \(formatCPF(c.cpf))")
            lines.append("Ano base: \(c.anoBase)")
        }
        if let r = data.resumo {
            lines.append("Total de pagamentos: \(r.totalPagamentos)")
            lines.append("Valor total: \(formatCurrency(r.valorTotalRendimentos))")
        }
        if let list = data.pagamentos, !list.isEmpty {
            lines.append("Detalhamento:")
            for p in list {
                lines.append("  \(p.data) - \(p.transacaoId) - \(formatCurrency(p.valor)) - \(p.empresa)")
            }
        }
        return lines.joined(separator: "\n")
    }

    private func shareInforme() {
        shareItem = informeAsText()
        showShareSheet = true
    }

    private func installPdf() {
        guard let pdfData = InformePDFGenerator.generatePDF(data: data) else {
            saveMessage = "Não foi possível gerar o PDF."
            showSaveAlert = true
            return
        }
        let fileName = "Informe_Rendimentos_\(data.anoBase).pdf"
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try pdfData.write(to: temp)
            shareItem = temp
            showShareSheet = true
        } catch {
            saveMessage = "Não foi possível salvar o PDF."
            showSaveAlert = true
        }
    }

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
                    Text("Informe de Rendimentos \(data.anoBase)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(textP)
                        .lineLimit(1)
                    Spacer()
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(bg)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let c = data.contribuinte {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Informações do Contribuinte")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(textP)
                                InformeDetailRow(label: "Nome", value: c.nome)
                                InformeDetailRow(label: "CPF", value: formatCPF(c.cpf))
                                InformeDetailRow(label: "Ano Base", value: c.anoBase)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(cardBg)
                            .cornerRadius(12)
                        }

                        if let r = data.resumo {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Resumo dos Rendimentos")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(textP)
                                HStack {
                                    Text("Total de pagamentos:")
                                        .foregroundColor(textS)
                                    Spacer()
                                    Text("\(r.totalPagamentos)")
                                        .fontWeight(.medium)
                                        .foregroundColor(textP)
                                }
                                HStack {
                                    Text("Valor total dos rendimentos:")
                                        .foregroundColor(textS)
                                    Spacer()
                                    Text(formatCurrency(r.valorTotalRendimentos))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.accentBlue)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(cardBg)
                            .cornerRadius(12)
                        }

                        if let list = data.pagamentos, !list.isEmpty {
                            Text("Detalhamento dos Pagamentos")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(textP)

                            ForEach(list) { p in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(p.data)
                                            .font(.subheadline)
                                            .foregroundColor(textS)
                                        Spacer()
                                        Text(formatCurrency(p.valor))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppColors.accentBlue)
                                    }
                                    Text(p.transacaoId)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(textP)
                                    Text(p.empresa)
                                        .font(.caption)
                                        .foregroundColor(textS)
                                    HStack {
                                        Text("Método:")
                                            .font(.caption)
                                            .foregroundColor(textS)
                                        Spacer()
                                        Text(p.metodo)
                                            .font(.caption)
                                            .foregroundColor(textP)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(cardBg.opacity(0.9))
                                .cornerRadius(12)
                            }
                        }

                        HStack(spacing: 12) {
                            Button {
                                shareInforme()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Compartilhar")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.accentBlue)
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Button {
                                installPdf()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.down.doc.fill")
                                    Text("Instalar PDF")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.accentBlue)
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: (shareItem as? String).map { [$0 as Any] } ?? (shareItem as? URL).map { [$0 as Any] } ?? [])
        }
        .alert("Informe", isPresented: $showSaveAlert) {
            Button("OK") { saveMessage = "" }
        } message: {
            Text(saveMessage)
        }
    }
}

private struct InformeDetailRow: View {
    let label: String
    let value: String
    var isDark: Bool = true

    private var textP: Color { AppColors.textPrimary(dark: isDark) }

    var body: some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary(dark: isDark))
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(textP)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        InformeRendimentosDetailView(
            data: InformeRendimentosData(
                anoBase: "2025",
                contribuinte: InformeContribuinte(nome: "Nome", cpf: "12345678900", anoBase: "2025"),
                resumo: InformeResumo(totalPagamentos: 24, valorTotalRendimentos: 44955.12),
                pagamentos: [],
                pdfUrl: nil
            )
        )
        .environmentObject(AppState.shared)
    }
}
