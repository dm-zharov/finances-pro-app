//
//  AssetModelQuery.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.01.2024.
//

import Foundation
import SwiftData

actor AssetModelQuery: ModelStringQuery {
    typealias Model = Asset
    
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: ModelContext(modelContainer)
        )
    }
    
    func models(matching string: String) async throws -> [AssetRepresentation] {
        let fetchDescriptor = FetchDescriptor<Asset>(
            predicate: #Predicate<Asset> { asset in
                asset.name.localizedStandardContains(string)
            },
            sortBy: [SortDescriptor(\Asset.name, order: .forward)]
        )
        return try modelContext.fetch(fetchDescriptor).map(\.objectRepresentation)
    }
    
    func models(for externalIdentifiers: [Model.ExternalID]) async throws -> [AssetRepresentation] {
        let fetchDescriptor = FetchDescriptor<Model>(
            predicate: #Predicate<Model> { model in
                externalIdentifiers.contains(model.externalIdentifier)
            }
        )
        return try modelContext.fetch(fetchDescriptor).map(\.objectRepresentation)
    }
    
    func model(for externalIdentifier: Model.ExternalID) async throws -> AssetRepresentation? {
        modelContext.existingModel(Asset.self, with: externalIdentifier).map(\.objectRepresentation)
    }
}
