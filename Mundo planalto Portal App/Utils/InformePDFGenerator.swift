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

            drawTitle("INFORME DE RENDIMENTOS \(data.anoBase)", ctx: context)
            drawLine("", ctx: context)

            if let c = data.contribuinte {
                drawTitle("Informações do Contribuinte", ctx: context)
                drawLine("Nome: \(c.nome)", ctx: context)
                drawLine("CPF: \(formatCPF(c.cpf))", ctx: context)
                drawLine("Ano Base: \(c.anoBase)", ctx: context)
                drawLine("", ctx: context)
            }

            if let r = data.resumo {
                drawTitle("Resumo dos Rendimentos", ctx: context)
                drawLine("Total de pagamentos: \(r.totalPagamentos)", ctx: context)
                drawLine("Valor total dos rendimentos: \(formatCurrency(r.valorTotalRendimentos))", ctx: context)
                drawLine("", ctx: context)
            }

            if let list = data.pagamentos, !list.isEmpty {
                drawTitle("Detalhamento dos Pagamentos", ctx: context)
                for p in list {
                    drawLine("\(p.data) - \(p.transacaoId) - \(formatCurrency(p.valor))", ctx: context)
                    drawLine("  \(p.empresa) - \(p.metodo)", ctx: context)
                }
            }
        }

        return pdfData
    }
}
