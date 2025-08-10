//
//  Crypto.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import Foundation
import SwiftData

@Model
class Crypto: Identifiable {
    /// Source of the crypto aaset.
    @Attribute(.allowsCloudEncryption) var source: Source?
    /// Name of the crypto asset.
    @Attribute(.allowsCloudEncryption) var name: String = ""
    /// Name of provider holding the asset.
    @Attribute(.allowsCloudEncryption) var institutionName: String?
    /// Current balance.
    @Attribute(.allowsCloudEncryption) var balance: Decimal?
    /// Abbreviation for the cryptocurrency,
    @Attribute(.allowsCloudEncryption) var currencyCode: String?
    /// Date/time the asset was created.
    var creationDate: Date = Date.distantPast
    /// The date and time the balance was last updated.
    var lastUpdatedDate: Date = Date.distantPast
    
    init(
        source: Crypto.Source,
        name: String = "",
        institutionName: String? = nil,
        balance: Decimal? = nil,
        currencyCode: String? = nil,
        creationDate: Date = .now
    ) {
        self.source = source
        self.name = name
        self.institutionName = institutionName
        self.balance = balance
        self.currencyCode = currencyCode
        self.creationDate = creationDate
        self.lastUpdatedDate = creationDate
    }
}

extension Crypto {
    enum Source: String, CaseIterable, Codable {
        /// Synced via a wallet, exchange, etc.
        case synced
        /// Balance is managed manually
        case manual
    }
}
