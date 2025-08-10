//
//  CategoryGroup.swift
//  Finances
//
//  Created by Dmitriy Zharov on 22.02.2024.
//

import Foundation
import SwiftData

@Model
class CategoryGroup: Identifiable {
    /// The name of the category group.
    @Attribute(.allowsCloudEncryption) var name: String = ""
    
    /// Transaction list associated with the category.
    @Relationship(deleteRule: .nullify)
    var categories: [Category]? = []
    
    /// Unique identifier.
    var externalIdentifier: UUID = UUID() /*< Unique */
    
    init(name: String = "") {
        self.name = name
        self.externalIdentifier = UUID()
    }
}

extension CategoryGroup {
    static func retrieve(_ externalIdentifier: UUID, modelContext: ModelContext) -> CategoryGroup? {
        if let categoryGroup = try? modelContext.fetchSingle(
            FetchDescriptor<CategoryGroup>(predicate: #Predicate<CategoryGroup>{ $0.externalIdentifier == externalIdentifier })
        ) {
            return categoryGroup
        } else {
            return nil
        }
    }
}

extension CategoryGroup: ExternallyIdentifiable {
    var externalIdentity: [String] {
        get { [name] }
        set { assertionFailure() }
    }
    
    
}
