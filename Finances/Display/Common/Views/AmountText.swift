//
//  AmountText.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.11.2023.
//

import SwiftUI
import CurrencyKit

struct AmountText: View {
    #if os(iOS)
    @Environment(\.redactionReasons) private var redactionReasons
    #endif
    @Environment(\.isCurrencyConversionEnabled) private var isCurrencyConversionEnabled
    @Environment(\.currency) private var currency
    
    let value: Decimal
    let currencyCode: CurrencyCode.RawValue
    let date: Date
    
    #if os(macOS)
    var body: Text /* Optimizes Table scrolling performance on macOS */ {
        content
    }
    #else
    var body: some View {
        content.privacySensitive()
    }
    #endif
    
    var content: Text /* Optimizes scrolling performance of Table on macOS */ {
        #if os(iOS)
        guard !redactionReasons.contains(.privacy) else {
            return Text(1_000.formatted(.currency(currency)))
        }
        #endif

        if isCurrencyConversionEnabled, currencyCode != currency.identifier {
            return Text("\(Image(systemName: "arrow.left.arrow.right")) ").foregroundStyle(.accent) + Text(
                (value / Currency(currencyCode).rate(relativeTo: currency, on: date)).formatted(.currency(currency))
            )
        } else {
            return Text(value.formatted(.currency(.init(currencyCode))))
        }
    }
    
    init(_ value: Decimal, currencyCode: CurrencyCode.RawValue, on date: Date = .now) {
        self.value = value
        self.currencyCode = currencyCode
        self.date = date
    }
}

#Preview {
    AmountText(.zero, currencyCode: Currency.current.identifier)
}
