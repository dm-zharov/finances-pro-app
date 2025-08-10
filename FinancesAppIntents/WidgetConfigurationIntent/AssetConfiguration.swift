//
//  AssetConfiguration.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 07.01.2024.
//

import WidgetKit
import AppIntents
import SwiftData
import FoundationExtension

struct AssetConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Asset Configuration"
    static var description = IntentDescription("This is an example widget.")
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    // An example configurable parameter.
    @Parameter(title: "Asset", optionsProvider: AssetConfiguration.AssetOptionsProvider())
    var asset: AssetEntity?
}

extension AssetConfiguration {
    private struct AssetOptionsProvider: EntityStringQuery {
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
        
        func defaultResult() async -> AssetEntity? {
            try? await AssetModelQuery(modelContainer: modelContainer)
                .models()
                .sorted(by: \.lastUpdatedDate, order: .reverse)
                .first
                .map { representation in
                    AssetEntity(representation: representation)
                }
        }
    }
}

