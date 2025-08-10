//
//  Tag.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import Foundation
import SwiftData

@Model
class Tag: Identifiable {
    /// User-defined name of tag.
    @Attribute(.allowsCloudEncryption) var name: String = "" /*< Unique */
    /// Transaction list associated with the transaction.
    @Relationship(deleteRule: .nullify)
    var transactions: [Transaction]? = []
    
    init(name: String) {
        precondition(!name.isEmpty)
        self.name = name
    }
}

extension Tag: ExternallyIdentifiable {
    var externalIdentifier: String {
        get { name }
        set { name = newValue }
    }
    
    var externalIdentity: [String] {
        get { [externalIdentifier] }
        set { }
    }
    
    static var propertiesForIdentities: [PartialKeyPath<Tag>] {
        [\Tag.name]
    }
    
    var identities: [String] {
        [name]
    }
}

// MARK: - Unique

extension Tag {
    static func unique(_ identity: String, modelContext: ModelContext) -> Tag {
        if let tag = try? modelContext.fetchSingle(
            FetchDescriptor<Tag>(predicate: #Predicate<Tag>{ $0.name == identity })
        ) {
            return tag
        } else {
            return create(identity, modelContext: modelContext)
        }
    }
    
    static func create(_ identity: String, modelContext: ModelContext) -> Tag {
        let tag = Tag(name: identity)
        modelContext.insert(tag)
        return tag
    }
}
