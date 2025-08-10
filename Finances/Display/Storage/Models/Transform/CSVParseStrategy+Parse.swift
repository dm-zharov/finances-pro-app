//
//  CSVParseStrategy+Parse.swift
//  Finances
//
//  Created by Dmitriy Zharov on 01.12.2023.
//

import Foundation
import SwiftCSV
import OrderedCollections
import FoundationExtension
import CurrencyKit

extension CSVParseStrategy: ParseStrategy {
    enum ParseError: Error {
        case missingMapping
        case missingValue
        case missingResult
    }
    
    typealias ParseInput = CSV<Named>
    typealias ParseOutput = Statement
    
    func parse(_ value: ParseInput) throws -> ParseOutput {
        let dateFormatter = ISO8601DateFormatter.default
        let numberFormatter = NumberFormatter.decimal
        numberFormatter.decimalSeparator = decimalSeparator
        
        let statement = Statement()
        
        if let account = header(for: .account), let column = value.columns?[account] {
            statement.assets = column.compactMap { string -> AssetRepresentation? in
                let value = transform[.account]?.transform(string) ?? string
                guard !value.isEmpty else {
                    return nil
                }
                
                var representation = AssetRepresentation()
                representation.name = transform[.account]?.transform(string) ?? string
                representation.id = value
                return representation
            }
        }
        
        if let category = header(for: .category), let column = value.columns?[category] {
            statement.categories = column.compactMap { string -> CategoryRepresentation? in
                let value = transform[.account]?.transform(string) ?? string
                guard !value.isEmpty else {
                    return nil
                }

                var representation = CategoryRepresentation()
                representation.name = transform[.account]?.transform(string) ?? string
                representation.id = value
                return representation
            }
        }
        
        statement.transactions = try value.rows.compactMap { row -> TransactionRepresentation? in
            var representation = TransactionRepresentation()
            representation.currency = decimalCurrency
            
            // Iterate over values in a row
            for header in value.header {
                // Get string by header
                guard let string = row[header] else {
                    throw ParseError.missingValue
                }
                // Get mapping by header
                guard let field = mapping[header] else {
                    continue
                }
                
                guard let value = transform[field]?.transform(string), !value.isEmpty else {
                    continue
                }
                
                switch field {
                case .date:
                    if let date = dateFormatter.date(from: value) {
                        representation.date = date
                    }
                case .category:
                    representation.category = value
                case .payee:
                    representation.payee = value
                case .amount:
                    if let amount = (numberFormatter.number(from: value) as? NSDecimalNumber)?.decimalValue {
                        if transform[.sign] == nil {
                            representation.amount = amount
                        } else {
                            representation.amount = Decimal(signOf: representation.amount, magnitudeOf: amount)
                        }
                    }
                case .currency:
                    representation.currency = Currency(value.lowercased())
                case .notes:
                    representation.notes = value
                case .tags:
                    representation.tags = value.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ",")
                case .account:
                    representation.asset = value
                case .id:
                    representation.id = value
                case .sign:
                    representation.amount._sign = FloatingPointSign(stringLiteral: value)
                }
            }
            
            if representation.validate() {
                return representation
            } else {
                return nil
            }
        }
        
        guard !statement.transactions.isEmpty else {
            throw ParseError.missingResult
        }
        return statement
    }
}

extension FloatingPointSign: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        switch value {
        case Operator.add.rawValue:
            self = .plus
        case Operator.subtract.rawValue:
            self = .minus
        default:
            fatalError()
        }
    }
}

extension FloatingPointSign: CustomStringConvertible {
    public var description: String {
        switch self {
        case .plus:
            Operator.add.rawValue
        case .minus:
            Operator.subtract.rawValue
        }
    }
}

extension FloatingPointSign: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .plus:
            "Plus"
        case .minus:
            "Minus"
        }
    }
}
