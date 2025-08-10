//
//  ExpressionFormatter.swift
//  Finances
//
//  Created by Dmitriy Zharov on 15.08.2024.
//

import Foundation
import Expression

enum ExpressionFormatterError: Error {
    case parsingError
}

final class ExpressionFormatter: Formatter {
    func value(from string: String) throws(ExpressionFormatterError) -> Decimal? {
        if string.isEmpty {
            return .zero
        }
        
        if string == "0" {
            return nil
        }
        
        if let expressionOperator = ExpressionOperator(rawValue: string) {
            switch expressionOperator {
            case .subtract:
                return nil
            default:
                throw .parsingError
            }
        }
        
        guard !string.hasSuffix("\(ExpressionOperator.divide.rawValue)0") else {
            throw .parsingError
        }
        
        let expressionCharacters: CharacterSet = .expressionSymbols.subtracting(.expressionModifiers)
        guard CharacterSet(charactersIn: string).isSubset(of: expressionCharacters) else {
            throw .parsingError
        }

        if string.count(where: { character in ExpressionSeparator(character) != nil }) > 1 {
            throw .parsingError
        }
        
        // String not contains two symbols in a row.
        var previousCharacter: Character?
        for character in string {
            if let previousCharacter, CharacterSet.expressionOperators.containsUnicodeScalars(of: previousCharacter) {
                if CharacterSet.expressionOperators.containsUnicodeScalars(of: character) {
                    throw .parsingError
                }
            }
            previousCharacter = character
        }

        do {
            let evaluator = ExpressionEvaluator(
                string
                    .replacingOccurrences(of: ExpressionSeparator.comma.rawValue, with: ExpressionSeparator.dot.rawValue)
                    .replacingOccurrences(of: ExpressionOperator.subtract.rawValue, with: "-")
                    .replacingOccurrences(of: ExpressionOperator.multiply.rawValue, with: "*")
            )
            return try Decimal(evaluator.evaluate())
        } catch {
            return nil
        }
    }
    
    func string(from value: Decimal) -> String {
        if value.isZero {
            return ""
        } else {
            return value.formatted(.number.grouping(.never))
        }
    }
    
    override func string(for obj: Any?) -> String? {
        if let value = obj as? Decimal {
            return string(from: value)
        } else {
            return nil
        }
    }
    
    override func isPartialStringValid(
        _ partialString: String,
        newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        return false
    }
}

extension CharacterSet {
    /// Brackets.
    static let expressionBrackets = CharacterSet(
        charactersIn: "()[]{}"
    )
    
    /// Separators.
    static let expressionSeparators = CharacterSet(
        charactersIn: ",."
    )

    /// Modifiers.
    static let expressionModifiers = CharacterSet(
        charactersIn: ExpressionModifier.allCases.map(\.rawValue).joined(separator: .empty)
    )
    
    /// Operators.
    static let expressionOperators = ExpressionOperator.allCases
        .reduce(CharacterSet()) { $0.union($1.characterSet) }

    /// Symbols.
    static let expressionSymbols = CharacterSet.decimalDigits
        .union(expressionSeparators)
        .union(expressionModifiers)
        .union(expressionOperators)
        .union(expressionBrackets)
}

extension BinaryFloatingPoint {
    var negative: Self {
        var value = self
        value.negate()
        return value
    }
}

extension Decimal {
    var negative: Decimal {
        var value = self
        value.negate()
        return value
    }
}

extension FloatingPointSign {
    mutating func toggle() {
        switch self {
        case .plus:
            self = .minus
        case .minus:
            self = .plus
        }
    }
}
