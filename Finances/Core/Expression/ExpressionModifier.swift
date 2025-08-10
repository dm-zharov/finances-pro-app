//
//  ExpressionCommand.swift
//  Finances
//
//  Created by Dmitriy Zharov on 16.08.2024.
//

import Foundation

enum ExpressionModifier: String, CaseIterable {
    /// Plus-Minus Sign "±"
    case negate = "\u{00B1}"
    /// Equals Sign "="
    case equal = "\u{003D}"
    
    var character: Character {
        switch self {
        case .negate: "\u{00B1}"
        case .equal:  "\u{003D}"
        }
    }
    
    init?(_ character: Character) {
        switch character {
        case "\u{00B1}": self = .negate
        case "\u{003D}": self = .equal
        default:
            return nil
        }
    }
}
