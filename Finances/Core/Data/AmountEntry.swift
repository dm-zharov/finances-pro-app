//
//  AmountEntry.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10/08/2025.
//

import Foundation

public struct AmountEntry<ID>: Identifiable, Hashable, Sendable where ID: Hashable & Sendable {
    /// Identifier
    public let id: ID
    /// Amount.
    public let amount: Decimal
    
    public init(id: ID, amount: Decimal) {
        self.id = id
        self.amount = amount
    }
}

extension AmountEntry where ID == Date {
    public var date: Date { id }
}

extension AmountEntry where ID == String {
    public var name: String { id }
}

extension AmountEntry where ID == String {
    static let unavailable = AmountEntry<String>(
        id: String(localized: "No Data"),
        amount: .zero
    )
}

extension Array where Element == AmountEntry<String> {
    func sum() -> Decimal {
        map(\.amount).sum()
    }
}
