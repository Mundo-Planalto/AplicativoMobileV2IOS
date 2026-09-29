//
//  InformePDFGenerator.swift
//  Mundo planalto Portal App
//
//  Gera PDF do informe de rendimentos com os dados exibidos na tela.
//

import UIKit

enum InformePDFGenerator {
    private static func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    private static func formatCPF(_ cpf: String) -> String {
        let digits = cpf.filter { $0.isNumber }
        guard digits.count == 11 else { return cpf }
        return "\(digits.prefix(3)).\(digits.dropFirst(3).prefix(3)).\(digits.dropFirst(6).prefix(3))-\(digits.suffix(2))"
    }

    private static func formatDate(_ value: String?) -> String {
        DateDisplayFormatter.toPtBRDate(value)
    }

    private static func formatPaymentDate(_ value: String?) -> String {
        guard let v = value?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty else {
            return "Não informada"
        }
        let d = DateDisplayFormatter.toPtBRDate(v)
        return (d == "-" || d.isEmpty) ? v : d
    }

    private static func fallbackName(from data: InformeRendimentosData) -> String {
        let fromData = data.contribuinte?.nome.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !fromData.isEmpty { return fromData }
        let fromPrefs = PreferencesManager.shared.getUserName()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return fromPrefs.isEmpty ? "Não informado" : fromPrefs
    }

    private static func fallbackCpf(from data: InformeRendimentosData) -> String {
        let fromData = data.contribuinte?.cpf.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !fromData.isEmpty { return fromData }
        let fromPrefs = PreferencesManager.shared.getUserCpfCnpj()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return fromPrefs.isEmpty ? "Não informado" : fromPrefs
    }

    private static func fallbackAnoBase(from data: InformeRendimentosData) -> String {
        let fromContrib = data.contribuinte?.anoBase.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !fromContrib.isEmpty { return fromContrib }
        let fromData = data.anoBase.trimmingCharacters(in: .whitespacesAndNewlines)
        return fromData.isEmpty ? "Não informado" : fromData
    }

    /// Gera Data do PDF a partir dos dados do informe (mesmo conteúdo da tela).
    static func generatePDF(data: InformeRendimentosData) -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let lineHeight: CGFloat = 22
        let titleFontSize: CGFloat = 18
        let bodyFontSize: CGFloat = 12

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        var y: CGFloat = margin
        var currentPage = 0

        func nextPage(_ ctx: UIGraphicsPDFRendererContext) {
            ctx.beginPage()
            currentPage += 1
            y = margin
        }

        func drawTitle(_ text: String, ctx: UIGraphicsPDFRendererContext) {
            let font = UIFont.boldSystemFont(ofSize: titleFontSize)
            let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
            let rect = CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: lineHeight * 2)
            (text as NSString).draw(in: rect, withAttributes: attrs)
            y += lineHeight * 1.5
        }

        func drawLine(_ text: String, ctx: UIGraphicsPDFRendererContext) {
            if y > pageHeight - margin - lineHeight {
                nextPage(ctx)
            }
            let font = UIFont.systemFont(ofSize: bodyFontSize)
            let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.darkGray]
            let rect = CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: lineHeight * 1.2)
            (text as NSString).draw(in: rect, withAttributes: attrs)
            y += lineHeight
        }

        let pdfData = renderer.pdfData { context in
            nextPage(context)

            let nome = fallbackName(from: data)
            let cpf = fallbackCpf(from: data)
            let anoBase = fallbackAnoBase(from: data)

            drawTitle("INFORME DE RENDIMENTOS \(anoBase)", ctx: context)
            drawLine("", ctx: context)

            drawTitle("Informações do Contribuinte", ctx: context)
            drawLine("Nome: \(nome)", ctx: context)
            drawLine("CPF: \(formatCPF(cpf))", ctx: context)
            drawLine("Ano Base: \(anoBase)", ctx: context)
            drawLine("", ctx: context)

            if let r = data.resumo {
                drawTitle("Resumo dos Rendimentos", ctx: context)
                drawLine("Total de pagamentos: \(r.totalPagamentos)", ctx: context)
                drawLine("Valor total dos rendimentos: \(formatCurrency(r.valorTotalRendimentos))", ctx: context)
                drawLine("", ctx: context)
            }

            if let list = data.pagamentos, !list.isEmpty {
                drawTitle("Detalhamento dos Pagamentos", ctx: context)
                for p in list {
                    drawLine("Data de pagamento: \(formatPaymentDate(p.dataPagamento))", ctx: context)
                    drawLine("Data de referência: \(formatDate(p.data))", ctx: context)
                    drawLine("\(p.transacaoId) - \(formatCurrency(p.valor))", ctx: context)
                    drawLine("  \(p.empresa) - \(p.metodo)", ctx: context)
                }
            }
        }

        return pdfData
    }
}
