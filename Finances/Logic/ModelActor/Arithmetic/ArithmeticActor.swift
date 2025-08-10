//
//  ArithmeticActor.swift
//  Finances
//
//  Created by Dmitriy Zharov on 01.11.2023.
//

import Foundation
import SwiftData
import CurrencyKit
import FoundationExtension

@globalActor
actor ArithmeticActor: ModelActor {
    static let shared = ArithmeticActor(modelContainer: .default)
    
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    
    private init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: ModelContext(modelContainer)
        )
    }

    func sum(
        predicate: Predicate<Transaction>,
        in currency: Currency
    ) throws -> [CategoryAmount] {
        #if DEBUG
        dispatchPrecondition(condition: .notOnQueue(.main))
        #endif
        
        var fetchDescriptor = FetchDescriptor<Transaction>(predicate: predicate)
        fetchDescriptor.relationshipKeyPathsForPrefetching = [\Transaction.category]
        
        let transactions = try modelContext.fetch(fetchDescriptor)
        
        return Dictionary(grouping: transactions) { transaction in
            transaction.categoryName
        }.mapValues { transactions in
            amount(for: transactions, in: currency)
        }.map { category, amount in
            CategoryAmount(category: category, amount: amount)
        }.sorted(by: \.amount)
    }

    func sum(
        predicate: Predicate<Transaction>,
        granularity: Calendar.Component = .day,
        in currency: Currency
    ) throws -> [DateAmount] {
        #if DEBUG
        dispatchPrecondition(condition: .notOnQueue(.main))
        #endif
        
        let fetchDescriptor = FetchDescriptor<Transaction>(predicate: predicate)
        let fetchResult = try modelContext.fetch(fetchDescriptor)
        
        let universal = Calendar.universal

        var dictionary = Dictionary(grouping: fetchResult) { transaction in
            if granularity == .day {
                return transaction.date /* Optimization */
            } else {
                return universal.startOf(granularity, for: transaction.date) ?? transaction.date
            }
        }.mapValues { transactions in
            amount(for: transactions, in: currency)
        }
        
        var minDate: Date = .distantFuture
        var maxDate: Date = .distantPast
        dictionary.keys.forEach { date in
            minDate = min(minDate, date)
            maxDate = max(maxDate, date)
        }
        
        if var checkingDate = universal.date(byAdding: granularity, value: 1, to: minDate) {
            while checkingDate <= maxDate {
                if dictionary[checkingDate] == nil {
                    dictionary[checkingDate] = 0 // Set missing dates amount to zero
                }
                if let nextDate = universal.date(byAdding: granularity, value: 1, to: checkingDate) {
                    checkingDate = nextDate
                } else {
                    break
                }
            }
        }

        return dictionary.map { date, amount in
            DateAmount(date: date, amount: amount)
        }.sorted(by: \.date)
    }
}

private extension ArithmeticActor {
    func amount(for transactions: [Transaction], in currency: Currency) -> Decimal {
        transactions.map { transaction in transaction.amount(in: currency) }.reduce(0, +)
    }
}

private extension Calendar {
    static let universal = {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = .gmt
        return calendar
    }()
}

public struct CategoryAmount: Codable, Hashable, Sendable {
    /// Amount.
    public let amount: Decimal
    /// Data Group.
    public let category: String
    
    public init(category: String, amount: Decimal) {
        self.category = category
        self.amount = amount
    }
}

extension Sequence where Element == CategoryAmount {
    public func sum() -> Decimal {
        reduce(.zero) { $0 + $1.amount }
    }
}

extension Collection where Element == CategoryAmount {
    public func average() -> Decimal {
        return sum() / Decimal(isEmpty ? 1 : count)
    }
}

extension Sequence where Element: AdditiveArithmetic {
    public func sum() -> Element {
        reduce(.zero, +)
    }
}

public struct DateAmount: Codable, Hashable, Sendable {
    /// Date Group.
    public let date: Date
    /// Amount.
    public let amount: Decimal
    
    public init(date: Date, amount: Decimal) {
        self.date = date
        self.amount = amount
    }
}

extension DateAmount: Identifiable {
    public var id: Date { date }
}
