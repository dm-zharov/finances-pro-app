//
//  LMCrypto.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.09.2023.
//

import Foundation

struct LMCrypto: Decodable, Identifiable {
    /// Unique identifier for a manual crypto account (no ID for synced accounts)
    let id: UInt64?
    /// Unique identifier for a synced crypto account (no ID for manual accounts, multiple currencies may have the same zabo_account_id)
    let zaboAccountId: UInt64
    let source: Source
    /// Name of the crypto asset
    let name: String
    /// Display name of the crypto asset (as set by user)
    let displayName: String
    /// Current balance
    let balance: String
    /// Date/time the balance was last updated in ISO 8601 extended format
    @StringRepresentation<Date>
    var balanceAsOf: String
    /// Abbreviation for the cryptocurrency
    let currency: String
    /// The current status of the crypto account. Either active or in error.
    let status: String
    /// Name of provider holding the asset
    let institutionName: String
    /// Date/time the asset was created in ISO 8601 extended format
    @StringRepresentation<Date>
    var createdAt: String
}

extension LMCrypto {
    enum Source: String, Decodable {
        /// Synced via a wallet, exchange, etc.
        case synced
        /// Balance is managed manually
        case manual
    }
}
