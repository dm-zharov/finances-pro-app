//
//  StoreQuery.swift
//  Finances
//
//  Created by Dmitriy Zharov on 01.11.2023.
//

import Foundation
import SwiftData

@globalActor
actor StoreQuery: ModelActor  {
    static let shared = StoreQuery(modelContainer: .default)
    
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    
    init(modelContainer: ModelContainer) {
        let modelContext = ModelContext(modelContainer)
        modelContext.autosaveEnabled = false
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: modelContext
        )
    }
    
    func save() throws {
        defer {
            NotificationCenter.default.post(name: ModelContext.didChange, object: modelContext)
        }
        try modelContext.save()
    }
    
    func rollback() {
        modelContext.rollback()
    }
}

// MARK: - Store

extension StoreQuery {
    @discardableResult
    func store(_ representations: [AssetRepresentation], ignoringDuplicates: Bool = false) throws -> (inserted: [Asset], duplicated: [Asset]) {
        var assetIDs: [String: Asset] = [:]
        
        var inserted: [Asset] = []
        var duplicated: [Asset] = []
        
        if ignoringDuplicates == false {
            try modelContext.prefetch(Asset.propertiesForIdentities).forEach { asset in
                asset.identities.forEach { identity in
                    assetIDs[identity] = asset
                }
            }
        }
        
        for representation in representations {
            if let asset = assetIDs[representation.id], ignoringDuplicates == false {
                duplicated.append(asset)
            } else {
                let asset = Asset.create(representation.id, modelContext: modelContext)
                asset.objectRepresentation = representation
                assetIDs[representation.id] = asset; inserted.append(asset)
            }
        }
        
        return (inserted, duplicated)
    }
    
    @discardableResult
    func store(_ representations: [CategoryRepresentation], ignoringDuplicates: Bool = false) throws -> (inserted: [Category], duplicated: [Category]) {
        var categoryIDs: [String: Category] = [:]
        
        var inserted: [Category] = []
        var duplicated: [Category] = []
        
        if ignoringDuplicates == false {
            try modelContext.prefetch(Category.propertiesForIdentities).forEach { category in
                category.identities.forEach { identity in
                    categoryIDs[identity] = category
                }
            }
        }
        
        for representation in representations {
            if let category = categoryIDs[representation.id], ignoringDuplicates == false {
                duplicated.append(category)
            } else {
                let category = Category.create(representation.id, modelContext: modelContext)
                category.objectRepresentation = representation
                categoryIDs[representation.id] = category; inserted.append(category)
            }
        }
        
        return (inserted, duplicated)
    }
    
    @discardableResult
    func store(_ representations: [TransactionRepresentation], ignoringDuplicates: Bool = false) throws -> (inserted: [Transaction], duplicated: [Transaction]) {
        var transactionIDs: [String: Transaction] = [:]
        var merchantIDs: [String: Merchant] = [:]
        var assetIDs: [String: Asset] = [:]
        var categoryIDs: [String: Category] = [:]
        
        var tagIDs: [String: Tag] = [:]
        
        var inserted: [Transaction] = []
        var duplicated: [Transaction] = []
        
        if ignoringDuplicates == false {
            try modelContext.prefetch(Transaction.propertiesForIdentities).forEach { transaction in
                transaction.identities.forEach { identity in
                    transactionIDs[identity] = transaction
                }
            }
            try modelContext.prefetch(Merchant.propertiesForIdentities).forEach { merchant in
                merchant.identities.forEach { identity in
                    merchantIDs[identity] = merchant
                }
            }
            try modelContext.prefetch(Asset.propertiesForIdentities).forEach { asset in
                asset.identities.forEach { identity in
                    assetIDs[identity] = asset
                }
            }
            try modelContext.prefetch(Tag.propertiesForIdentities).forEach { tag in
                tag.identities.forEach { identity in
                    tagIDs[identity] = tag
                }
            }
        }
        
        // Transaction
        for representation in representations {
            if let transaction = transactionIDs[representation.id] ?? transactionIDs[representation.compositeIdentifierString], ignoringDuplicates == false {
                duplicated.append(transaction)
            } else {
                let transaction = Transaction()
                modelContext.insert(transaction)
                transaction.setObjectRepresentation(representation, withRelationshipUpdates: .none)
                
                // Payee
                if !representation.payee.isEmpty {
                    if let merchant = merchantIDs[representation.payee] {
                        transaction.payee = merchant
                    } else {
                        let merchant = Merchant.create(representation.payee, modelContext: modelContext)
                        transaction.payee = merchant
                        merchantIDs[representation.payee] = merchant
                    }
                }
                
                // Asset
                if let identity = representation.asset {
                    if let asset = assetIDs[identity] {
                        transaction.asset = asset
                    } else {
                        let asset = Asset.create(identity, modelContext: modelContext)
                        transaction.asset = asset
                        assetIDs[identity] = asset
                    }
                }
                
                // Category
                if let identity = representation.category {
                    if let category = categoryIDs[identity] {
                        transaction.category = category
                    } else {
                        let category = Category.create(identity, modelContext: modelContext)
                        transaction.category = category
                        categoryIDs[identity] = category
                    }
                }
                
                transaction.tags = representation.tags.compactMap { identity -> Tag? in
                    if !identity.isEmpty {
                        if let tag = tagIDs[identity] {
                            return tag
                        } else {
                            let tag = Tag.create(identity, modelContext: modelContext)
                            tagIDs[identity] = tag
                            return tag
                        }
                    } else {
                        return nil
                    }
                }
                
                transactionIDs[representation.id] = transaction; inserted.append(transaction)
            }
        }
        
        return (inserted, duplicated)
    }
    
    @discardableResult
    func store(_ representation: TransactionRepresentation, ignoringDuplicates: Bool = false) throws -> (inserted: Transaction?, duplicated: Transaction?) {
        guard ignoringDuplicates == true else {
            let (inserted, duplicated) = try store([representation], ignoringDuplicates: false)
            return (inserted.first, duplicated.first)
        }
        
        let transaction = Transaction()
        modelContext.insert(transaction)
        
        transaction.performWithRelationshipUpdates {
            transaction.objectRepresentation = representation
        }
        
        return (transaction, nil)
    }
}
