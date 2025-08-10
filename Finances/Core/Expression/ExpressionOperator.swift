//
//  ExpressionOperator.swift
//  Finances
//
//  Created by Dmitriy Zharov on 16.08.2024.
//

import Foundation

enum ExpressionOperator: String, CaseIterable {
    // Plus Sign, "+"
    case add = "\u{002B}"
    // "-", Hyphen-Minus
    case subtract = "\u{002D}"
    // Multiplication Sign "×"
    case multiply = "\u{00D7}"
    // Solidus "/"
    case divide = "\u{002F}"
    
    var characterSet: CharacterSet {
        switch self {
        case .add: [
            "\u{002B}", // "+", Plus Sign
        ]
        case .subtract: [
            "\u{2212}", // "−", Minus Sign
            "\u{002D}", // "-", Hyphen-Minus
            "\u{2010}", // "‐", Hyphen
        ]
        case .multiply: [
            "\u{00D7}", // "×", Multiplication Sign
            "\u{002A}", // "*", Asterisk
        ]
        case .divide: [
            "\u{002F}", // "/", Solidus
            "\u{00F7}", // "÷", Division Sign
        ]
        }
    }
    
    init?(rawValue: String) {
        if rawValue.count == 1 {
            self.init(Character(rawValue))
        } else {
            return nil
        }
    }
    
    init?(_ character: Character) {
        if let expressionOperator = ExpressionOperator.allCases.first(where: { expressionOperator in
            expressionOperator.characterSet.containsUnicodeScalars(of: character)
        }) {
            self = expressionOperator
        } else {
            return nil
        }
    }
}
