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
    case invalidCharacters
    case tooManyDecimalSeparators
    case consecutiveOperators
    case divisionByZero
    
    var localizedDescription: String {
        switch self {
        case .parsingError:
            return String(localized: "Unable to parse expression")
        case .invalidCharacters:
            return String(localized: "Expression contains invalid characters")
        case .tooManyDecimalSeparators:
            return String(localized: "Expression contains multiple decimal separators")
        case .consecutiveOperators:
            return String(localized: "Expression contains consecutive operators")
        case .divisionByZero:
            return String(localized: "Division by zero is not allowed")
        }
    }
}

final class ExpressionFormatter: Formatter {
    
    // MARK: - Public Methods
    
    /// Converts a string expression to a `Decimal` value.
    /// - Parameter string: The expression string to evaluate.
    /// - Returns: The evaluated `Decimal` value, or `nil` if the expression is incomplete or invalid.
    /// - Throws: `ExpressionFormatterError` if the expression is malformed.
    func value(from string: String) throws(ExpressionFormatterError) -> Decimal? {
        // Empty strings evaluate to zero
        guard !string.isEmpty else {
            return .zero
        }
        
        // Single "0" returns nil (incomplete input)
        guard string != "0" else {
            return nil
        }
        
        // Handle single operator case
        if let expressionOperator = ExpressionOperator(rawValue: string) {
            return try handleSingleOperator(expressionOperator)
        }
        
        // Validate the expression
        try validateExpression(string)
        
        // Normalize and evaluate
        return try evaluateExpression(string)
    }
    
    /// Converts a `Decimal` value to its string representation.
    /// - Parameter value: The decimal value to format.
    /// - Returns: A string representation of the value, or empty string if zero.
    func string(from value: Decimal) -> String {
        value.isZero ? "" : value.formatted(.number.grouping(.never))
    }
    
    // MARK: - Formatter Overrides
    
    override func string(for obj: Any?) -> String? {
        guard let value = obj as? Decimal else {
            return nil
        }
        return string(from: value)
    }
    
    override func isPartialStringValid(
        _ partialString: String,
        newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        false
    }
    
    // MARK: - Private Validation Methods
    
    private func handleSingleOperator(_ operator: ExpressionOperator) throws(ExpressionFormatterError) -> Decimal? {
        switch `operator` {
        case .subtract:
            return nil
        default:
            throw .parsingError
        }
    }
    
    private func validateExpression(_ string: String) throws(ExpressionFormatterError) {
        // Check for division by zero pattern
        guard !string.hasSuffix("\(ExpressionOperator.divide.rawValue)0") else {
            throw .divisionByZero
        }
        
        // Validate character set (excluding modifiers)
        try validateCharacterSet(string)
        
        // Validate decimal separator count
        try validateDecimalSeparators(string)
        
        // Validate no consecutive operators
        try validateNoConsecutiveOperators(string)
    }
    
    private func validateCharacterSet(_ string: String) throws(ExpressionFormatterError) {
        let allowedCharacters: CharacterSet = .expressionSymbols.subtracting(.expressionModifiers)
        guard CharacterSet(charactersIn: string).isSubset(of: allowedCharacters) else {
            throw .invalidCharacters
        }
    }
    
    private func validateDecimalSeparators(_ string: String) throws(ExpressionFormatterError) {
        let separatorCount = string.count { ExpressionSeparator($0) != nil }
        guard separatorCount <= 1 else {
            throw .tooManyDecimalSeparators
        }
    }
    
    private func validateNoConsecutiveOperators(_ string: String) throws(ExpressionFormatterError) {
        var previousCharacter: Character?
        
        for character in string {
            if let previous = previousCharacter,
               CharacterSet.expressionOperators.containsUnicodeScalars(of: previous),
               CharacterSet.expressionOperators.containsUnicodeScalars(of: character) {
                throw .consecutiveOperators
            }
            previousCharacter = character
        }
    }
    
    // MARK: - Private Evaluation Methods
    
    private func evaluateExpression(_ string: String) throws(ExpressionFormatterError) -> Decimal? {
        let normalizedString = normalizeExpression(string)
        
        do {
            let evaluator = ExpressionEvaluator(normalizedString)
            let result = try evaluator.evaluate()
            return Decimal(result)
        } catch {
            // Expression library couldn't evaluate, return nil for incomplete expressions
            return nil
        }
    }
    
    private func normalizeExpression(_ string: String) -> String {
        string
            .replacingOccurrences(of: ExpressionSeparator.comma.rawValue, with: ExpressionSeparator.dot.rawValue)
            .replacingOccurrences(of: ExpressionOperator.subtract.rawValue, with: "-")
            .replacingOccurrences(of: ExpressionOperator.multiply.rawValue, with: "*")
    }
}

// MARK: - CharacterSet Extensions

extension CharacterSet {
    /// Character set containing brackets: `()[]{}`
    static let expressionBrackets = CharacterSet(charactersIn: "()[]{}")
    
    /// Character set containing decimal separators: `,.`
    static let expressionSeparators = CharacterSet(charactersIn: ",.")

    /// Character set containing expression modifiers (negate, equal, etc.)
    static let expressionModifiers = CharacterSet(
        charactersIn: ExpressionModifier.allCases.map(\.rawValue).joined()
    )
    
    /// Character set containing all expression operators (+, -, ×, /)
    static let expressionOperators = ExpressionOperator.allCases
        .reduce(into: CharacterSet()) { $0 = $0.union($1.characterSet) }

    /// Character set containing all valid expression symbols
    static let expressionSymbols = CharacterSet.decimalDigits
        .union(.expressionSeparators)
        .union(.expressionModifiers)
        .union(.expressionOperators)
        .union(.expressionBrackets)
}

// MARK: - Numeric Extensions

extension BinaryFloatingPoint {
    /// Returns the negative value of this number.
    var negative: Self {
        var value = self
        value.negate()
        return value
    }
}

extension Decimal {
    /// Returns the negative value of this decimal.
    var negative: Decimal {
        var value = self
        value.negate()
        return value
    }
}

extension FloatingPointSign {
    /// Toggles between plus and minus signs.
    mutating func toggle() {
        self = self == .plus ? .minus : .plus
    }
}
