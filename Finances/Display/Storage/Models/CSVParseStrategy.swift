//
//  CSVParseStrategy.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.11.2023.
//

import Foundation
import SwiftCSV
import CurrencyKit

extension CSV<Named> {
    typealias Header = String
}

struct CSVParseStrategy: Hashable, Codable {
    var mapping: [ParseInput.Header: Statement.Field] = [:]
    var transform: [Statement.Field: CSVColumnTransformer] = [:]
    
    // Locale
    var decimalCurrency: Currency = .usd
    var decimalSeparator: String = "."
}

extension CSVParseStrategy {
    func header(for field: Statement.Field) -> String? {
        mapping.first(where: { $1 == field }).map(\.key)
    }
}
