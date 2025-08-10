//
//  ModelContext+Extension.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.01.2024.
//

import Foundation
import SwiftData
import AppIntents

extension ModelContext {
    func prefetch<T>(_ propertiesToFetch: [PartialKeyPath<T>]) throws -> [T] where T : PersistentModel {
        var fetchDescriptor = FetchDescriptor<T>()
        fetchDescriptor.propertiesToFetch = propertiesToFetch
        return try fetch(fetchDescriptor)
    }
}

extension ModelContext {
    static let didChange: Notification.Name = Notification.Name("ModelContextDidChange")
}

// MARK: - Fetch

extension ModelContext {
    public func fetchSingle<T>(_ descriptor: FetchDescriptor<T>) throws -> T? {
        try fetch(descriptor, limit: 1).first
    }
    
    public func fetch<T>(_ descriptor: FetchDescriptor<T>, limit: Int) throws -> [T] where T : PersistentModel {
        var descriptor = descriptor
        descriptor.fetchLimit = limit
        return try fetch(descriptor)
    }
}

extension ModelContext {
    func existingModel<T>(_ model: T.Type = T.self, with externalIdentifier: T.ExternalID) -> T? where T: PersistentModel & ExternallyIdentifiable {
        guard let identifier = try? _identifier(for: model, with: externalIdentifier) else {
            return nil
        }
        if let model: T = registeredModel(for: identifier) {
            return model
        } else {
            return try? _fetchSingle(model, with: externalIdentifier)
        }
    }
    
    private func _identifier<T>(for model: T.Type = T.self, with externalIdentifier: T.ExternalID) throws -> PersistentIdentifier? where T: PersistentModel & ExternallyIdentifiable {
        if let identifier = ModelContainer._cache[externalIdentifier.entityIdentifierString] {
            return identifier
        } else {
            let identifier = try _fetchSingle(model, with: externalIdentifier)?.persistentModelID
            ModelContainer._cache[externalIdentifier.entityIdentifierString] = identifier
            return identifier
        }
    }
    
    private func _fetchSingle<T>(_ model: T.Type, with externalIdentifier: T.ExternalID) throws -> T? where T: PersistentModel & ExternallyIdentifiable {
        if model == Asset.self {
            let externalIdentifier = externalIdentifier as! Asset.ExternalID
            return try fetchSingle(FetchDescriptor(predicate: #Predicate<Asset> { model in
                model.externalIdentifier == externalIdentifier
            })) as! T?
        }
        
        if model == Budget.self {
            let externalIdentifier = externalIdentifier as! Budget.ExternalID
            return try fetchSingle(FetchDescriptor(predicate: #Predicate<Budget> { model in
                model.externalIdentifier == externalIdentifier
            })) as! T?
        }

        if model == Category.self {
            let externalIdentifier = externalIdentifier as! Category.ExternalID
            return try fetchSingle(FetchDescriptor(predicate: #Predicate<Category> { model in
                model.externalIdentifier == externalIdentifier
            })) as! T?
        }
        
        if model == CategoryGroup.self {
            let externalIdentifier = externalIdentifier as! CategoryGroup.ExternalID
            return try fetchSingle(FetchDescriptor(predicate: #Predicate<CategoryGroup> { model in
                model.externalIdentifier == externalIdentifier
            })) as! T?
        }

        if model == Transaction.self {
            let externalIdentifier = externalIdentifier as! Transaction.ExternalID
            return try fetchSingle(FetchDescriptor(predicate: #Predicate<Transaction> { model in
                model.externalIdentifier == externalIdentifier
            })) as! T?
        }
        
        if model == Merchant.self {
            let name = externalIdentifier as! Merchant.ExternalID
            return try fetchSingle(FetchDescriptor(predicate: #Predicate<Merchant> { model in
                model.name == name
            })) as! T?
        }
        
        assertionFailure("Unsupported type \(model)")

        return nil
    }
}

private extension ModelContainer {
    static var _cache: Dictionary<String, PersistentIdentifier> = [:]
}
