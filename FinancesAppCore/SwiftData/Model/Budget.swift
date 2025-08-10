//
//  Budget.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.03.2024.
//

import Foundation
import SwiftData
import FoundationExtension
import CurrencyKit

@Model
class Budget: Identifiable {
    /// The limit of budget in numeric format.
    @Attribute(.allowsCloudEncryption) var amount: Decimal = 0.0
    /// Three-letter lowercase currency code of the transaction in ISO 4217 format
    @Attribute(.allowsCloudEncryption) var currencyCode: CurrencyCode.RawValue = Currency.current.identifier
    /// The date period for budget.
    @Attribute(.allowsCloudEncryption) var repeatInterval: DatePeriod.RawValue = DatePeriod.month.rawValue
    /// The start date for budget.
    @Attribute(.allowsCloudEncryption) var startDate: Date = Calendar.autoupdatingCurrent.startOfMonth(for: .now, in: .gmt)
    /// The date when the budget was created.
    var creationDate: Date = Date.now
    
    /// Transaction list associated with the category.
    @Relationship(deleteRule: .nullify)
    var categories: [Category]? = []
    
    var externalIdentifier: UUID = UUID()
    var externalIdentity: [String] = []
    
    init(
        amount: Decimal = .zero,
        currency: Currency = .current,
        repeatInterval: DatePeriod = .month,
        startDate: Date = Calendar.autoupdatingCurrent.startOfMonth(for: .now, in: .gmt),
        categories: [Category]? = []
    ) {
        self.amount = amount
        self.currencyCode = currency.identifier
        self.repeatInterval = repeatInterval.rawValue
        self.startDate = Calendar.current.startOfDay(for: startDate, in: .gmt)
        self.creationDate = .now
        self.categories = categories
    }
}

extension Budget {
    var displayName: String {
        "Some"
    }
}

extension Budget: ExternallyIdentifiable {
    typealias ExternalID = UUID
}
