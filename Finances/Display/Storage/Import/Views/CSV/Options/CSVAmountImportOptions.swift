//
//  CSVAmountImportOptions.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.11.2023.
//

import SwiftUI
import OrderedCollections
import CurrencyKit
import FoundationExtension

struct CSVAmountImportOptions: View {
    let data: OrderedSet<String>
    @Binding var strategy: CSVParseStrategy
    
    @State private var dictionary: [String: CSVParseAction] = [:]

    @State private var isInverse: Bool = false
    
    var body: some View {
        Section {
            if strategy.mapping.values.contains(.currency) == false, strategy.transform[.currency] == nil {
                Picker(selection: $strategy.decimalCurrency) {
                    ForEach(Currency.supportedCurrencies.sorted(by: \.localizedDescription), id: \.self) { currency in
                        CurrencyItemRow(currency)
                    }
                } label: {
                    Text("Currency")
                }
            }
            if strategy.mapping.values.contains(.sign) == false, strategy.transform[.sign] == nil {
                Toggle("Sign Inversion", isOn: $isInverse)
            }
            Picker(selection: $strategy.decimalSeparator) {
                Text(".")
                    .tag(".")
                Text(",")
                    .tag(",")
                
            } label: {
                Text("Decimal Separator")
            }
        } header: {
            Text("Options")
        }
        .onChange(of: dictionary) {
            strategy.transform[.amount] = .replace(dictionary)
        }
        .onChange(of: strategy.decimalSeparator) {
            parse()
        }
        .onChange(of: isInverse) {
            parse()
        }
        .onChange(of: data, initial: true) {
            parse()
        }
    }
    
    private func parse() {
        let formatter = NumberFormatter.decimal
        formatter.decimalSeparator = strategy.decimalSeparator
        
        var dictionary: [String: CSVParseAction] = [:]
        for row in data {
            if let number = formatter.number(from: row) as? NSDecimalNumber {
                dictionary[row] = .replace(with: isInverse ? number.multiplying(by: NSDecimalNumber(decimal: -1)).stringValue : number.stringValue)
            } else {
                dictionary[row] = .replace(with: .empty)
            }
        }
        self.dictionary = dictionary
    }
}

#Preview {
    CSVAmountImportOptions(data: [], strategy: .constant(.init()))
}
