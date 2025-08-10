//
//  Recurrence.swift
//  Finances
//
//  Created by Dmitriy Zharov on 05.01.2024.
//

import Foundation
import SwiftData
import FoundationExtension
import CurrencyKit

@Model
class Recurrence: Hashable, Identifiable {
    /// Amount of the recurrence in numeric format.
    @Attribute(.allowsCloudEncryption) var amount: Decimal = 0.0
    /// Three-letter lowercase currency code of the recurrence in ISO 4217 format
    @Attribute(.allowsCloudEncryption) var currencyCode: CurrencyCode.RawValue = Currency.current.identifier
    
    /// Repetition info.
    var startDate: Date
    var endDate: Date?
    
    /// The date and time of when the recurrence was created.
    var creationDate: Date = Date.now
    
    /// Unique identifier.
    var externalIdentifier: UUID = UUID.zero
    
    /// Reciever of recurrence.
    @Relationship
    var payee: Merchant? = nil
    /// Associated manually-managed asset.
    @Relationship
    var asset: Asset? = nil
    /// Associated category.
    @Relationship
    var category: Category? = nil
    
    init(
        amount: Decimal = 0.0,
        currency: Currency = .current,
        startDate: Date = .now,
        endDate: Date? = nil
    ) {
        self.creationDate = .now
        self.amount = amount
        self.currencyCode = currency.identifier
        self.startDate = Calendar.current.startOfDay(for: startDate, in: .gmt)
        self.endDate = Calendar.current.startOfDay(for: startDate, in: .gmt)
    }
}
