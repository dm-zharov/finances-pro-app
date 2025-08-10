//
//  ModelQuery.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.01.2024.
//

import Foundation
import SwiftData

protocol ModelQuery: ModelActor {
    associatedtype Model: PersistentModel & ObjectRepresentable
    
    func models() async throws -> [Self.Model.Representation]
    func models(for identifiers: [Model.ID]) async throws -> [Self.Model.Representation]
}

protocol ModelStringQuery: ModelQuery {
    func models(matching string: String) async throws -> [Self.Model.Representation]
}

extension ModelQuery {
    func models() async throws -> [Self.Model.Representation] {
        let fetchDescriptor = FetchDescriptor<Model>()
        return try modelContext.fetch(fetchDescriptor).map(\.objectRepresentation)
    }
    
    func models(for identifiers: [PersistentIdentifier]) async throws -> [Self.Model.Representation] {
        let fetchDescriptor = FetchDescriptor<Model>(
            predicate: #Predicate<Model> { model in
                identifiers.contains(model.persistentModelID)
            }
        )
        return try modelContext.fetch(fetchDescriptor, limit: identifiers.count).map(\.objectRepresentation)
    }
}
