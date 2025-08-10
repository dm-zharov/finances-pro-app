//
//  ArithmeticService.swift
//  Finances
//
//  Created by Dmitriy Zharov on 16.10.2023.
//

import Foundation
import Combine
import SwiftData
import CurrencyKit
import FoundationExtension

// MARK: - Asset

extension Asset {
    func balance(in currency: Currency) -> Decimal {
        balance / Currency(currencyCode).rate(relativeTo: currency)
    }
}

extension Sequence where Element == Asset {
    func sum(in currency: Currency) -> Decimal {
        return map { asset in asset.balance(in: currency) }.sum()
    }
}

// MARK: - Budget

extension Budget {
    func amount(in currency: Currency) -> Decimal {
        amount / Currency(currencyCode).rate(relativeTo: currency)
    }
}

// MARK: - Transaction

extension Transaction {
    func amount(in currency: Currency) -> Decimal {
        amount / Currency(currencyCode).rate(relativeTo: currency, on: date)
    }
}

extension Sequence where Element == Transaction {
    func sum(in currency: Currency) -> Decimal {
        map { transaction in transaction.amount(in: currency) }.sum()
    }
    
    func average(in currency: Currency) -> Decimal {
        map { transaction in transaction.amount(in: currency) }.average()
    }
    
    func median(in currency: Currency) -> Decimal {
        let sorted = map { transaction in transaction.amount(in: currency) }.sorted()
        let count = sorted.count
        
        if count.isMultiple(of: 2) {
            return (sorted[(count - 1) / 2] + sorted[count / 2]) / 2
        } else {
            return sorted[count / 2]
        }
    }
}

extension Currency {
    func rate(
        relativeTo counter: Currency,
        on date: Date = Calendar.autoupdatingCurrent.startOfDay(for: .now, in: .gmt)
    ) -> Decimal {
        CurrencyRatesStore.shared.rate(for: self, relativeTo: counter, on: date)
    }
}
