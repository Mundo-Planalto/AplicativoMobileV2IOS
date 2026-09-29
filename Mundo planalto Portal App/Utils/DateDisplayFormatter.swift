//
//  DateDisplayFormatter.swift
//  Mundo planalto Portal App
//

import Foundation

enum DateDisplayFormatter {
    /// Formata para dd/MM/yyyy. Para ISO com `T…Z`, usa só os componentes da **data** (antes do `T`) para não mudar o dia por fuso.
    static func toPtBRDate(_ value: String?) -> String {
        guard let value else { return "-" }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "-" }

        if let literal = literalCalendarDayToPtBR(trimmed) {
            return literal
        }

        if let date = parse(trimmed) {
            let out = DateFormatter()
            out.locale = Locale(identifier: "pt_BR")
            out.dateFormat = "dd/MM/yyyy"
            return out.string(from: date)
        }

        return trimmed
    }

    /// Reorganiza só por texto: `yyyy-MM-dd`, `dd-MM-yyyy` ou parte antes de `T` (ex.: `2008-08-10T00:00:00Z`, `10-08-2008T00:00:00Z`).
    private static func literalCalendarDayToPtBR(_ trimmed: String) -> String? {
        let beforeT = trimmed.split(separator: "T", maxSplits: 1, omittingEmptySubsequences: false)
            .first
            .map(String.init) ?? trimmed
        let token = beforeT.split(whereSeparator: { $0.isWhitespace }).first.map(String.init) ?? beforeT

        if token.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil {
            let comps = token.split(separator: "-")
            if comps.count == 3 {
                return "\(comps[2])/\(comps[1])/\(comps[0])"
            }
        }

        if token.range(of: #"^\d{1,2}-\d{1,2}-\d{4}$"#, options: .regularExpression) != nil {
            let comps = token.split(separator: "-")
            if comps.count == 3,
               let day = Int(comps[0]),
               let month = Int(comps[1]),
               let year = Int(comps[2]) {
                return String(format: "%02d/%02d/%04d", day, month, year)
            }
        }

        if token.range(of: #"^\d{2}/\d{2}/\d{4}$"#, options: .regularExpression) != nil {
            return token
        }

        return nil
    }

    private static func parse(_ text: String) -> Date? {
        let isoWithFraction = ISO8601DateFormatter()
        isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoWithFraction.date(from: text) { return date }

        let isoBasic = ISO8601DateFormatter()
        isoBasic.formatOptions = [.withInternetDateTime]
        if let date = isoBasic.date(from: text) { return date }

        let formats = [
            "dd/MM/yyyy",
            "yyyy-MM-dd",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd HH:mm:ss",
            "dd/MM/yyyy HH:mm:ss"
        ]

        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = format
            if let date = formatter.date(from: text) {
                return date
            }
        }

        return nil
    }
}
