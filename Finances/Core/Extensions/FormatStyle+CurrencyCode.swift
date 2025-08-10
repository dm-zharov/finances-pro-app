//
//  FormatStyle+CurrencyCode.swift
//
//
//  Created by Dmitriy Zharov on 13.10.2023.
//

import Foundation
import CurrencyKit

extension FormatStyle where Self == Decimal.FormatStyle.Currency {
    public static func currency(_ currency: Currency) -> Self {
        self.currency(code: currency.identifier)
    }
}

extension FormatStyle {
    public static func currency<Value>(_ currency: Currency) -> Self where Self == FloatingPointFormatStyle<Value>.Currency, Value : BinaryFloatingPoint {
        self.currency(code: currency.identifier)
    }
}
