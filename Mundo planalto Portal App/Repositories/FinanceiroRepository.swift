//
//  FinanceiroRepository.swift
//  Hard Rock Hotel & Vacation Club
//
//  Resumo financeiro e empreendimento principal para a Início e a tela Financeiro.
//  Mock: valores de docs/telas.md. Remote: API existente do portal
//  (financial/resumo, financial/extrato, ventures) via serviços já usados pelo app.
//

import Foundation

protocol FinanceiroRepository {
    /// `venture` filtra o resumo por empreendimento (aberto pela página do empreendimento).
    func resumo(forceRefresh: Bool, venture: Venture?) async throws -> FinanceiroResumo
}

extension FinanceiroRepository {
    func resumo(forceRefresh: Bool) async throws -> FinanceiroResumo {
        try await resumo(forceRefresh: forceRefresh, venture: nil)
    }
}

// MARK: - Mock (docs/telas.md)

final class FinanceiroRepositoryMock: FinanceiroRepository {
    static let shared = FinanceiroRepositoryMock()

    static let imagemGramado = "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800"

    func resumo(forceRefresh: Bool, venture: Venture?) async throws -> FinanceiroResumo {
        FinanceiroResumo(
            empreendimentoNome: "Hard Rock Hotel Gramado",
            empreendimentoLocal: "Gramado • RS",
            empreendimentoImagem: Self.imagemGramado,
            situacao: "Em dia",
            situacaoEmDia: true,
            proximoVencimento: "15 OUT 2026",
            proximoValor: "R$ 2.480,00",
            saldoContrato: "R$ 172.480,00",
            parcelasPagas: "28 de 48",
            parcelasRestantes: "20 de 48",
            proximasParcelas: [
                ParcelaResumo(id: "1", vencimento: "15 OUT 2026", valor: "R$ 2.480,00", status: .aVencer),
                ParcelaResumo(id: "2", vencimento: "15 NOV 2026", valor: "R$ 2.480,00", status: .aVencer),
                ParcelaResumo(id: "3", vencimento: "15 DEZ 2026", valor: "R$ 2.480,00", status: .aVencer)
            ]
        )
    }
}

// MARK: - Remote (API do portal já existente)

final class FinanceiroRepositoryRemote: FinanceiroRepository {
    func resumo(forceRefresh: Bool, venture selected: Venture?) async throws -> FinanceiroResumo {
        async let summaryTask = ExtratoService.shared.getFinancialSummary(useCache: !forceRefresh, forceRefresh: forceRefresh)
        async let itemsTask = ExtratoService.shared.getExtrato(showPaid: true, showOverdue: true, showDue: true, useCache: !forceRefresh, forceRefresh: false)
        let firstVenture = try? await EmpreendimentosService.shared.getEmpreendimentos().empreendimentos.first
        let venture = selected ?? firstVenture

        let summary = try await summaryTask
        var items = (try? await itemsTask) ?? []
        // GET ventures/{id}/financial ainda não existe: com empreendimento escolhido, filtra o
        // extrato pelo nome (docs/PENDENCIAS.md). O valor do próximo vencimento segue o resumo geral.
        if let selected {
            let nome = selected.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let filtrados = items.filter { $0.ventureName.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare(nome) == .orderedSame }
            if !filtrados.isEmpty { items = filtrados }
        }

        let pagas = items.filter { $0.status == .paid }.count
        let total = items.count
        let saldo = items.filter { $0.status != .paid }.reduce(0.0) { $0 + $1.amount }
        let emDia = summary.overdueAmount <= 0 && summary.overdueInstallments == 0

        let proximas = items
            .filter { $0.status != .paid }
            .sorted { (HrFormat.parseDate($0.dueDate) ?? .distantFuture) < (HrFormat.parseDate($1.dueDate) ?? .distantFuture) }
            .prefix(3)
            .map { item in
                ParcelaResumo(
                    id: item.id,
                    vencimento: HrFormat.shortDate(item.dueDate),
                    valor: HrFormat.currency(item.amount),
                    status: item.status == .overdue ? .vencida : .aVencer
                )
            }

        return FinanceiroResumo(
            empreendimentoNome: venture?.name ?? (items.first?.ventureName ?? "Meu empreendimento"),
            empreendimentoLocal: venture?.localTexto ?? "",
            empreendimentoImagem: venture?.imageUrl.hasPrefix("http") == true ? venture?.imageUrl : nil,
            situacao: emDia ? "Em dia" : "Em atraso",
            situacaoEmDia: emDia,
            proximoVencimento: summary.nextDueDate.map { HrFormat.shortDate($0) } ?? "-",
            proximoValor: HrFormat.currency(summary.nextDueValue),
            saldoContrato: HrFormat.currency(saldo),
            parcelasPagas: total > 0 ? "\(pagas) de \(total)" : "-",
            parcelasRestantes: total > 0 ? "\(total - pagas) de \(total)" : "-",
            proximasParcelas: Array(proximas)
        )
    }
}
