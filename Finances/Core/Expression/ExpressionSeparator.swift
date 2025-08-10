//
//  ExpressionSeparator.swift
//  Finances
//
//  Created by Dmitriy Zharov on 16.08.2024.
//

import Foundation
import FoundationExtension

typealias DecimalSeparator = ExpressionSeparator

enum ExpressionSeparator: String, CaseIterable, Codable {
    /// Sign "."
    case dot = "."
    /// Sign ","
    case comma = ","
    
    /// The character value that the expression separator represents.
    var character: Character {
        switch self {
        case .dot:
            return "."
        case .comma:
            return ","
        }
    }
    
    /// Creates a new expression separator from the given character value.
    init?(_ character: Character) {
        switch character {
        case ".": self = .dot
        case ",": self = .comma
        default:
            return nil
        }
    }
}

extension ExpressionSeparator {
    static var current: ExpressionSeparator {
        if let decimalSeparator = Locale.current.decimalSeparator, let expressionSeparator = ExpressionSeparator(rawValue: decimalSeparator) {
            return expressionSeparator
        } else {
            return .dot
        }
    }
}

extension ExpressionSeparator: CustomLocalizedStringConvertible {
    var localizedDescription: String {
        switch self {
        case .dot:
            return String(localized: "Dot")
        case .comma:
            return String(localized: "Comma")
        }
    }
}
