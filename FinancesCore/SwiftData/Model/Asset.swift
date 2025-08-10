//
//  Asset.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import Foundation
import SwiftData
import CurrencyKit
import FoundationExtension
import AppUI

@Model
class Asset: Identifiable {
    /// Type of the asset.
    @Attribute(.allowsCloudEncryption) var type: AssetType.RawValue = AssetType.other.rawValue
    /// Current balance of the asset.
    @Attribute(.allowsCloudEncryption) var balance: Decimal = Decimal.zero
    /// Three-letter lowercase currency code of the balance (ISO 4217 format).
    @Attribute(.allowsCloudEncryption) var currencyCode: CurrencyCode.RawValue = Currency.current.identifier
    /// Name of the asset.
    @Attribute(.allowsCloudEncryption) var name: String = ""
    /// Name of institution holding the asset.
    @Attribute(.allowsCloudEncryption) var institutionName: String?
    /// The date and time of when the asset was added.
    var creationDate: Date = Date.distantPast
    /// The date and time the balance was last updated.
    var lastUpdatedDate: Date = Date.distantPast
    
    /// If true, the asset will be hidden from user.
    var isHidden: Bool = false
    
    /// External identifier.
    var externalIdentifier: UUID = UUID.zero /*< Unique */
    var externalIdentity: [String] = []

    /// Transaction list associated with the asset.
    @Relationship(deleteRule: .nullify)
    var transactions: [Transaction]? = []
    
    init(
        type: AssetType = .other,
        balance: Decimal = .zero,
        currency: Currency = .current,
        name: String = "",
        institutionName: String? = nil,
        isHidden: Bool = false,
        creationDate: Date = .now
    ) {
        self.type = type.rawValue
        self.balance = balance
        self.currencyCode = currency.identifier
        self.name = name
        self.institutionName = institutionName
        self.creationDate = creationDate
        self.lastUpdatedDate = creationDate
        self.isHidden = isHidden
        self.externalIdentifier = UUID()
        self.externalIdentity = []
    }
}

extension Asset: ExternallyIdentifiable {
    static var propertiesForIdentities: [PartialKeyPath<Asset>] {
        [\Asset.externalIdentifier, \Asset.externalIdentity, \Asset.name]
    }
    
    var identities: [String] {
        [externalIdentifier.uuidString, name] + externalIdentity
    }
    
    convenience init(externalIdentifier: UUID) {
        self.init(); self.externalIdentifier = externalIdentifier
    }
}

// MARK: - Identity

extension Asset {
    static func retrieve(_ externalIdentifier: UUID, modelContext: ModelContext) -> Asset? {
        if let asset = try? modelContext.fetchSingle(
            FetchDescriptor<Asset>(predicate: #Predicate<Asset>{ $0.externalIdentifier == externalIdentifier })
        ) {
            return asset
        } else {
            return nil
        }
    }
    
    static func unique(_ identity: String, modelContext: ModelContext) -> Asset {
        if let asset = try? modelContext.prefetch(Asset.propertiesForIdentities).first(where: { $0.identities.contains(identity) }) {
            return asset
        } else {
            return create(identity, modelContext: modelContext)
        }
    }
    
    static func create(_ identity: String, modelContext: ModelContext) -> Asset {
        let asset = Asset(name: identity)
        asset.setIdentityString(identity)
        modelContext.insert(asset)
        return asset
    }
}

// MARK: - Group

extension Asset {
    enum GroupBy: String, CaseIterable, CustomLocalizedStringResourceConvertible, DefaultValueProvidable {
        case type
        case currency
        
        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .type:
                "Kind"
            case .currency:
                "Currency"
            }
        }
        
        static let defaultValue: Asset.GroupBy = .type
    }
}

// MARK: - Sort

extension Asset {
    static func sortDescriptor(_ sortOrder: SortOrder = .defaultValue) -> SortDescriptor<Asset> {
        switch sortOrder {
        case .name:
            SortDescriptor(\.name, order: .forward)
        case .date:
            SortDescriptor(\.lastUpdatedDate, order: .forward)
        }
    }
    
    enum SortOrder: String, CaseIterable, Identifiable, DefaultValueProvidable {
        case name
        case date
        var id: Self { self }
        
        static let defaultValue: Asset.SortOrder = .name
    }
}

// MARK: - Filter

extension Sequence where Element == Asset {
    func filter(by type: AssetType) -> [Element] {
        filter { AssetType(rawValue: $0.type) == type }
    }
}

extension Asset {
    var symbolName: String {
        let assetType = AssetType(rawValue: type, default: .other)
        switch assetType {
        case .cash:
            if let sfSymbolsName = Locale.Currency(currencyCode).sfSymbolsName {
                return sfSymbolsName
            } else {
                return assetType.symbolName
            }
        default:
            return assetType.symbolName
        }
    }
}
