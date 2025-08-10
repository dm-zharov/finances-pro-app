//
//  Transaction.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import Foundation
import SwiftData
import FoundationExtension
import CurrencyKit

protocol CompositeIdentifierRepresentable {
    var compositeIdentifierString: String { get }
}

extension Date: @retroactive CustomLocalizedStringConvertible {
    public var localizedDescription: String {
        formatted(DateFormatter.RelativeFormatStyle())
    }
}

@Model
class Transaction: Hashable, Identifiable {
    /// The date and time of the transaction.
    /// - Important: Start of the Day.
    var date: Date = Date.distantPast
    /// Amount of the transaction in numeric format.
    @Attribute(.allowsCloudEncryption) var amount: Decimal = 0.0
    /// Three-letter lowercase currency code of the transaction in ISO 4217 format
    @Attribute(.allowsCloudEncryption) var currencyCode: CurrencyCode.RawValue = Currency.current.identifier
    /// User intervention is required to change this to recurring.
    var status: String = Status.uncleared.rawValue /**< This is default value for CloudKit in case of partial synchronization. Direct initialization uses `.cleared`. */
    /// User-entered transaction notes
    @Attribute(.allowsCloudEncryption) var notes: String?
    /// The date and time of when the transaction was created.
    var creationDate: Date = Date.distantPast
    /// The date and time the balance was last updated.
    var lastUpdatedDate: Date = Date.distantPast
    
    // let creditDebitIndicator: CreditDebitIndicator
    
    /// Unique identifier.
    var externalIdentity: [String] = []
    var externalIdentifier: UUID = UUID.zero /*< Unique */
    
    /// Reciever of payment.
    @Relationship(deleteRule: .nullify, inverse: \Merchant.transactions)
    var payee: Merchant? = nil
    /// Associated manually-managed asset.
    @Relationship(deleteRule: .nullify, inverse: \Asset.transactions)
    var asset: Asset? = nil
    /// Associated category.
    @Relationship(deleteRule: .nullify, inverse: \Category.transactions)
    var category: Category? = nil
    /// Array of Tag objects.
    @Relationship(deleteRule: .nullify, inverse: \Tag.transactions)
    var tags: [Tag]? = []
    
    init(
        date: Date = .now,
        amount: Decimal = 0.0,
        currency: Currency = .current,
        status: Status = Status.cleared,
        notes: String? = nil,
        creationDate: Date = .now
    ) {
        self.date = Calendar.current.startOfDay(for: date, in: .gmt)
        self.amount = amount
        self.currencyCode = currency.identifier
        self.status = status.rawValue
        self.notes = notes
        self.creationDate = creationDate
        self.lastUpdatedDate = creationDate
        self.externalIdentity = []
        self.externalIdentifier = UUID()
    }
}

extension Transaction {
    var currency: Currency {
        Currency(currencyCode)
    }
}

extension Transaction: ExternallyIdentifiable {
    static var propertiesForIdentities: [PartialKeyPath<Transaction>] {
        [\Transaction.externalIdentifier, \Transaction.externalIdentity] + propertiesForCompositeIdentifier
    }
    
    var identities: [String] {
        [externalIdentifier.uuidString, compositeIdentifierString] + externalIdentity
    }
    
    convenience init(externalIdentifier: UUID) {
        self.init(); self.externalIdentifier = externalIdentifier
    }
}

extension Transaction: CompositeIdentifierRepresentable {
    static var propertiesForCompositeIdentifier: [PartialKeyPath<Transaction>] {
        [\Transaction.date, \Transaction.amount, \Transaction.currencyCode]
    }
    
    var compositeIdentifierString: String {
        [date.formatted(.iso8601.year().month().day()), amount.formatted(.number.grouping(.never)), currencyCode].joined(separator: ";")
    }
}

extension Transaction {
    static func unique(_ identity: String, modelContext: ModelContext) -> Transaction {
        if let externalIdentifier = UUID(uuidString: identity),
           let transaction: Transaction = modelContext.existingModel(with: externalIdentifier) {
            return transaction
        } else if let transaction = try? modelContext.fetchSingle(
            FetchDescriptor<Transaction>(predicate: #Predicate<Transaction>{ $0.externalIdentity.contains(identity) })
        ) {
            return transaction
        } else {
            let transaction = Transaction()
            modelContext.insert(transaction)
            return transaction
        }
    }
}

extension Transaction {
    enum Status: String, CaseIterable {
        /// User has reviewed the transaction
        case cleared
        /// User has not yet reviewed the transaction (includes imported transactions).
        case uncleared
        /// Transaction is linked to a recurring expense.
        case recurring
        /// Transaction is listed as a suggested transaction for an existing recurring expense.
        case recurringSuggested
    }
    
    struct Relationship: OptionSet {
        let rawValue: Int

        static let payee    = Relationship(rawValue: 1 << 0)
        static let asset    = Relationship(rawValue: 1 << 1)
        static let category = Relationship(rawValue: 1 << 2)
        static let tags     = Relationship(rawValue: 1 << 3)
        static let repetition = Relationship(rawValue: 1 << 4)

        static let none: Relationship = []
        static let all: Relationship = [payee, asset, category, tags, repetition]
    }
}

// MARK: - Balance

extension Transaction {
    func performWithRelationshipUpdates(_ relationship: Relationship = .all, _ operationsOnTransaction: () -> Void) {
        guard let modelContext = modelContext else {
            fatalError()
        }
        
        // Balance adjustment
        if relationship.contains(.asset), let asset = asset {
            let currency = Currency(asset.currencyCode)
            asset.balance -= amount(in: currency)
            asset.lastUpdatedDate = .now
        }
        
        operationsOnTransaction()
        
        if isDeleted {
            // Clean up merchants
            if relationship.contains(.payee), let payee, payee.transactions?.count == 1 {
                modelContext.delete(payee)
            }
            // Clean up tags
            if relationship.contains(.tags), let tags {
                for tag in tags where tag.transactions?.count == 1 {
                    modelContext.delete(tag)
                }
            }
        } else {
            // Balance adjustment
            if relationship.contains(.asset), let asset = asset {
                let currency = Currency(asset.currencyCode)
                asset.balance += amount(in: currency)
                asset.lastUpdatedDate = .now
            }
        }
        
        if relationship.contains(.category), let category {
            category.lastUpdatedDate = .now
        }
    }
}

// MARK: - FetchDescriptor

extension Transaction {
    static func prefetchDescriptor(
        predicate: Predicate<Transaction>? = nil,
        sortBy: [SortDescriptor<Transaction>] = .defaultValue
    ) -> FetchDescriptor<Transaction> {
        let sortBy = sortBy + [SortDescriptor(\.creationDate, order: .reverse)]
        var fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: sortBy)
        fetchDescriptor.relationshipKeyPathsForPrefetching = [
            \Transaction.payee, \Transaction.asset, \Transaction.category, \Transaction.tags
        ]
        return fetchDescriptor
    }
}

// MARK: - Group

extension Transaction {
    enum GroupBy: String, CaseIterable, Codable, CustomLocalizedStringResourceConvertible, DefaultValueProvidable {
        case none
        case date
        case payee
        case category
        case asset
        case currency
        
        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .none:
                "None"
            case .date:
                "Date"
            case .payee:
                "Payee"
            case .category:
                "Category"
            case .asset:
                "Asset"
            case .currency:
                "Currency"
            }
        }
        
        static let defaultValue: Transaction.GroupBy = .date
    }
}

// MARK: - Sort

extension Transaction {
    static func sortDescriptor(_ sortOrder: Transaction.SortOrder = .defaultValue) -> SortDescriptor<Transaction> {
        switch sortOrder {
        case .date:
            SortDescriptor(\.date, order: .reverse)
        case .amount:
            SortDescriptor(\.amount, order: .reverse)
        }
    }
    
    enum SortOrder: String, CaseIterable, Codable, CustomLocalizedStringResourceConvertible, DefaultValueProvidable {
        case date, amount
        
        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .date:
                "Date"
            case .amount:
                "Amount"
            }
        }
        
        static let defaultValue: Transaction.SortOrder = .date
    }
}

extension [SortDescriptor<Transaction>] {
    static let defaultValue: [SortDescriptor<Transaction>] = [Transaction.sortDescriptor()]
}

// MARK: - Info

extension Transaction {
    /// Report the range of dates over which there are transactions.
    static func dateRange(modelContext: ModelContext) -> ClosedRange<Date> {
        let startDescriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .forward)])
        let endDescriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])

        guard
            let start = try? modelContext.fetchSingle(startDescriptor)?.date,
            let end = try? modelContext.fetchSingle(endDescriptor)?.date
        else {
            return .distantPast ... .distantFuture
        }

        return start ... end
    }

    /// Reports the total number of transactions.
    static func totalTransactions(modelContext: ModelContext) -> Int {
        (try? modelContext.fetchCount(FetchDescriptor<Transaction>())) ?? 0
    }
}

extension Transaction {
    var payeeName: String {
        payee?.name ?? String(localized: "No Payee")
    }
    
    var categoryName: String {
        category?.name ?? String(localized: "Uncategorized")
    }
    
    var assetName: String {
        asset?.name ?? String(localized: "Unaccounted")
    }
    
    var currencyName: String {
        Currency(currencyCode).localizedDescription
    }
}
