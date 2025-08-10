//
//  Liability.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10.03.2024.
//

import Foundation
import SwiftData
import CurrencyKit
import FoundationExtension

@Model
class Liability: Identifiable {
    /// Type of the asset.
    @Attribute(.allowsCloudEncryption) var type: LiabilityType.RawValue = LiabilityType.other.rawValue
    /// Three-letter lowercase currency code of the balance (ISO 4217 format).
    @Attribute(.allowsCloudEncryption) var currencyCode: CurrencyCode.RawValue = Currency.current.identifier
    /// Name of the asset.
    @Attribute(.allowsCloudEncryption) var name: String = ""
    /// Name of institution holding the asset.
    @Attribute(.allowsCloudEncryption) var institutionName: String?
    
    /// Information regarding credits to the account.
    // public let creditInformation: AccountCreditInformation
    
    /// The date and time of when the asset was added.
    var creationDate: Date = Date.distantPast
    /// The date and time the balance was last updated.
    var lastUpdatedDate: Date = Date.distantPast
     
    /// External identifier.
    var externalIdentifier: UUID = UUID.zero /*< Unique */
    var externalIdentity: [String] = []
    
    init(
        type: LiabilityType = .other,
        currency: Currency = .current,
        name: String = "",
        institutionName: String? = nil,
        creationDate: Date = .now
    ) {
        self.type = type.rawValue
        self.currencyCode = currency.identifier
        self.name = name
        self.institutionName = institutionName
        self.creationDate = creationDate
        self.lastUpdatedDate = creationDate
        self.externalIdentifier = UUID()
        self.externalIdentity = []
    }
}
