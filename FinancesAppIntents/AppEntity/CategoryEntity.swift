//
//  CategoryEntity.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 07.01.2024.
//

import AppIntents
import AppUI
import SwiftData
import FoundationExtension

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

struct CategoryEntityQuery: EntityStringQuery {
    @Dependency
    var modelContainer: ModelContainer
    
    func entities(for identifiers: [CategoryEntity.ID]) async throws -> [CategoryEntity] {
        if identifiers.count == 1, identifiers.first == .zero {
            return [.empty]
        }
        return try await CategoryModelQuery(modelContainer: modelContainer).models(for: identifiers).map { representation in
            CategoryEntity(representation: representation)
        }
    }
    
    func entities(matching string: String) async throws -> [CategoryEntity] {
        try await CategoryModelQuery(modelContainer: modelContainer).models(matching: string).map { representation in
            CategoryEntity(representation: representation)
        }
    }
    
    func suggestedEntities() async throws -> [CategoryEntity] {
        try await CategoryModelQuery(modelContainer: modelContainer).models().map { representation in
            CategoryEntity(representation: representation)
        }
    }
}

struct CategoryEntity: Identifiable {
    var id: UUID
    @Property(title: "Display Name")
    var name: String
    @Property(title: "Kind")
    var type: CategoryType
    var symbolName: SymbolName!
    var colorName: ColorName!
    
    init(id: UUID, name: String, type: CategoryType, symbolName: SymbolName, colorName: ColorName) {
        self.id = id
        self.name = name
        self.type = type
        self.symbolName = symbolName
        self.colorName = colorName
    }
}

extension CategoryEntity {
    static var empty: CategoryEntity {
        CategoryEntity(
            id: .zero,
            name: String(localized: "Uncategorized"),
            type: .none,
            symbolName: .defaultValue,
            colorName: .defaultValue
        )
    }
}

extension CategoryEntity {
    init(representation: CategoryRepresentation) {
        self.init(
            id: UUID(uuidString: representation.id) ?? .zero,
            name: representation.name,
            type: representation.type,
            symbolName: representation.symbolName,
            colorName: representation.colorName
        )
    }
}

extension CategoryEntity: AppEntity {
    static let defaultQuery = CategoryEntityQuery()
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    var displayRepresentation: AppIntents.DisplayRepresentation {
        let title = LocalizedStringResource(verbatim: name)
        let subtitle = LocalizedStringResource(verbatim: type.localizedDescription)
        
        let image: AppIntents.DisplayRepresentation.Image?
        if id != .zero {
            var systemName: String = symbolName.rawValue
            if !systemName.contains(".circle") { systemName += ".circle" }
            if !systemName.contains(".fill") { systemName += ".fill" }
            image = .init(
                systemName: systemName,
                symbolConfiguration: .init(paletteColors: [.white, .named(colorName)])
            )
        } else {
            image = nil
        }

        return AppIntents.DisplayRepresentation(title: title, subtitle: subtitle, image: image)
    }
}
