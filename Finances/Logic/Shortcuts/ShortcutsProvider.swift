//
//  ShortcutsProvider.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 07.01.2024.
//

import AppIntents
import SwiftData
import FoundationExtension
import SwiftUI

final class ShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NewTransaction(),
            phrases: [
                "New Transaction in \(.applicationName)",
                "Record Transaction in \(.applicationName)"
            ],
            shortTitle: "New Transaction",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: OpenAsset(),
            phrases: [
                "Open \(\.$asset) in \(.applicationName)",
                "Show \(\.$asset) in \(.applicationName)"
            ],
            shortTitle: "Open Asset",
            systemImageName: "folder",
            parameterPresentation: .init(for: \.$asset, summary: .init("Open \(\.$asset)"), optionsCollections: {
                AppShortcutOptionsCollection(ShortcutsProvider.AssetOptionsProvider(), title: "Assets", systemImageName: "list.bullet")
            })
        )
    }
    
    static let shortcutTileColor: ShortcutTileColor = .tangerine
}

extension ShortcutsProvider {
    private struct AssetOptionsProvider: DynamicOptionsProvider {
        @Dependency
        var modelContainer: ModelContainer
        
        func results() async throws -> some ResultsCollection {
            try await AssetModelQuery(modelContainer: modelContainer)
                .models()
                .sorted(by: \.lastUpdatedDate, order: .reverse)
                .map { representation in
                    var entity = AssetEntity(representation: representation)
                    entity.badgeProminence = .decreased
                    return entity
                }
        }
    }
}
