//
//  Merchant.swift
//  Finances
//
//  Created by Dmitriy Zharov on 26.09.2023.
//

import Foundation
import SwiftData

@Model
class Merchant: Identifiable {
    /// The name of the merchant.
    @Attribute(.allowsCloudEncryption) var name: String = "" /*< Unique */
    /// Transaction list associated with the merchant.
    @Relationship(deleteRule: .nullify)
    var transactions: [Transaction]? = []
    
    init(name: String) {
        precondition(!name.isEmpty)
        self.name = name
    }
}

extension Merchant {
    static var propertiesForIdentities: [PartialKeyPath<Merchant>] {
        [\Merchant.name]
    }
    
    var identities: [String] {
        [name]
    }
}

// MARK: - Unique

extension Merchant {
    static func unique(_ identity: String, modelContext: ModelContext) -> Merchant? {
        if let merchant = try? modelContext.fetchSingle(
            FetchDescriptor<Merchant>(predicate: #Predicate<Merchant>{ $0.name == identity })
        ) {
            return merchant
        } else {
            return create(identity, modelContext: modelContext)
        }
    }
    
    static func create(_ identity: String, modelContext: ModelContext) -> Merchant {
        let merchant = Merchant(name: identity)
        modelContext.insert(merchant)
        return merchant
    }
}

extension Merchant: ExternallyIdentifiable {
    var externalIdentifier: String {
        get { name }
        set { name = newValue }
    }
    
    var externalIdentity: [String] {
        get { [name] }
        set { assertionFailure() }
    }
}
