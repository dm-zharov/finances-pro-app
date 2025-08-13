//
//  AssetListConfiguration.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 07.01.2024.
//

import WidgetKit
import AppIntents
import SwiftData
import FoundationExtension

struct AssetListConfiguration: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Assets Configuration"

    // An example configurable parameter.
    @Parameter(title: "Assets", size: [
        .systemSmall: IntentCollectionSize(min: 1, max: 2),
        .systemMedium: IntentCollectionSize(min: 1, max: 4),
    ], query: AssetListConfiguration.AssetListOptionsProvider())
    var assets: [AssetEntity]?
}

extension AssetListConfiguration {
    private struct AssetListOptionsProvider: EntityStringQuery {
        @Dependency
        var modelContainer: ModelContainer
        
        func entities(for identifiers: [AssetEntity.ID]) async throws -> [AssetEntity] {
            try await AssetEntityQuery().entities(for: identifiers)
        }
        
        func entities(matching string: String) async throws -> IntentItemCollection<AssetEntity> {
            try await AssetEntityQuery().entities(matching: string)
        }
        
        func suggestedEntities() async throws -> IntentItemCollection<AssetEntity> {
            try await AssetEntityQuery().suggestedEntities()
        }
        
        func defaultResult() async -> [AssetEntity]? {
            try? await AssetModelQuery(modelContainer: modelContainer)
                .models()
                .sorted(by: \.lastUpdatedDate, order: .reverse)
                .prefix(2)
                .map { representation in
                    AssetEntity(representation: representation)
                }
        }
    }
}
