//
//  EnvironmentValues+Currency.swift
//  Finances
//
//  Created by Dmitriy Zharov on 05.11.2023.
//

import SwiftUI
import CurrencyKit

struct CurrencyKey: EnvironmentKey {
    static var defaultValue: Currency {
        Currency.current
    }
}

struct CurrencyConversionKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

struct CurrencyConversionModeKey: EnvironmentKey {
    static let defaultValue: Binding<Bool>? = nil
}

extension EnvironmentValues {
    var currency: Currency {
        get { self[CurrencyKey.self] }
        set { self[CurrencyKey.self] = newValue }
    }
    
    var isCurrencyConversionEnabled: Bool {
        get { self[CurrencyConversionKey.self] }
        set { self[CurrencyConversionKey.self] = newValue }
    }
    
    var currencyConversionMode: Binding<Bool>? {
        get { self[CurrencyConversionModeKey.self] }
        set { self[CurrencyConversionModeKey.self] = newValue }
    }
}
