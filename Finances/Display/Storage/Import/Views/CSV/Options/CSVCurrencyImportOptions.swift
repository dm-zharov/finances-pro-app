//
//  CSVCurrencyImportOptions.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.11.2023.
//

import SwiftUI
import OrderedCollections
import CurrencyKit
import FoundationExtension

struct CSVCurrencyImportOptions: View {
    let data: OrderedSet<String>
    @Binding var strategy: CSVParseStrategy

    @State private var dictionary: [String: CSVParseAction] = [:]
    
    private let formatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.minimumIntegerDigits = 2
        numberFormatter.generatesDecimalNumbers = true
        return numberFormatter
    }()
    
    var body: some View {
        Section {
            ForEach(data, id: \.self) { row in
                picker(for: row)
            }
        } header: {
            Text("Options")
        }
        .onChange(of: dictionary) {
            strategy.transform[.currency] = .replace(dictionary)
        }
        .onChange(of: data, initial: true) { oldValue, newValue in
            if oldValue != newValue || dictionary.isEmpty {
                parse()
            }
        }
    }
    
    private func picker(for row: String) -> some View {
        Picker(selection: $dictionary[row]) {
            Text("Unknown")
                .tag(Optional<CSVParseAction>.none)
            Section("Replace with") {
                ForEach(Currency.supportedCurrencies.sorted(by: \.localizedDescription)) { currency in
                    CurrencyItemRow(currency)
                        .tag(Optional<CSVParseAction>.some(
                            .replace(with: currency.identifier.uppercased(), description: currency.localizedDescription)
                        ))
                }
            }
        } label: {
            Text(row)
        }
        .pickerStyle(.menu)
    }
    
    private func parse() {
        var dictionary: [String: CSVParseAction] = [:]
        for currency in Currency.supportedCurrencies {
            let lowercased = currency.identifier.lowercased()
            let uppercased = currency.identifier.uppercased()
            
            if data.contains(lowercased) {
                dictionary[lowercased] = .replace(with: uppercased, description: currency.localizedDescription)
            } else if data.contains(uppercased) {
                dictionary[uppercased] = .replace(with: uppercased)
            }
        }
        self.dictionary = dictionary
    }
}

#Preview {
    CSVCurrencyImportOptions(data: [], strategy: .constant(.init()))
}
