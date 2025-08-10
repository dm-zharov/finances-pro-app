//
//  CurrencyPicker.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.12.2023.
//

import SwiftUI
import CurrencyKit
import FoundationExtension

struct CurrencyPicker: View {
    @Binding var selection: Currency
    let suggestions: [Currency]
    
    var body: some View {
        Picker(selection: $selection) {
            if !suggestions.isEmpty {
                Section("Suggestions") {
                    ForEach(suggestions, id: \.self) { currency in
                        CurrencyItemRow(currency)
                    }
                }
            }

            Section("All Currencies") {
                ForEach(Currency.supportedCurrencies.sorted(by: \.localizedDescription)) { currency in
                    CurrencyItemRow(currency)
                }
            }
        } label: {
            Text("Currency")
        }
    }
    
    init(selection: Binding<Currency>, suggestions: [Currency] = []) {
        self._selection = selection
        self.suggestions = suggestions
    }
}

#Preview {
    CurrencyPicker(selection: .constant(.current))
}
