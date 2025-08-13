//
//  CurrencyRatesStore.swift
//  Finances
//
//  Created by Dmitriy Zharov on 11.11.2023.
//

import Foundation
import CoreData
import FoundationExtension
import OSLog
import CurrencyKit

final class CurrencyRatesStore: CurrencyRatesProvider {
    typealias DataSource = [Date: [CurrencyCode.RawValue: Decimal]]
    
    private let global: Currency = .usd
    
    // MARK: - Properties
    
    nonisolated(unsafe) var dataSource: DataSource = [:]
    
    public func rate(for currency: Currency, relativeTo counter: Currency, on date: Date) -> Decimal {
        guard currency != counter else {
            return 1.0
        }
        
        guard !dataSource.isEmpty else {
            return .nan
        }
        
        guard currency != global else {
            return 1.0 / rate(for: counter, relativeTo: currency, on: date)
        }
        
        guard counter == global else {
            return rate(for: currency, relativeTo: global, on: date) / rate(for: counter, relativeTo: global, on: date)
        }
        
        guard let values = dataSource[date] else {
            return rate(for: currency, relativeTo: global, on: dataSource.keys.nearest(for: date))
        }
        
        if let rate = values[currency.normalizedIdentifier] {
            return rate
        } else {
            assertionFailure()
            return .nan
        }
    }

    @MainActor
    public static let shared = CurrencyRatesStore()
    @MainActor
    private init() {
        updateRates();
        Task {
            await observeStoreChanges();
        }
    }
}

extension CurrencyRatesStore {
    func observeStoreChanges() async {
        for await _ in NotificationCenter.default.notifications(
            named: PersistentController.objectsDidChange, object: PersistentController.public
        ) {
            await updateRates()
        }
    }
    
    @MainActor
    func updateRates() {
        self.dataSource = CurrencyRates.dictionaryRepresentation()
    }
}

extension Collection where Element == Date {
    func nearest(for target: Date) -> Date {
        let sortedDates = self.sorted()
        
        if let maxDate = sortedDates.last, maxDate <= target {
            return maxDate
        }

        if let minDate = sortedDates.first, minDate >= target {
            return minDate
        }

        var nearestDate: Date = .distantFuture
        var minimumDifference: TimeInterval = .infinity

        for date in sortedDates {
            let difference = target.timeIntervalSince(date).magnitude
            if difference < minimumDifference {
                nearestDate = date
                minimumDifference = difference
            }
        }

        return nearestDate
    }
}
