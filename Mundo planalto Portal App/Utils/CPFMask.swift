//
//  CPFMask.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import Foundation

struct CPFMask {
    static func format(_ text: String) -> String {
        let numbers = text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
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
    
    static func unformat(_ text: String) -> String {
        return text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
}
