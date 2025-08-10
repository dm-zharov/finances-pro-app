//
//  DateFormatter+Relative.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.09.2023.
//

import Foundation

extension DateFormatter {
    public struct RelativeFormatStyle: FormatStyle {
        public typealias FormatInput = Date
        public typealias FormatOutput = String
        
        public func format(_ value: Date) -> String {
            DateFormatter.relative.string(from: value)
        }
    }
    
    static var relative: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }
}

extension NumberFormatter {
    static var decimal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 2
        formatter.generatesDecimalNumbers = true
        return formatter
    }
    
    static func currency(code: String) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.generatesDecimalNumbers = true
        return formatter
    }
}
