//
//  Category.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2022.
//

import Foundation
import SwiftUI
import SwiftData
import AppUI
import FoundationExtension
import AppIntents

protocol ExternallyIdentifiable: AnyObject {
    associatedtype ExternalID: EntityIdentifierConvertible
    
    var externalIdentifier: ExternalID { get set }
    var externalIdentity: [String] { get set }
}

extension ExternallyIdentifiable {
    func setIdentityString(_ string: String) {
        guard !string.isEmpty else {
            assertionFailure(); return
        }
        
        if let externalIdentifier = ExternalID.entityIdentifier(for: string) {
            self.externalIdentifier = externalIdentifier
        } else if !externalIdentity.contains(where: { $0 == string }) {
            self.externalIdentity.append(string)
        }
    }
    
    var identities: [String] {
        [externalIdentifier.entityIdentifierString] + externalIdentity
    }
}

@Model
class Category: Identifiable {
    /// The name of the category.
    @Attribute(.allowsCloudEncryption) var name: String = ""
    /// The image for the category.
    @Attribute(.allowsCloudEncryption) var symbolName: String?
    /// The color for the category.
    var colorName: String?
    /// The date and time of when the category was created.
    var creationDate: Date = Date.distantPast
    /// The date and time the balance was last updated.
    var lastUpdatedDate: Date = Date.distantPast
    
    /// If true, the transactions in this category will be treated as income.
    var isIncome: Bool = false
    /// If true, the transactions in this category will be excluded from totals.
    var isTransient: Bool = false
    
    /// Unique identifier.
    var externalIdentifier: UUID = UUID() /*< Unique */
    var externalIdentity: [String] = []

    /// Transaction list associated with the category.
    @Relationship(deleteRule: .nullify)
    var transactions: [Transaction]? = []
    #if BudgetFeature
    @Relationship(deleteRule: .nullify)
    var budgets: [Budget]? = []
    #endif

    /// Group associated with the category.
    @Relationship(deleteRule: .nullify)
    var group: CategoryGroup? = nil
    
    init(
        name: String = "",
        symbolName: SymbolName? = nil,
        colorName: ColorName? = nil,
        isIncome: Bool = false,
        isTransient: Bool = false,
        creationDate: Date = .now
    ) {
        self.name = name
        self.symbolName = symbolName?.rawValue
        self.colorName = colorName?.rawValue
        self.creationDate = creationDate
        self.lastUpdatedDate = creationDate
        self.isIncome = isIncome
        self.isTransient = isTransient
        self.externalIdentity = []
        self.externalIdentifier = UUID()
    }
}

extension Category {
    var type: CategoryType {
        switch (isIncome, isTransient) {
        case (false, false):
            return [.none]
        case (true, false):
            return [.income]
        case (false, true):
            return [.excluded]
        case (true, true):
            return [.income, .excluded]
        }
    }
}

extension Category: ExternallyIdentifiable {
    static var propertiesForIdentities: [PartialKeyPath<Category>] {
        [\Category.externalIdentifier, \Category.externalIdentity, \Category.name]
    }
    
    var identities: [String] {
        [externalIdentifier.uuidString, name] + externalIdentity
    }
    
    convenience init(externalIdentifier: UUID) {
        self.init(); self.externalIdentifier = externalIdentifier
    }
}

// MARK: - Unique

extension Category {
    static func retrieve(_ externalIdentifier: UUID, modelContext: ModelContext) -> Category? {
        if let category = try? modelContext.fetchSingle(
            FetchDescriptor<Category>(predicate: #Predicate<Category>{ $0.externalIdentifier == externalIdentifier })
        ) {
            return category
        } else {
            return nil
        }
    }
    
    static func unique(_ identity: String, modelContext: ModelContext) -> Category {
        if let category = try? modelContext.prefetch(Category.propertiesForIdentities).first(where: { $0.identities.contains(identity) }) {
            return category
        } else {
            return create(identity, modelContext: modelContext)
        }
    }
    
    static func create(_ identity: String, modelContext: ModelContext) -> Category {
        let category = Category(name: identity)
        category.setIdentityString(identity)
        modelContext.insert(category)
        return category
    }
}

// MARK: - Predicate

extension Category {
    static func predicate(isIncome: Bool, includeTransient: Bool) -> Predicate<Category> {
        if includeTransient {
            return #Predicate<Category> { category in
                category.isIncome == isIncome
            }
        } else {
            return #Predicate<Category> { category in
                category.isIncome == isIncome && category.isTransient == false
            }
        }
    }
}

// MARK: - Order

protocol Reorderable {
    var reorderIdentifier: UUID { get }
}

@available(iOSApplicationExtension, unavailable)
extension Collection where Element: Reorderable {
    typealias Order = [UUID]
    
    func ordered(by key: String) -> [Element] {
        let order = UserDefaults.shared.identifiers(forKey: key)
        return sorted(by: { lhs, rhs in
            guard let lhsIndex = order.firstIndex(of: lhs.reorderIdentifier) else { return false }
            guard let rhsIndex = order.firstIndex(of: rhs.reorderIdentifier) else { return true }
            return lhsIndex < rhsIndex
        })
    }

    /// Moves all the elements at the specified offsets to the specified destination offset, preserving ordering.
    func reorder(_ key: String, fromOffsets source: IndexSet, toOffset destination: Int) {
        var ordered = ordered(by: key).map(\.reorderIdentifier)
        ordered.move(fromOffsets: source, toOffset: destination)
        UserDefaults.shared.set(ordered, forKey: key)
    }

}

private extension KeyValueStore {
    func identifiers(forKey defaultName: String) -> [UUID] {
        if let strings: [String] = array(forKey: defaultName) as? [String] {
            return strings.compactMap { uuidString in
                UUID(uuidString: uuidString)
            }
        } else {
            return []
        }
    }
    
    func set(_ identifiers: [UUID]?, forKey key: String) {
        if let identifiers {
            set(identifiers.map { $0.uuidString }, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }
}


extension Asset: Reorderable {
    var reorderIdentifier: UUID {
        externalIdentifier
    }
}

extension Category: Reorderable {
    var reorderIdentifier: UUID {
        externalIdentifier
    }
}

extension CategoryGroup: Reorderable {
    var reorderIdentifier: UUID {
        externalIdentifier
    }
}

extension AssetRepresentation: Reorderable {
    var reorderIdentifier: UUID {
        UUID(uuidString: id) ?? .zero
    }
}

extension CategoryRepresentation: Reorderable {
    var reorderIdentifier: UUID {
        UUID(uuidString: id) ?? .zero
    }
}
