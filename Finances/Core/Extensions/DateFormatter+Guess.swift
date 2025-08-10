//
//  DateFormatter+Guess.swift
//  Finances
//
//  Created by Dmitriy Zharov on 29.11.2023.
//

import Foundation

extension CharacterSet {
    static let dateSeparators = CharacterSet(charactersIn: DateFormatter.DateSeparator.allCases.map(\.rawValue).joined())
}

extension DateFormatter {
    static var fixed: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .gmt
        return dateFormatter
    }
}

extension ISO8601DateFormatter {
    static var `default`: ISO8601DateFormatter {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return dateFormatter
    }
}

extension DateFormatter {
    enum DateSeparator: String, CaseIterable {
        case dash = "-"
        case slash = "/"
        case dot = "."
        case space = " "
        
        static func guessed(from string: String) throws -> DateSeparator {
            guard let dateSeparator = allCases.first(where: { dateSeparator in
                string.contains(dateSeparator.rawValue)
            }) else {
                throw DateFormat.GuessError.missingSeparator
            }
            return dateSeparator
        }
    }
    
    enum DateOrder: CaseIterable {
        case yearMonthDay // Common in many Asian countries and ISO 8601 standard (e.g., 2023-03-14)
        case dayMonthYear // Common in many European and Latin American countries (e.g., 14-03-2023)
        case monthDayYear // common in the United States (e.g., 03-14-2023)
        
        static func guessed(from string: String) throws -> DateOrder {
            let components = Array(string.components(separatedBy: CharacterSet.dateSeparators).prefix(3))
            
            // Parsing is tied to existence of numeric year (e.g. "2023")
            guard
                let indexOfYear = components.firstIndex(where: { string in string.count == 4 && Int(string) != nil }), components.count >= 3
            else {
                throw DateFormat.GuessError.missingYear
            }
            
            // YMD, DMY, MDY?
            
            if indexOfYear == 0 {
                return .yearMonthDay
            }
            
            // DMY, MDY?
            
            guard let indexOfDay = components.firstIndex(where: { string in
                if let int = Int(string) {
                    return int > 12 && int <= 31
                } else {
                    return false
                }
            }) else {
                throw DateFormat.GuessError.multipleChoices
            }
            
            // DMY, MDY?
            
            switch indexOfDay {
            case 0:
                return .dayMonthYear
            case 1:
                return .monthDayYear
            case 2:
                return .yearMonthDay
            default:
                fatalError()
            }
        }
    }
}

extension DateFormatter.DateOrder: CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .yearMonthDay:
            "Year-Month-Day"
        case .dayMonthYear:
            "Day-Month-Year"
        case .monthDayYear:
            "Month-Day-Year"
        }
    }
}

extension DateFormatter {
    enum DateFormat {
        enum GuessError: Error {
            case missingSeparator
            case missingYear
            case multipleChoices
            case unknownFormat
        }
        
        static func guessed(from string: String, dateOrder: DateOrder? = nil) throws -> String {
            let dateSeparator = try DateSeparator.guessed(from: string)
            let dateComponents = string.components(separatedBy: CharacterSet.dateSeparators)
            let dateOrder = try dateOrder ?? DateOrder.guessed(from: string)
            
            let dateFormatter = DateFormatter.fixed
            func date(from string: String, format dateFormat: String) -> Date? {
                dateFormatter.dateFormat = dateFormat
                return dateFormatter.date(from: string)
            }
            
            let possibleFormats: [String]
            switch dateOrder {
            case .yearMonthDay:
                possibleFormats = ["yyyy-MM-dd", "yyyy-M-dd", "yyyy-M-d", "yyyy-MMM-dd", "yyyy-MMMM-dd"]
            case .dayMonthYear:
                possibleFormats = ["dd-MM-yyyy", "dd-M-yyyy", "d-M-yyyy", "dd-MMM-yyyy", "dd-MMMM-yyyy"]
            case .monthDayYear:
                possibleFormats = ["MM-dd-yyyy", "M-dd-yyyy", "M-d-yyyy", "MMM-dd-yyyy", "MMMM-dd-yyyy"]
            }
            
            let dateString = Array(dateComponents.prefix(3)).joined(separator: "-")
            for dateFormat in possibleFormats where date(from: dateString, format: dateFormat) != nil {
                return dateFormat.replacingOccurrences(of: "-", with: dateSeparator.rawValue)
            }
            
            throw GuessError.unknownFormat
        }
    }
}
