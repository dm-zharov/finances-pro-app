//
//  AmountField.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.11.2023.
//

import SwiftUI
import FoundationExtension
import CurrencyKit
import AppUI
import KeyboardKit
import Expression

enum Operator: String, CaseIterable {
    case add = "+"
    case subtract = "-"
    case multiply = "*"
    case divide = "/"
    
    case inverse = "±"
    
    var character: Character {
        Character(rawValue)
    }
}

extension Math {
    enum CharacterSet {
        static let expression = Foundation.CharacterSet.decimalDigits.union(separators).union(operators)
        
        static let operators = Foundation.CharacterSet(charactersIn: Operator.allCases.map(\.rawValue).joined(separator: ""))
        static let separators = Foundation.CharacterSet(charactersIn: ",.")
        static let symbols = operators.union(separators)
    }
}

struct AmountField: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    @Environment(\.customKeyboardState) private var keyboardState
    
    let titleKey: LocalizedStringKey
    let currency: Currency
    @Binding var value: Decimal
    let onReady: @MainActor (Bool) -> Void
    let onSubmit: @MainActor () -> Void
    
    @State private var text: String = .empty
    private let format: Decimal.FormatStyle = .number.grouping(.never)
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        TextField(titleKey, text: $text, prompt: placeholder)
            #if os(iOS)
            .keyboard(userInterfaceIdiom == .phone ? .default : .decimalPad) {
                NumericKeyboardView()
                    .customKeyboardSubmit(submit)
            }
            #endif
            .onSubmit(submit)
            .onChange(of: text) { previousText, currentText in
                guard previousText != currentText else {
                    return
                }
                handle(currentText)
                updateKeyboardState()
            }
            .onChange(of: value, initial: true) { previousValue, currentValue in
                handle(value)
                updateKeyboardState()
            }
    }
    
    func handle(_ text: String) {
        guard sign(text) == text else {
            return handle(sign(text))
        }
        
        if validate(text) {
            let (text, value) = evaluate(text)
            self.value = value; self.text = sign(text)
        } else {
            self.value = Decimal(signOf: value, magnitudeOf: 0); self.text = .empty
        }
    }
    
    func handle(_ value: Decimal) {
        if value != evaluate(text).value, value != .zero, value != .zero.reversed {
            self.text = value.formatted(format)
        }
    }
    
    @MainActor
    func submit() {
        let (_, value) = evaluate(text)
        self.value = value; self.text = value.formatted(format)
        if keyboardState.submitLabel == .return {
            onSubmit()
        }
    }
    
    init(
        _ titleKey: LocalizedStringKey = "Amount",
        value: Binding<Decimal>,
        currency: Currency,
        onReady: @MainActor @escaping (Bool) -> Void,
        onSubmit: @MainActor @escaping () -> Void
    ) {
        self.titleKey = titleKey
        self.currency = currency
        self._value = value
        self.onReady = onReady
        self.onSubmit = onSubmit
    }
}

// MARK: - Placeholder

extension AmountField {
    var placeholderStyle: AnyShapeStyle {
        if userInterfaceIdiom == .phone ? value > .zero : value >= .zero {
            return AnyShapeStyle(Color.green.secondary)
        } else {
            return AnyShapeStyle(Color.ui(.placeholderText))
        }
    }
    
    var placeholder: Text? {
        let value = value == .zero.reversed ? .zero : value
        return Text(value.formatted(.currency(currency)))
            .foregroundStyle(placeholderStyle)
    }
}

extension AmountField {
    func validate(_ text: String) -> Bool {
        guard
            text != "\(Operator.subtract.rawValue)\(Operator.add.rawValue)" && text != "\(Operator.add.rawValue)\(Operator.subtract.rawValue)"
        else {
            return true
        }
        
        guard text != Operator.divide.rawValue || text != Operator.multiply.rawValue else {
            return false
        }
        
        guard !text.contains("\(Operator.divide.rawValue)0") else {
            return false
        }
        
        // String contains allowed characters only.
        guard text.allSatisfy({ character in
            Math.CharacterSet.expression.containsUnicodeScalars(of: character)
        }) else {
            return false
        }
        
        // String not contains two symbols in a row.
        var previousCharacter: Character?
        for character in text {
            if let previousCharacter, Math.CharacterSet.symbols.containsUnicodeScalars(of: previousCharacter) {
                if Math.CharacterSet.symbols.containsUnicodeScalars(of: character) {
                    return false
                }
            }
            previousCharacter = character
        }
        
        return true
    }
    
    func sign(_ text: String) -> String {
        switch value.sign {
        case .plus:
            if text == Operator.subtract.rawValue {
                return text
            }
            if text.hasPrefix(Operator.subtract.rawValue), text.trimmingCharacters(in: CharacterSet.decimalDigits) == Operator.subtract.rawValue {
                return String(text.trimmingPrefix(Operator.subtract.rawValue))
            }
        case .minus:
            if text.isEmpty {
                return text
            }
            if text.trimmingCharacters(in: CharacterSet.decimalDigits).isEmpty {
                return Operator.subtract.rawValue.appending(text)
            }
        }
        return text
    }
    
    func evaluate(_ text: String) -> (text: String, value: Decimal) {
        var text = text
        
        // Reverse
        if let inverseIndex = text.firstIndex(of: Character(Operator.inverse.rawValue)) {
            text.remove(at: inverseIndex)
            let (_, value) = evaluate(text)
            guard value != .zero.reversed else {
                return (.empty, Decimal(signOf: value.reversed, magnitudeOf: value))
            }
            return (value.reversed.formatted(format), Decimal(signOf: value.reversed, magnitudeOf: value))
        }
        
        // Minus or Plus-Minus
        if text == Operator.subtract.rawValue || text == "\(Operator.add.rawValue)\(Operator.subtract.rawValue)" {
            return (Operator.subtract.rawValue, .zero.reversed)
        }
        
        // Plus or Minus-Plus
        if text == Operator.add.rawValue || text == "\(Operator.subtract.rawValue)\(Operator.add.rawValue)" {
            return (.empty, .zero)
        }

        // Evaluate
        do {
            let result = Decimal(try Math(text.replacingOccurrences(of: ",", with: ".")).evaluate())
            guard result != .zero else {
                return (text, Decimal(signOf: value, magnitudeOf: 0))
            }
            return (text, result)
        } catch {
            return (text, Decimal(signOf: value, magnitudeOf: 0))
        }
    }
}
 
extension AmountField {
    @MainActor
    func updateKeyboardState() {
        // Active/deactive inverse button
        let isInverse: Bool = value.sign == .minus
        if keyboardState.isInverse != isInverse {
            keyboardState.isInverse = isInverse
        }
        
        // Replace return key definition
        let submitLabel: CustomKeyboardState.SubmitLabel = text.enumerated().contains(where: { index, character in
            if Math.CharacterSet.operators.containsUnicodeScalars(of: character) {
                if index == 0, character == "-", isInverse {
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        }) ? .equal : .return
        if keyboardState.submitLabel != submitLabel {
            keyboardState.submitLabel = submitLabel; onReady(submitLabel == .return)
        }
    }
}

extension AmountField {
    func labeled(_ titleKey: LocalizedStringKey = "Amount") -> some View {
        #if os(iOS)
        modifier(LabeledModifier<Self>(titleKey))
        #else
        self
        #endif
    }
}

#Preview {
    List {
        AmountField(value: .constant(100.0), currency: .usd, onReady: { _ in }) {
            
        }
    }
}
