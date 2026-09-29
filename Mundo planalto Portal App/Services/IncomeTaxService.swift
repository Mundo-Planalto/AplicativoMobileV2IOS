//
//  IncomeTaxService.swift
//  Mundo planalto Portal App
//
//  GET /api/incometax/years, POST /api/incometax/generate/{year}
//

import Foundation

struct IncomeTaxYearDto: Codable {
    let year: Int
}

struct IncomeTaxPaymentDto: Codable {
    let date: String?
    let paymentDate: String?
    let paidAt: String?
    let paidDate: String?
    let dataPagamento: String?
    let paymentDatetime: String?
    let description: String?
    let contractNumber: String?
    let installmentNumber: String?
    let enterpriseName: String?
    let enterprise: String?
    let ventureName: String?
    let projectName: String?
    let value: Double
    let paymentMethod: String?

    private struct RawKey: CodingKey {
        let stringValue: String
        let intValue: Int? = nil
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: RawKey.self)
        func decodeString(_ keys: [String]) -> String? {
            for key in keys {
                guard let k = RawKey(stringValue: key) else { continue }
                if let v = try? c.decodeIfPresent(String.self, forKey: k), !v.isEmpty { return v }
            }
            return nil
        }
        func decodeDouble(_ keys: [String]) -> Double {
            for key in keys {
                guard let k = RawKey(stringValue: key) else { continue }
                if let v = try? c.decodeIfPresent(Double.self, forKey: k) { return v }
                if let v = try? c.decodeIfPresent(Int.self, forKey: k) { return Double(v) }
                if let s = try? c.decodeIfPresent(String.self, forKey: k), let v = Double(s) { return v }
            }
            return 0
        }

        // Referência / vencimento (não usar como data de pagamento). `data` genérico só por último — senão pode mascarar baixa.
        self.date = decodeString([
            "dueDate", "due_date",
            "referenceDate", "reference_date",
            "dataVencimento", "data_vencimento",
            "vencimento",
            "installmentDueDate", "installment_due_date",
            "date",
            "data"
        ])
        // Baixa / pagamento: mesma prioridade usada na montagem do informe.
        let mergedPayment = decodeString([
            "paidDate", "paid_date",
            "paidAt", "paid_at",
            "paymentDate", "payment_date",
            "dataPagamento", "data_pagamento",
            "dataBaixa", "data_baixa",
            "paymentDatetime", "paymentDateTime", "payment_datetime",
            "baixaDate", "baixa_date",
            "settlementDate", "settlement_date",
            "settledAt", "settled_at"
        ])
        self.paidDate = mergedPayment
        self.paymentDate = decodeString(["paymentDate", "payment_date"]) ?? mergedPayment
        self.paidAt = decodeString(["paidAt", "paid_at"]) ?? mergedPayment
        self.dataPagamento = decodeString(["dataPagamento", "data_pagamento"]) ?? mergedPayment
        self.paymentDatetime = decodeString(["paymentDatetime", "paymentDateTime", "payment_datetime"]) ?? mergedPayment
        self.description = decodeString(["description", "descricao"])
        self.contractNumber = decodeString(["contractNumber", "contract_number"])
        self.installmentNumber = decodeString(["installmentNumber", "installment_number"])
        self.enterpriseName = decodeString(["enterpriseName", "enterprise_name"])
        self.enterprise = decodeString(["enterprise", "empreendimento"])
        self.ventureName = decodeString(["ventureName", "venture_name"])
        self.projectName = decodeString(["projectName", "project_name"])
        self.value = decodeDouble(["value", "amount", "valor"])
        self.paymentMethod = decodeString(["paymentMethod", "payment_method", "metodoPagamento"])
    }
}

struct IncomeTaxReportDto: Codable {
    let customerName: String
    let document: String
    let year: Int
    let generatedAt: String?
    let totalPaid: Double
    let payments: [IncomeTaxPaymentDto]?
}

enum IncomeTaxError: Error {
    case networkError
    case invalidResponse
    case noData
}

class IncomeTaxService {
    static let shared = IncomeTaxService()
    private init() {}

    private var baseURL: String { ApiConfig.baseURL + "/" }

    /// Data de pagamento para exibição: só campos de baixa/pagamento — **nunca** `date`/vencimento.
    private static func displayPaymentDate(from p: IncomeTaxPaymentDto) -> String? {
        let raw = [
            p.paidDate,
            p.paymentDate,
            p.paidAt,
            p.dataPagamento,
            p.paymentDatetime
        ]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
        guard let raw else { return nil }
        let formatted = DateDisplayFormatter.toPtBRDate(raw)
        if formatted != "-", !formatted.isEmpty { return formatted }
        return raw.isEmpty ? nil : raw
    }

    private static func displayReferenceDate(from p: IncomeTaxPaymentDto) -> String {
        let raw = (p.date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return "" }
        let formatted = DateDisplayFormatter.toPtBRDate(raw)
        if formatted != "-", !formatted.isEmpty { return formatted }
        return raw
    }

    private static func normalizeContractKey(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
    }

    private static func installmentsLikelyEqual(_ a: String, _ b: String) -> Bool {
        let x = normalizeContractKey(a)
        let y = normalizeContractKey(b)
        if x.isEmpty || y.isEmpty { return false }
        if x == y { return true }
        if y.hasPrefix(x + "/") || x.hasPrefix(y + "/") { return true }
        let fx = x.split(separator: "/").first.map(String.init) ?? x
        let fy = y.split(separator: "/").first.map(String.init) ?? y
        return fx == fy
    }

    private static func amountsClose(_ a: Double, _ b: Double) -> Bool {
        if a == b { return true }
        let diff = abs(a - b)
        return diff < 0.02 || diff < max(abs(a), abs(b), 1) * 0.001
    }

    /// Exibe `FinancialStatementItem.paymentDate` (mapeado do `paidDate` do GET extrato).
    private static func displayPaymentDateFromExtratoItem(_ item: FinancialStatementItem) -> String? {
        guard let raw = item.paymentDate?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        let formatted = DateDisplayFormatter.toPtBRDate(raw)
        if formatted != "-", !formatted.isEmpty { return formatted }
        return raw
    }

    /// Cruza informe com `/api/financial/extrato`: usa `paidDate` já normalizado em `paymentDate` da parcela.
    private static func paymentDateFromExtrato(
        contractNumber: String,
        installmentNumber: String,
        referenceDueDisplay: String,
        value: Double,
        ventureNameHint: String,
        items: [FinancialStatementItem]
    ) -> String? {
        let cWant = normalizeContractKey(contractNumber)
        let iWant = normalizeContractKey(installmentNumber)
        let refWant = referenceDueDisplay.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let refFmtWant = DateDisplayFormatter.toPtBRDate(referenceDueDisplay)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let ventHint = ventureNameHint.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let candidates = items.filter { item in
            guard let pd = item.paymentDate?.trimmingCharacters(in: .whitespacesAndNewlines), !pd.isEmpty else { return false }
            return true
        }

        func scoreMatch(_ item: FinancialStatementItem) -> Int {
            var score = 0
            let ic = normalizeContractKey(item.contractNumber ?? "")
            if !cWant.isEmpty, !ic.isEmpty {
                if ic == cWant {
                    score += 5
                } else if ic.contains(cWant) || cWant.contains(ic) {
                    score += 3
                }
            }
            if !iWant.isEmpty {
                if installmentsLikelyEqual(iWant, item.installmentNumber) || installmentsLikelyEqual(iWant, item.parcela) {
                    score += 5
                }
            }
            if !ventHint.isEmpty {
                let iv = item.ventureName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if !iv.isEmpty, iv == ventHint || iv.contains(ventHint) || ventHint.contains(iv) {
                    score += 3
                }
            }
            if amountsClose(item.amount, value) { score += 2 }
            if !refWant.isEmpty {
                let due = item.dueDate.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let dueFmt = DateDisplayFormatter.toPtBRDate(item.dueDate)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()
                if due == refWant || dueFmt == refWant || due == refFmtWant || dueFmt == refFmtWant {
                    score += 2
                }
            }
            return score
        }

        let ranked = candidates.map { (item: $0, score: scoreMatch($0)) }.filter { $0.score > 0 }.sorted { $0.score > $1.score }

        if let best = ranked.first, best.score >= 5 {
            return displayPaymentDateFromExtratoItem(best.item)
        }
        if let best = ranked.first, best.score >= 4 {
            return displayPaymentDateFromExtratoItem(best.item)
        }
        if let best = ranked.first, best.score >= 3 {
            return displayPaymentDateFromExtratoItem(best.item)
        }

        return nil
    }

    private func createAuthorizedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// GET /api/incometax/years
    func getAvailableYears() async throws -> [Int] {
        guard let url = URL(string: baseURL + "incometax/years") else { throw IncomeTaxError.networkError }
        var request = createAuthorizedRequest(url: url)
        var (data, response) = try await URLSession.shared.data(for: request)
        if (response as? HTTPURLResponse)?.statusCode == 401 {
            let recovered = await AuthService.shared.recoverSessionIfNeeded()
            guard recovered else { throw IncomeTaxError.invalidResponse }
            request = createAuthorizedRequest(url: url)
            let retry = try await URLSession.shared.data(for: request)
            data = retry.0
            response = retry.1
        }
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw IncomeTaxError.invalidResponse }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let decoded = try? decoder.decode(ApiResponse<[IncomeTaxYearDto]>.self, from: data),
           let arr = decoded.data,
           !arr.isEmpty {
            return arr.map(\.year)
        }
        let flexible = Self.parseYearsFromFlexibleJSON(data)
        if !flexible.isEmpty {
            return flexible
        }
        throw IncomeTaxError.invalidResponse
    }

    /// Aceita vários formatos de payload (`data: [2024]`, `data: [{year, ano}]`, `years`, etc.).
    private static func parseYearsFromFlexibleJSON(_ data: Data) -> [Int] {
        guard let json = try? JSONSerialization.jsonObject(with: data) else { return [] }

        func ints(from value: Any?) -> [Int] {
            guard let value else { return [] }
            if let arr = value as? [Int] { return arr }
            if let arr = value as? [NSNumber] { return arr.map { $0.intValue } }
            if let arr = value as? [Double] { return arr.map { Int($0) } }
            if let arr = value as? [[String: Any]] {
                var out: [Int] = []
                for dict in arr {
                    let candidates: [Any?] = [
                        dict["year"], dict["Year"], dict["ano"], dict["Ano"], dict["calendarYear"], dict["baseYear"]
                    ]
                    for c in candidates {
                        if let y = c as? Int { out.append(y); continue }
                        if let y = c as? Double { out.append(Int(y)); continue }
                        if let s = c as? String, let y = Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) {
                            out.append(y)
                        }
                    }
                }
                return out
            }
            if let arr = value as? [String] {
                return arr.compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
            }
            return []
        }

        if let root = json as? [String: Any] {
            if let dataObj = root["data"] {
                let direct = ints(from: dataObj)
                if !direct.isEmpty { return direct }
                if let inner = dataObj as? [String: Any] {
                    for key in ["years", "anos", "availableYears", "yearList", "items"] {
                        if let v = inner[key] {
                            let got = ints(from: v)
                            if !got.isEmpty { return got }
                        }
                    }
                }
            }
            for key in ["years", "anos", "availableYears"] {
                if let v = root[key] {
                    let got = ints(from: v)
                    if !got.isEmpty { return got }
                }
            }
        }
        if let arr = json as? [Int] { return arr }
        if let arr = json as? [NSNumber] { return arr.map { $0.intValue } }
        return []
    }

    /// POST /api/incometax/generate/{year} -> mapeia para InformeRendimentosData
    func generateReport(year: Int) async throws -> InformeRendimentosData {
        guard let url = URL(string: baseURL + "incometax/generate/\(year)") else { throw IncomeTaxError.networkError }
        var request = createAuthorizedRequest(url: url, method: "POST")
        request.httpBody = "{}".data(using: .utf8)
        var (data, response) = try await URLSession.shared.data(for: request)
        if (response as? HTTPURLResponse)?.statusCode == 401 {
            let recovered = await AuthService.shared.recoverSessionIfNeeded()
            guard recovered else { throw IncomeTaxError.invalidResponse }
            request = createAuthorizedRequest(url: url, method: "POST")
            request.httpBody = "{}".data(using: .utf8)
            let retry = try await URLSession.shared.data(for: request)
            data = retry.0
            response = retry.1
        }
        let http = response as? HTTPURLResponse
        if http?.statusCode == 404 {
            throw IncomeTaxError.noData
        }
        guard http?.statusCode == 200 else { throw IncomeTaxError.invalidResponse }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(ApiResponse<IncomeTaxReportDto>.self, from: data)
        guard let report = decoded.data else { throw IncomeTaxError.noData }
        let safeName = report.customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? (PreferencesManager.shared.getUserName() ?? "")
            : report.customerName
        let safeDocument = report.document.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? (PreferencesManager.shared.getUserCpfCnpj() ?? "")
            : report.document
        let contribuinte = InformeContribuinte(
            nome: safeName,
            cpf: safeDocument,
            anoBase: "\(report.year)"
        )
        let resumo = InformeResumo(
            totalPagamentos: report.payments?.count ?? 0,
            valorTotalRendimentos: report.totalPaid
        )

        let extratoItems = (try? await ExtratoService.shared.getExtrato(
            showPaid: true,
            showOverdue: true,
            showDue: true,
            useCache: true,
            forceRefresh: false
        )) ?? []

        let pagamentos: [InformePagamento]? = report.payments?.enumerated().compactMap { index, p in
            let safeDate = Self.displayReferenceDate(from: p)
            var paymentDisplay = Self.displayPaymentDate(from: p)
            let payRawForId = [
                p.paidDate,
                p.paymentDate,
                p.paidAt,
                p.dataPagamento,
                p.paymentDatetime
            ]
                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first { !$0.isEmpty } ?? ""
            let safeContract = p.contractNumber?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let safeInstallment = p.installmentNumber?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let rawDescription = p.description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let referencia: String = {
                if !rawDescription.isEmpty { return rawDescription }
                if !safeContract.isEmpty || !safeInstallment.isEmpty {
                    let contrato = safeContract.isEmpty ? "-" : safeContract
                    let parcela = safeInstallment.isEmpty ? "-" : safeInstallment
                    return "Contrato \(contrato) - Parcela \(parcela)"
                }
                return "Pagamento \(index + 1)"
            }()
            let enterpriseCandidates = [
                p.enterpriseName,
                p.enterprise,
                p.ventureName,
                p.projectName
            ]
            let empreendimento = enterpriseCandidates
                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first(where: { !$0.isEmpty }) ?? "Empreendimento não informado"
            let ventureHintForExtrato = empreendimento == "Empreendimento não informado" ? "" : empreendimento

            let paymentTrimmed = paymentDisplay?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if paymentTrimmed.isEmpty {
                paymentDisplay = Self.paymentDateFromExtrato(
                    contractNumber: safeContract,
                    installmentNumber: safeInstallment,
                    referenceDueDisplay: safeDate,
                    value: p.value,
                    ventureNameHint: ventureHintForExtrato,
                    items: extratoItems
                )
            }

            return InformePagamento(
                id: "payment-\(index)-\(safeDate)-\(payRawForId)-\(p.value)",
                data: safeDate.isEmpty ? ((p.date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)) : safeDate,
                dataPagamento: paymentDisplay,
                valor: p.value,
                transacaoId: referencia,
                empresa: empreendimento,
                metodo: p.paymentMethod ?? "Boleto"
            )
        }
        return InformeRendimentosData(
            anoBase: "\(report.year)",
            contribuinte: contribuinte,
            resumo: resumo,
            pagamentos: pagamentos,
            pdfUrl: nil
        )
    }
}
