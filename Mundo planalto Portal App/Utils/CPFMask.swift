//
//  CPFMask.swift
//  Hard Rock Hotel & Vacation Club
//
//  Máscaras de CPF (000.000.000-00) e CNPJ (00.000.000/0000-00).
//

import Foundation

struct CPFMask {
    /// Aplica máscara de CPF (até 11 dígitos) ou CNPJ (12 a 14 dígitos).
    static func format(_ text: String) -> String {
        let numbers = String(unformat(text).prefix(14))
        if numbers.count > 11 {
            return formatCNPJ(numbers)
        }
        return formatCPF(numbers)
    }

    static func formatCPF(_ numbers: String) -> String {
        if numbers.count <= 3 {
            return numbers
        } else if numbers.count <= 6 {
            return "\(numbers.prefix(3)).\(numbers.dropFirst(3))"
        } else if numbers.count <= 9 {
            return "\(numbers.prefix(3)).\(numbers.dropFirst(3).prefix(3)).\(numbers.dropFirst(6))"
        } else {
            return "\(numbers.prefix(3)).\(numbers.dropFirst(3).prefix(3)).\(numbers.dropFirst(6).prefix(3))-\(numbers.dropFirst(9))"
        }
    }

    static func formatCNPJ(_ numbers: String) -> String {
        var out = ""
        for (i, ch) in numbers.enumerated() {
            switch i {
            case 2, 5: out += "."
            case 8: out += "/"
            case 12: out += "-"
            default: break
            }
            out.append(ch)
        }
        return out
    }

    static func unformat(_ text: String) -> String {
        return text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }

    /// Documento válido para login: 11 (CPF) ou 14 (CNPJ) dígitos.
    static func isValidDocumentLength(_ text: String) -> Bool {
        let n = unformat(text).count
        return n == 11 || n == 14
    }
}
