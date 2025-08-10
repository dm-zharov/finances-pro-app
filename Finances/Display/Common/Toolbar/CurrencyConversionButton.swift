//
//  CurrencyConversionButton.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.11.2023.
//

import SwiftUI
import AppUI
import SwiftData
import FoundationExtension

struct CurrencyConversionButton: View {
    @Environment(\.isCurrencyConversionEnabled) private var isCurrencyConversionEnabled
    @Environment(\.currencyConversionMode) private var currencyConversionMode
    @Environment(\.currency) private var currency
    
    private var selection: Binding<Bool> {
        currencyConversionMode ?? .constant(isCurrencyConversionEnabled)
    }
    
    var body: some View {
        Toggle("Convert All", systemImage: systemImage, isOn: selection)
    }
    
    var systemImage: String {
        if let sfSymbolsName = Locale.Currency(currency.identifier).sfSymbolsName {
            return "\(sfSymbolsName).arrow.circlepath"
        } else {
            return "dollarsign.arrow.circlepath"
        }
    }
}

#Preview {
    CurrencyConversionButton()
}
