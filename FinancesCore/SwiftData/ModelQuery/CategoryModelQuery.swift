//
//  CategoryModelQuery.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.01.2024.
//

import Foundation
import SwiftData

actor CategoryModelQuery: ModelStringQuery {
    typealias Model = Category
    
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: ModelContext(modelContainer)
        )
    }
    
    func models(matching string: String) async throws -> [CategoryRepresentation] {
        let fetchDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate<Category> { category in
                category.name.localizedStandardContains(string)
            }
        )
        return try modelContext.fetch(fetchDescriptor).map(\.objectRepresentation)
    }
    
    func models(for externalIdentifiers: [Model.ExternalID]) async throws -> [CategoryRepresentation] {
        let fetchDescriptor = FetchDescriptor<Model>(
            predicate: #Predicate<Model> { model in
                externalIdentifiers.contains(model.externalIdentifier)
            }
        )
        return try modelContext.fetch(fetchDescriptor).map(\.objectRepresentation)
    }
    
    func model(with externalIdentifier: Model.ExternalID) async throws -> CategoryRepresentation? {
        modelContext.existingModel(Category.self, with: externalIdentifier).map(\.objectRepresentation)
    }
}
