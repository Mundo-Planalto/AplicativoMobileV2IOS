//
//  ExtratoService.swift
//  Mundo planalto Portal App
//
//  Responsável por consumir /api/financial/extrato e dados de boleto,
//  além de montar o resumo financeiro usado no dashboard.
//

import Foundation

enum ExtratoError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}

/// Item do extrato retornado por GET /api/financial/extrato
/// Decodificação tolerante a nomes alternativos de campo e timestamps numéricos (para datas).
struct ExtratoItemDto: Codable {
    let billReceivableId: Int?
    let installmentId: Int?
    let installmentNumber: String?
    let contractNumber: String?
    let enterpriseName: String?
    let dueDate: String?
    let paymentDate: String?
    let paidAt: String?
    let paidDate: String?
    let originalValue: Double?
    let currentBalance: Double?
    let latePaymentInterest: Double?
    let isPaid: Bool?
    let isOverdue: Bool?
    let generatedBillet: Bool?
    let billetStatusKnown: Bool?
    let isEsolution: Bool?
    let esolutionBoletoId: Int?

    private struct DynamicKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int? { nil }
        init?(intValue: Int) { return nil }
    }

    private enum CodingKeys: String, CodingKey {
        case billReceivableId, installmentId, installmentNumber, contractNumber, enterpriseName
        case dueDate, paymentDate, paidAt, paidDate
        case originalValue, currentBalance, latePaymentInterest
        case isPaid, isOverdue, generatedBillet, billetStatusKnown
        case isEsolution, esolutionBoletoId
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let dyn = try decoder.container(keyedBy: DynamicKey.self)

        billReceivableId = ExtratoItemDto.decodeInt(c: c, dyn: dyn, key: .billReceivableId, alt: ["billReceivableId", "bill_receivable_id", "billReceivableID"])
        installmentId = ExtratoItemDto.decodeInt(c: c, dyn: dyn, key: .installmentId, alt: ["installmentId", "installment_id", "installmentID"])
        installmentNumber = ExtratoItemDto.decodeString(c: c, dyn: dyn, key: .installmentNumber, alt: ["installmentNumber", "installment_number", "parcela", "installment"])
        contractNumber = ExtratoItemDto.decodeString(c: c, dyn: dyn, key: .contractNumber, alt: ["contractNumber", "contract_number", "contrato"])
        enterpriseName = ExtratoItemDto.decodeString(c: c, dyn: dyn, key: .enterpriseName, alt: ["enterpriseName", "enterprise_name", "empreendimento", "ventureName", "venture_name"])

        dueDate = ExtratoItemDto.decodeDateLike(
            c: c,
            dyn: dyn,
            key: .dueDate,
            alt: ["dueDate", "due_date", "dataVencimento", "data_vencimento", "vencimento", "expirationDate", "expiration_date", "expireDate"]
        )
        let payMerged = ExtratoItemDto.decodeDateLike(
            c: c,
            dyn: dyn,
            key: .paymentDate,
            alt: [
                "paymentDate", "payment_date",
                "paidDate", "paid_date",
                "dataPagamento", "data_pagamento",
                "paymentDatetime", "payment_datetime", "paymentDateTime",
                "dataBaixa", "data_baixa", "baixa"
            ]
        )
        paymentDate = payMerged
        paidAt = ExtratoItemDto.decodeString(c: c, dyn: dyn, key: .paidAt, alt: ["paidAt", "paid_at"]) ?? payMerged
        paidDate = ExtratoItemDto.decodeString(c: c, dyn: dyn, key: .paidDate, alt: ["paidDate", "paid_date"]) ?? payMerged

        originalValue = ExtratoItemDto.decodeDouble(c: c, dyn: dyn, key: .originalValue, alt: ["originalValue", "original_value", "valorOriginal", "valor_original"])
        currentBalance = ExtratoItemDto.decodeDouble(c: c, dyn: dyn, key: .currentBalance, alt: ["currentBalance", "current_balance", "saldo", "valor"])
        latePaymentInterest = ExtratoItemDto.decodeDouble(c: c, dyn: dyn, key: .latePaymentInterest, alt: ["latePaymentInterest", "late_payment_interest", "juros"])

        isPaid = ExtratoItemDto.decodeBool(c: c, dyn: dyn, key: .isPaid, alt: ["isPaid", "is_paid", "paid", "pago"])
        isOverdue = ExtratoItemDto.decodeBool(c: c, dyn: dyn, key: .isOverdue, alt: ["isOverdue", "is_overdue", "overdue"])
        generatedBillet = ExtratoItemDto.decodeBool(c: c, dyn: dyn, key: .generatedBillet, alt: ["generatedBillet", "generated_billet"])
        billetStatusKnown = ExtratoItemDto.decodeBool(c: c, dyn: dyn, key: .billetStatusKnown, alt: ["billetStatusKnown", "billet_status_known"])
        isEsolution = ExtratoItemDto.decodeBool(c: c, dyn: dyn, key: .isEsolution, alt: ["isEsolution", "is_esolution"])
        esolutionBoletoId = ExtratoItemDto.decodeInt(c: c, dyn: dyn, key: .esolutionBoletoId, alt: ["esolutionBoletoId", "esolution_boleto_id"])
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(billReceivableId, forKey: .billReceivableId)
        try c.encodeIfPresent(installmentId, forKey: .installmentId)
        try c.encodeIfPresent(installmentNumber, forKey: .installmentNumber)
        try c.encodeIfPresent(contractNumber, forKey: .contractNumber)
        try c.encodeIfPresent(enterpriseName, forKey: .enterpriseName)
        try c.encodeIfPresent(dueDate, forKey: .dueDate)
        try c.encodeIfPresent(paymentDate, forKey: .paymentDate)
        try c.encodeIfPresent(paidAt, forKey: .paidAt)
        try c.encodeIfPresent(paidDate, forKey: .paidDate)
        try c.encodeIfPresent(originalValue, forKey: .originalValue)
        try c.encodeIfPresent(currentBalance, forKey: .currentBalance)
        try c.encodeIfPresent(latePaymentInterest, forKey: .latePaymentInterest)
        try c.encodeIfPresent(isPaid, forKey: .isPaid)
        try c.encodeIfPresent(isOverdue, forKey: .isOverdue)
        try c.encodeIfPresent(generatedBillet, forKey: .generatedBillet)
        try c.encodeIfPresent(billetStatusKnown, forKey: .billetStatusKnown)
        try c.encodeIfPresent(isEsolution, forKey: .isEsolution)
        try c.encodeIfPresent(esolutionBoletoId, forKey: .esolutionBoletoId)
    }

    private static func decodeInt(c: KeyedDecodingContainer<CodingKeys>, dyn: KeyedDecodingContainer<DynamicKey>, key: CodingKeys, alt: [String]) -> Int? {
        if let v = try? c.decodeIfPresent(Int.self, forKey: key) { return v }
        if let v = try? c.decodeIfPresent(Double.self, forKey: key) { return Int(v) }
        if let s = try? c.decodeIfPresent(String.self, forKey: key), let v = Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) { return v }
        for k in alt {
            guard let dk = DynamicKey(stringValue: k) else { continue }
            if let v = try? dyn.decodeIfPresent(Int.self, forKey: dk) { return v }
            if let v = try? dyn.decodeIfPresent(Double.self, forKey: dk) { return Int(v) }
            if let s = try? dyn.decodeIfPresent(String.self, forKey: dk), let v = Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) { return v }
        }
        return nil
    }

    private static func decodeDouble(c: KeyedDecodingContainer<CodingKeys>, dyn: KeyedDecodingContainer<DynamicKey>, key: CodingKeys, alt: [String]) -> Double? {
        if let v = try? c.decodeIfPresent(Double.self, forKey: key) { return v }
        if let v = try? c.decodeIfPresent(Int.self, forKey: key) { return Double(v) }
        if let s = try? c.decodeIfPresent(String.self, forKey: key), let v = Double(s.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)) {
            return v
        }
        for k in alt {
            guard let dk = DynamicKey(stringValue: k) else { continue }
            if let v = try? dyn.decodeIfPresent(Double.self, forKey: dk) { return v }
            if let v = try? dyn.decodeIfPresent(Int.self, forKey: dk) { return Double(v) }
            if let s = try? dyn.decodeIfPresent(String.self, forKey: dk), let v = Double(s.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)) {
                return v
            }
        }
        return nil
    }

    private static func decodeBool(c: KeyedDecodingContainer<CodingKeys>, dyn: KeyedDecodingContainer<DynamicKey>, key: CodingKeys, alt: [String]) -> Bool? {
        if let v = try? c.decodeIfPresent(Bool.self, forKey: key) { return v }
        if let v = try? c.decodeIfPresent(Int.self, forKey: key) { return v != 0 }
        if let s = try? c.decodeIfPresent(String.self, forKey: key) {
            let lower = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if ["true", "1", "yes", "sim"].contains(lower) { return true }
            if ["false", "0", "no", "nao", "não"].contains(lower) { return false }
        }
        for k in alt {
            guard let dk = DynamicKey(stringValue: k) else { continue }
            if let v = try? dyn.decodeIfPresent(Bool.self, forKey: dk) { return v }
            if let v = try? dyn.decodeIfPresent(Int.self, forKey: dk) { return v != 0 }
            if let s = try? dyn.decodeIfPresent(String.self, forKey: dk) {
                let lower = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if ["true", "1", "yes", "sim"].contains(lower) { return true }
                if ["false", "0", "no", "nao", "não"].contains(lower) { return false }
            }
        }
        return nil
    }

    private static func decodeString(c: KeyedDecodingContainer<CodingKeys>, dyn: KeyedDecodingContainer<DynamicKey>, key: CodingKeys, alt: [String]) -> String? {
        if let s = try? c.decodeIfPresent(String.self, forKey: key) {
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty { return s }
        }
        for k in alt {
            guard let dk = DynamicKey(stringValue: k) else { continue }
            if let s = try? dyn.decodeIfPresent(String.self, forKey: dk) {
                let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
                if !t.isEmpty { return s }
            }
        }
        return nil
    }

    /// Data como string ou número (epoch segundos/ms).
    private static func decodeDateLike(c: KeyedDecodingContainer<CodingKeys>, dyn: KeyedDecodingContainer<DynamicKey>, key: CodingKeys, alt: [String]) -> String? {
        if let s = try? c.decodeIfPresent(String.self, forKey: key) {
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty { return s }
        }
        if let num = try? c.decodeIfPresent(Double.self, forKey: key) {
            return formatEpochForDisplay(num)
        }
        if let num = try? c.decodeIfPresent(Int.self, forKey: key) {
            return formatEpochForDisplay(Double(num))
        }
        for k in alt {
            guard let dk = DynamicKey(stringValue: k) else { continue }
            if let s = try? dyn.decodeIfPresent(String.self, forKey: dk) {
                let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
                if !t.isEmpty { return s }
            }
            if let num = try? dyn.decodeIfPresent(Double.self, forKey: dk) {
                return formatEpochForDisplay(num)
            }
            if let num = try? dyn.decodeIfPresent(Int.self, forKey: dk) {
                return formatEpochForDisplay(Double(num))
            }
        }
        return nil
    }

    private static func formatEpochForDisplay(_ value: Double) -> String {
        let seconds: Double
        if value > 1e12 { seconds = value / 1000.0 }
        else { seconds = value }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date(timeIntervalSince1970: seconds)
        let y = cal.component(.year, from: date)
        let m = cal.component(.month, from: date)
        let d = cal.component(.day, from: date)
        return String(format: "%02d/%02d/%04d", d, m, y)
    }
}

struct ExtratoResponseDto: Codable {
    let items: [ExtratoItemDto]
    let totalOverdue: Double?
    let totalDue: Double?
    let overdueCount: Int?
    let dueCount: Int?
    let paidCount: Int?
    let totalPaid: Double?

    enum CodingKeys: String, CodingKey {
        case items, itens, totalOverdue, totalDue, overdueCount, dueCount, paidCount, totalPaid
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let fromItems = try? c.decode([ExtratoItemDto].self, forKey: .items)
        let fromItens = try? c.decode([ExtratoItemDto].self, forKey: .itens)
        items = fromItems ?? fromItens ?? []
        totalOverdue = try? c.decode(Double.self, forKey: .totalOverdue)
        totalDue = try? c.decode(Double.self, forKey: .totalDue)
        overdueCount = try? c.decode(Int.self, forKey: .overdueCount)
        dueCount = try? c.decode(Int.self, forKey: .dueCount)
        paidCount = try? c.decode(Int.self, forKey: .paidCount)
        totalPaid = try? c.decode(Double.self, forKey: .totalPaid)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(items, forKey: .items)
        try c.encodeIfPresent(totalOverdue, forKey: .totalOverdue)
        try c.encodeIfPresent(totalDue, forKey: .totalDue)
        try c.encodeIfPresent(overdueCount, forKey: .overdueCount)
        try c.encodeIfPresent(dueCount, forKey: .dueCount)
        try c.encodeIfPresent(paidCount, forKey: .paidCount)
        try c.encodeIfPresent(totalPaid, forKey: .totalPaid)
    }
}

/// GET /api/financial/resumo
private struct FinancialSummaryResponseDto: Codable {
    let totalOverdue: Double?
    let totalDue: Double?
    let overdueInstallmentsCount: Int?
    let dueInstallmentsCount: Int?
    let nextDue: NextDueDto?
    let totalVencido: Double?
    let totalAVencer: Double?
    let totalAberto: Double?

    struct NextDueDto: Codable {
        let dueDate: String?
        let amount: Double?
        let count: Int?
    }
}

struct PDFExtratoResponse: Codable {
    let pdfUrl: String
    let success: Bool
    let message: String?
}

class ExtratoService {
    static let shared = ExtratoService()
    private init() {}

    private var baseURL: String { ApiConfig.baseURL + "/" }

    private func createAuthorizedRequest(url: URL, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = PreferencesManager.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = body
        }
        return request
    }

    /// Paths possíveis do extrato (tenta em ordem até obter 200 e dados válidos)
    private static let extratoPaths = [
        "financial/extrato",
        "customers/financial/extrato",
        "customers/extrato",
        "financeiro/extrato",
        "customers/financeiro/extrato"
    ]

    private func extratoCacheKey(showPaid: Bool, showOverdue: Bool, showDue: Bool) -> String {
        let userId = PreferencesManager.shared.getUserId() ?? "anon"
        // Cache por usuário + parâmetros do endpoint.
        return "extrato|user:\(userId)|showPaid:\(showPaid)|showOverdue:\(showOverdue)|showDue:\(showDue)"
    }

    private func financialSummaryCacheKey() -> String {
        let userId = PreferencesManager.shared.getUserId() ?? "anon"
        return "financial-summary|user:\(userId)"
    }

    private func refreshFinancial() async throws {
        let refreshPath = "financial/refresh"
        guard let url = URL(string: baseURL + refreshPath) else { throw ExtratoError.networkError }

        // A rota precisa do token do usuário.
        guard let token = PreferencesManager.shared.getAuthToken(), !token.isEmpty else {
            throw ExtratoError.invalidCredentials
        }

        var request = createAuthorizedRequest(url: url, method: "POST")
        // Alguns backends exigem o token também no body.
        request.httpBody = try? JSONEncoder().encode(["token": token])

        var (_, response) = try await URLSession.shared.data(for: request)
        guard var http = response as? HTTPURLResponse else { throw ExtratoError.invalidResponse }

        if http.statusCode == 401 || http.statusCode == 403 {
            let recovered = await AuthService.shared.recoverSessionIfNeeded()
            guard recovered else { throw ExtratoError.invalidCredentials }
            request = createAuthorizedRequest(url: url, method: "POST")
            if let newToken = PreferencesManager.shared.getAuthToken(), !newToken.isEmpty {
                request.httpBody = try? JSONEncoder().encode(["token": newToken])
            }
            let retry = try await URLSession.shared.data(for: request)
            response = retry.1
            guard let retryHttp = response as? HTTPURLResponse else { throw ExtratoError.invalidResponse }
            http = retryHttp
        }

        if http.statusCode == 401 || http.statusCode == 403 {
            throw ExtratoError.invalidCredentials
        }

        // Alguns backends usam 200/201/202/204 para "refresh em background".
        guard (200...204).contains(http.statusCode) || http.statusCode == 202 else {
            throw ExtratoError.invalidResponse
        }
    }

    /// GET extrato – tenta vários paths e decodificações.
    func getExtrato(
        showPaid: Bool = true,
        showOverdue: Bool = true,
        showDue: Bool = true,
        useCache: Bool = true,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 5 * 60
    ) async throws -> [FinancialStatementItem] {
        let cacheKey = extratoCacheKey(showPaid: showPaid, showOverdue: showOverdue, showDue: showDue)
        if useCache, !forceRefresh,
           let cached: [FinancialStatementItem] = ApiCache.shared.get([FinancialStatementItem].self, key: cacheKey) {
            return cached
        }

        // Quando o usuário pedir refresh na tela, primeiro geramos/atualizamos no backend.
        if forceRefresh {
            try await refreshFinancial()
        }

        let queryItems = [
            URLQueryItem(name: "showPaid", value: showPaid ? "true" : "false"),
            URLQueryItem(name: "showOverdue", value: showOverdue ? "true" : "false"),
            URLQueryItem(name: "showDue", value: showDue ? "true" : "false")
        ]

        var lastNon200Status: Int?
        var lastNetworkError: Error?

        for path in Self.extratoPaths {
            var components = URLComponents(string: baseURL + path)
            components?.queryItems = queryItems
            guard let url = components?.url else { continue }

            let request = createAuthorizedRequest(url: url)

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    lastNon200Status = nil
                    continue
                }
                #if DEBUG
                print("[ExtratoService] GET \(path) → HTTP \(http.statusCode), \(data.count) bytes")
                #endif

                if http.statusCode == 401 {
                    let recovered = await AuthService.shared.recoverSessionIfNeeded()
                    guard recovered else { throw ExtratoError.invalidCredentials }
                    let retryRequest = createAuthorizedRequest(url: url)
                    let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
                    guard let retryHttp = retryResponse as? HTTPURLResponse else {
                        lastNon200Status = nil
                        continue
                    }
                    if retryHttp.statusCode == 401 { throw ExtratoError.invalidCredentials }
                    if retryHttp.statusCode != 200 {
                        lastNon200Status = retryHttp.statusCode
                        continue
                    }
                    let items = parseExtratoResponse(data: retryData)
                    if useCache {
                        let ttl = items.isEmpty ? min(cacheTTL, 60) : cacheTTL
                        ApiCache.shared.set(items, key: cacheKey, ttl: ttl)
                    }
                    return items
                }

                if http.statusCode != 200 {
                    lastNon200Status = http.statusCode
                    continue
                }

                // Resposta 200: tenta decodificar
                let items = parseExtratoResponse(data: data)
                if useCache {
                    // Evita ficar “travado” num parse/estrutura inesperada por muito tempo.
                    let ttl = items.isEmpty ? min(cacheTTL, 60) : cacheTTL
                    ApiCache.shared.set(items, key: cacheKey, ttl: ttl)
                }
                return items
            } catch ExtratoError.invalidCredentials {
                throw ExtratoError.invalidCredentials
            } catch {
                lastNetworkError = error
            }
        }

        if let status = lastNon200Status, status == 404 {
            if useCache {
                ApiCache.shared.set([FinancialStatementItem](), key: cacheKey, ttl: min(cacheTTL, 60))
            }
            return []
        }
        if let _ = lastNetworkError {
            throw ExtratoError.networkError
        }
        throw ExtratoError.invalidResponse
    }

    /// GET /api/financial/resumo - resumo financeiro pronto para o card do dashboard.
    func getFinancialSummary(
        useCache: Bool = true,
        forceRefresh: Bool = false,
        cacheTTL: TimeInterval = 5 * 60
    ) async throws -> FinancialSummary {
        let cacheKey = financialSummaryCacheKey()
        if useCache, !forceRefresh,
           let cached: FinancialSummary = ApiCache.shared.get(FinancialSummary.self, key: cacheKey) {
            return cached
        }

        // Mesmo comportamento do extrato: se for refresh manual, chama o refresh antes.
        if forceRefresh {
            try await refreshFinancial()
        }

        guard let url = URL(string: baseURL + "financial/resumo") else { throw ExtratoError.networkError }
        var request = createAuthorizedRequest(url: url)
        var (data, response) = try await URLSession.shared.data(for: request)

        guard var http = response as? HTTPURLResponse else { throw ExtratoError.invalidResponse }
        if http.statusCode == 401 || http.statusCode == 403 {
            let recovered = await AuthService.shared.recoverSessionIfNeeded()
            guard recovered else { throw ExtratoError.invalidCredentials }
            request = createAuthorizedRequest(url: url)
            let retry = try await URLSession.shared.data(for: request)
            data = retry.0
            response = retry.1
            guard let retryHttp = response as? HTTPURLResponse else { throw ExtratoError.invalidResponse }
            http = retryHttp
        }
        #if DEBUG
        print("[ExtratoService] GET financial/resumo → HTTP \(http.statusCode), \(data.count) bytes")
        #endif
        if http.statusCode == 401 || http.statusCode == 403 { throw ExtratoError.invalidCredentials }
        guard http.statusCode == 200 else { throw ExtratoError.invalidResponse }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let wrapped = try decoder.decode(ApiResponse<FinancialSummaryResponseDto>.self, from: data)
        #if DEBUG
        print("[ExtratoService] financial/resumo decodificado: success=\(wrapped.success), data=\(wrapped.data != nil ? "sim" : "nil"), message=\(wrapped.message ?? "-")")
        #endif
        guard let dto = wrapped.data else { throw ExtratoError.invalidResponse }

        let overdue = dto.totalOverdue ?? dto.totalVencido ?? 0
        let upcoming = dto.totalDue ?? dto.totalAVencer ?? 0
        let overdueCount = dto.overdueInstallmentsCount ?? 0
        let nextDate = normalizeDateForDisplay(dto.nextDue?.dueDate)
        let nextValue = dto.nextDue?.amount ?? 0
        let total = dto.totalAberto ?? (overdue + upcoming)

        let summary = FinancialSummary(
            overdueAmount: overdue,
            upcomingAmount: upcoming,
            overdueInstallments: overdueCount,
            totalAmount: total,
            nextDueDate: nextDate,
            nextDueValue: nextValue
        )

        if useCache {
            ApiCache.shared.set(summary, key: cacheKey, ttl: cacheTTL)
        }

        return summary
    }

    private func parseExtratoResponse(data: Data) -> [FinancialStatementItem] {
        let decoderSnake = JSONDecoder()
        decoderSnake.keyDecodingStrategy = .convertFromSnakeCase

        // API padrão: { success, message, data: { items/itens: [...] } }
        if let wrapped = try? decoderSnake.decode(ApiResponse<ExtratoResponseDto>.self, from: data),
           let dto = wrapped.data {
            return mapItems(dto.items)
        }

        // Fallback: { success, message, data: [ ... ] }
        if let wrappedArray = try? decoderSnake.decode(ApiResponse<[ExtratoItemDto]>.self, from: data),
           let list = wrappedArray.data {
            return mapItems(list)
        }

        // Fallback: array na raiz
        if let list = try? decoderSnake.decode([ExtratoItemDto].self, from: data) {
            return mapItems(list)
        }

        // Fallback: extrair do JSON (data.items, data.itens, items, itens, extrato)
        let extracted = extractItemsFromRawJSON(data, decoder: decoderSnake)
        if !extracted.isEmpty {
            return mapItems(extracted)
        }

        let decoderCamel = JSONDecoder()
        decoderCamel.keyDecodingStrategy = .useDefaultKeys
        let extractedCamel = extractItemsFromRawJSON(data, decoder: decoderCamel)
        if !extractedCamel.isEmpty {
            return mapItems(extractedCamel)
        }

        return []
    }

    private func extractItemsFromRawJSON(_ data: Data, decoder: JSONDecoder) -> [ExtratoItemDto] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [] }
        var array: [[String: Any]]?
        if let dataObj = json["data"] as? [String: Any] {
            array = (dataObj["items"] as? [[String: Any]]) ?? (dataObj["itens"] as? [[String: Any]])
        }
        if array == nil {
            array = (json["items"] as? [[String: Any]]) ?? (json["itens"] as? [[String: Any]]) ?? (json["extrato"] as? [[String: Any]])
        }
        guard let list = array else { return [] }
        return list.compactMap { dict -> ExtratoItemDto? in
            guard let itemData = try? JSONSerialization.data(withJSONObject: dict) else { return nil }
            return try? decoder.decode(ExtratoItemDto.self, from: itemData)
        }
    }

    private func mapItems(_ items: [ExtratoItemDto]) -> [FinancialStatementItem] {
        return items.map { item in
            let isPaid = item.isPaid ?? false
            let isOverdue = item.isOverdue ?? false

            // A API pode vir sem `isOverdue` consistente. Fazemos fallback pelo `dueDate`.
            // Comparação por "dia" evita problemas de timezone/horário.
            let due = parseDueDate(item.dueDate ?? "")
            let status: PaymentStatus = {
                if isPaid { return .paid }
                if isOverdue { return .overdue }
                if let due {
                    let calendar = Calendar.current
                    let dueStart = calendar.startOfDay(for: due)
                    let todayStart = calendar.startOfDay(for: Date())
                    if dueStart < todayStart { return .overdue }
                }
                return .upcoming
            }()

            let ventureName = item.enterpriseName ?? ""
            let dueRaw = item.dueDate?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let dueDate = normalizeDateForDisplay(item.dueDate) ?? (dueRaw.isEmpty ? "" : dueRaw)
            let paymentDate: String? = {
                let candidates = [item.paymentDate, item.paidAt, item.paidDate]
                    .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                for raw in candidates {
                    if let n = normalizeDateForDisplay(raw), !n.isEmpty { return n }
                }
                return candidates.first
            }()
            let originalVal = item.originalValue ?? 0
            let currentBal = item.currentBalance ?? 0
            let amount = currentBal > 0 ? currentBal : originalVal

            let instId = item.installmentId ?? 0
            let brId = item.billReceivableId ?? 0
            let id: String = item.isEsolution == true && item.esolutionBoletoId != nil
                ? "esolution-\(item.esolutionBoletoId!)"
                : "\(brId)-\(instId)"
            let parcela = item.installmentNumber ?? "\(instId)"

            return FinancialStatementItem(
                id: id,
                ventureName: ventureName,
                installmentNumber: parcela,
                parcela: parcela,
                dueDate: dueDate,
                paymentDate: paymentDate,
                amount: amount,
                status: status,
                contractNumber: item.contractNumber,
                billReceivableId: item.isEsolution == true ? nil : item.billReceivableId,
                installmentId: item.isEsolution == true ? nil : item.installmentId,
                isEsolution: item.isEsolution,
                esolutionBoletoId: item.esolutionBoletoId,
                generatedBillet: item.generatedBillet
            )
        }
    }

    /// Converte string de vencimento (dd/MM/yyyy ou yyyy-MM-dd ou ISO) em Date.
    private func parseDueDate(_ dueDate: String) -> Date? {
        let trimmed = dueDate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // ISO 8601 (ex.: 2026-02-23T00:00:00Z ou com milissegundos)
        let isoWithFraction = ISO8601DateFormatter()
        isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoWithFraction.date(from: trimmed) { return d }

        let isoNoFraction = ISO8601DateFormatter()
        isoNoFraction.formatOptions = [.withInternetDateTime]
        if let d = isoNoFraction.date(from: trimmed) { return d }

        let fmtBr = DateFormatter()
        fmtBr.dateFormat = "dd/MM/yyyy"
        fmtBr.locale = Locale(identifier: "pt_BR")
        if let d = fmtBr.date(from: trimmed) { return d }

        let fmtIso = DateFormatter()
        fmtIso.dateFormat = "yyyy-MM-dd"
        fmtIso.locale = Locale(identifier: "en_US_POSIX")
        if let d = fmtIso.date(from: trimmed) { return d }

        // Alguns endpoints podem retornar ISO com horário.
        let fmtIsoTime = DateFormatter()
        fmtIsoTime.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        fmtIsoTime.locale = Locale(identifier: "en_US_POSIX")
        if let d = fmtIsoTime.date(from: trimmed) { return d }

        return nil
    }

    private func normalizeDateForDisplay(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return raw }

        // Evita deslocamento por timezone:
        // extrai a data textual antes do "T" e só reorganiza os componentes.
        let dateLiteral: String = {
            if let tIdx = trimmed.firstIndex(of: "T") {
                return String(trimmed[..<tIdx])
            }
            return trimmed
        }()

        // yyyy-MM-dd -> dd/MM/yyyy
        if dateLiteral.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil {
            let comps = dateLiteral.split(separator: "-")
            if comps.count == 3 {
                return "\(comps[2])/\(comps[1])/\(comps[0])"
            }
        }

        // dd-MM-yyyy -> dd/MM/yyyy
        if dateLiteral.range(of: #"^\d{2}-\d{2}-\d{4}$"#, options: .regularExpression) != nil {
            return dateLiteral.replacingOccurrences(of: "-", with: "/")
        }

        // dd/MM/yyyy já está no formato esperado
        if dateLiteral.range(of: #"^\d{2}/\d{2}/\d{4}$"#, options: .regularExpression) != nil {
            return dateLiteral
        }

        guard let date = parseDueDate(trimmed) else { return raw }
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.timeZone = TimeZone(secondsFromGMT: 0)
        return fmt.string(from: date)
    }

    /// Resposta do endpoint de dados do boleto (usamos apenas pdfUrl).
    private struct BoletoDataDto: Codable {
        let pdfUrl: String?
    }

    /// Calcula o resumo financeiro a partir dos itens do extrato (mesma lógica da tela Extrato).
    /// - Dívidas vencidas e Parcelas atrasadas: todos os itens em atraso (sem filtro generatedBillet).
    /// - A Vencer: apenas itens a vencer com generatedBillet == true.
    /// - Próximo vencimento: primeiro item a vencer (com boleto gerado) por data.
    func buildFinancialSummary(from items: [FinancialStatementItem]) -> FinancialSummary {
        let overdue = items.filter { $0.status == .overdue }
        let overdueAmount = overdue.map(\.amount).reduce(0, +)
        let overdueInstallments = overdue.count

        let upcomingWithBillet = items.filter { $0.status == .upcoming && $0.generatedBillet == true }
        let upcomingAmount = upcomingWithBillet.map(\.amount).reduce(0, +)

        let nextDue: (date: String, value: Double)? = {
            let fmtBr = DateFormatter()
            fmtBr.dateFormat = "dd/MM/yyyy"
            fmtBr.locale = Locale(identifier: "pt_BR")

            let fmtIso = DateFormatter()
            fmtIso.dateFormat = "yyyy-MM-dd"
            fmtIso.locale = Locale(identifier: "en_US_POSIX")

            let fmtIsoTime = DateFormatter()
            fmtIsoTime.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            fmtIsoTime.locale = Locale(identifier: "en_US_POSIX")

            let fmtShort = DateFormatter()
            fmtShort.dateFormat = "dd/MM/yy"
            fmtShort.locale = Locale(identifier: "pt_BR")

            let fmtIsoZ = DateFormatter()
            fmtIsoZ.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            fmtIsoZ.locale = Locale(identifier: "en_US_POSIX")

            let fmtIsoZ2 = DateFormatter()
            fmtIsoZ2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            fmtIsoZ2.locale = Locale(identifier: "en_US_POSIX")

            let formatters = [fmtBr, fmtIso, fmtIsoTime, fmtShort, fmtIsoZ, fmtIsoZ2]

            func parse(_ s: String) -> Date? {
                let t = s.trimmingCharacters(in: .whitespaces)
                for fmt in formatters {
                    if let d = fmt.date(from: t) { return d }
                }
                if let d = ISO8601DateFormatter().date(from: t) { return d }
                return nil
            }

            let today = Calendar.current.startOfDay(for: Date())
            let withDate = upcomingWithBillet.compactMap { item -> (item: FinancialStatementItem, date: Date)? in
                guard let d = parse(item.dueDate) else { return nil }
                return (item, d)
            }

            let fmtDisplay = DateFormatter()
            fmtDisplay.dateFormat = "dd/MM/yyyy"
            fmtDisplay.locale = Locale(identifier: "pt_BR")

            func toDisplay(_ d: Date) -> String { fmtDisplay.string(from: d) }

            let sorted = withDate.filter { $0.date >= today }.sorted { $0.date < $1.date }
            if let first = sorted.first {
                return (toDisplay(first.date), first.item.amount)
            }
            if let firstAny = withDate.sorted(by: { $0.date < $1.date }).first {
                return (toDisplay(firstAny.date), firstAny.item.amount)
            }
            if let firstRaw = upcomingWithBillet.min(by: { $0.dueDate < $1.dueDate }) {
                return (firstRaw.dueDate, firstRaw.amount)
            }
            return nil
        }()

        return FinancialSummary(
            overdueAmount: overdueAmount,
            upcomingAmount: upcomingAmount,
            overdueInstallments: overdueInstallments,
            totalAmount: overdueAmount + upcomingAmount,
            nextDueDate: nextDue?.date,
            nextDueValue: nextDue?.value ?? 0
        )
    }

    /// Obtém a URL do PDF do boleto para "Ver Boleto" / "Gerar 2ª Via". Retorna nil se falhar ou não aplicável.
    func getBoletoPdfUrl(item: FinancialStatementItem) async -> URL? {
        // Esolution
        if item.isEsolution == true, let id = item.esolutionBoletoId {
            guard let url = URL(string: baseURL + "financial/boleto-data/esolution/\(id)") else { return nil }
            let request = createAuthorizedRequest(url: url)
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
            let decoded = try? JSONDecoder().decode(ApiResponse<BoletoDataDto>.self, from: data)
            guard let pdfUrlString = decoded?.data?.pdfUrl, let pdfUrl = URL(string: pdfUrlString) else { return nil }
            return pdfUrl
        }

        // Sienge
        guard let brId = item.billReceivableId, let instId = item.installmentId else { return nil }
        guard let url = URL(string: baseURL + "financial/boleto-data/\(brId)/\(instId)") else { return nil }
        let request = createAuthorizedRequest(url: url)
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
        let decoded = try? JSONDecoder().decode(ApiResponse<BoletoDataDto>.self, from: data)
        guard let pdfUrlString = decoded?.data?.pdfUrl, let pdfUrl = URL(string: pdfUrlString) else { return nil }
        return pdfUrl
    }

    /// Anos calendário em que há movimentação no extrato (vencimento e, quando existir, data de pagamento).
    /// Prioriza leitura literal dos componentes da data (sem `Date`/timezone) para não alterar o ano.
    func distinctCalendarYearsFromExtrato(
        useCache: Bool = true,
        forceRefresh: Bool = false
    ) async throws -> [Int] {
        let items = try await getExtrato(
            showPaid: true,
            showOverdue: true,
            showDue: true,
            useCache: useCache,
            forceRefresh: forceRefresh
        )
        return Self.distinctCalendarYears(from: items)
    }

    static func distinctCalendarYears(from items: [FinancialStatementItem]) -> [Int] {
        var years = Set<Int>()
        for item in items {
            if let y = Self.calendarYearLiteral(from: item.dueDate) {
                years.insert(y)
            }
            if let pd = item.paymentDate?.trimmingCharacters(in: .whitespacesAndNewlines), !pd.isEmpty,
               let y = Self.calendarYearLiteral(from: pd) {
                years.insert(y)
            }
        }
        return years.sorted(by: >)
    }

    /// Extrai o ano a partir de `dd/MM/yyyy`, `dd-MM-yyyy` ou `yyyy-MM-dd` (ou prefixo antes de `T` em ISO).
    private static func calendarYearLiteral(from raw: String) -> Int? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let datePart = trimmed.split(separator: "T", maxSplits: 1, omittingEmptySubsequences: false)
            .first
            .map(String.init) ?? trimmed

        if datePart.range(of: #"^\d{2}/\d{2}/\d{4}$"#, options: .regularExpression) != nil {
            let parts = datePart.split(separator: "/")
            if parts.count == 3, let y = Int(parts[2]) { return y }
        }

        if datePart.range(of: #"^\d{2}-\d{2}-\d{4}$"#, options: .regularExpression) != nil {
            let parts = datePart.split(separator: "-")
            if parts.count == 3, let y = Int(parts[2]) { return y }
        }

        if datePart.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil {
            return Int(datePart.prefix(4))
        }

        return nil
    }
}

