//
//  CurrencySettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 05.11.2023.
//

import SwiftUI
import FoundationExtension
import CurrencyKit
import FinancesCore

struct CurrencySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage(SettingKey.currencyCode, store: .shared) private var currency: Currency = .current

    @State private var currenciesInUse: [Currency] = []
    
    var body: some View {
        VStack {
            Form {
                Section {
                    currencyPicker
                } header: {
                    Text("Base Currency")
                } footer: {
                    Text("Determines the currency for statistics and transaction conversions. You can change it anytime.")
                        .textStyle(.footer)
                }
                
                if !currenciesInUse.isEmpty {
                    Section {
                        ForEach(currenciesInUse) { currencyInUse in
                            LabeledContent {
                                AmountText(currencyInUse.rate(relativeTo: currency), currencyCode: currencyInUse.identifier)
                                    .environment(\.isCurrencyConversionEnabled, false)
                                    .unredacted()
                            } label: {
                                Text(currencyInUse.localizedDescription)
                            }
                        }
                    } header: {
                        Text("Currency Rates")
                    } footer: {
                        if let dates = .some(CurrencyRatesStore.shared.dataSource.keys.sorted()), let latestDate = dates.last, let startDate = dates.first {
                            Text("Last updated \(DateFormatter.relative.string(from: latestDate)).\nHistorical rates from \(DateFormatter.relative.string(from: startDate)).")
                                .textStyle(.footer)
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
        .navigationTitle("Currencies")
        .onAppear {
            self.currenciesInUse = Currency.suggestedEntities(modelContext: modelContext)
        }
    }
    
    @ViewBuilder
    var currencyPicker: some View {
        #if os(iOS)
        NavigationLink {
            CurrencySelectorView(selection: $currency, suggestions: currenciesInUse)
        } label: {
            LabeledContent {
                Text(currency.localizedDescription)
            } label: {
                Text("Currency")
            }
        }
        #else
        CurrencyPicker(selection: $currency, suggestions: currenciesInUse)
            .pickerStyle(.menu)
        #endif
    }
}

#Preview {
    NavigationStack {
        CurrencySettingsView()
    }
}
