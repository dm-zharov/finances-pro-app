//
//  AssetEntity.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 07.01.2024.
//

import AppIntents
import SwiftUI
import SwiftData
import AppUI
import FoundationExtension
import CurrencyKit

struct AssetEntityQuery: EntityStringQuery {
    @Dependency
    var modelContainer: ModelContainer
    
    func entities(for identifiers: [AssetEntity.ID]) async throws -> [AssetEntity] {
        if identifiers.count == 1, identifiers.first == .zero {
            return [.empty]
        }
        return try await AssetModelQuery(modelContainer: modelContainer).models(for: identifiers).map { representation in
            AssetEntity(representation: representation)
        }
    }
    
    func entities(matching string: String) async throws -> IntentItemCollection<AssetEntity> {
        let entities = try await AssetModelQuery(modelContainer: modelContainer).models(matching: string).map { representation in
            AssetEntity(representation: representation)
        }
        return IntentItemCollection(items: entities)
    }
    
    func suggestedEntities() async throws -> IntentItemCollection<AssetEntity> {
        let entities = try await AssetModelQuery(modelContainer: modelContainer).models().map { representation in
            AssetEntity(representation: representation)
        }
        return IntentItemCollection(
            sections: AssetType.allCases.map { assetType in
                IntentItemSection(
                    assetType.localizedStringResource,
                    items: entities.filter { $0.type == assetType }.map { entity in
                        IntentItem(entity)
                    }
                )
            }
        )
    }
}

struct AssetEntity: Identifiable, Sendable {
    var id: UUID
    @Property(title: "Display Name")
    var name: String
    @Property(title: "Kind")
    var type: AssetType
    @Property(title: "Balance")
    var balance: Double
    @Property(title: "Currency Code")
    var currencyCode: CurrencyCode.RawValue
    
    #if !os(watchOS)
    var badgeProminence: BadgeProminence = .standard
    #endif
    
    init(id: UUID, name: String, type: AssetType, balance: Double, currency: Currency) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.currencyCode = currency.identifier
    }
}

extension AssetEntity {
    static var empty: AssetEntity {
        AssetEntity(
            id: .zero,
            name: String(localized: "Unaccounted"),
            type: .other,
            balance: .nan,
            currency: Currency.current
        )
    }
    
    static var placeholder: AssetEntity {
        AssetEntity(
            id: .zero,
            name: "Apple Card",
            type: .checking,
            balance: 1234.56,
            currency: "usd"
        )
    }
}

extension AssetEntity {
    init(representation: AssetRepresentation) {
        self.init(
            id: UUID(uuidString: representation.id) ?? .zero,
            name: representation.name,
            type: representation.type,
            balance: Double(truncating: representation.balance),
            currency: representation.currency
        )
    }
}

extension AssetEntity: AppEntity {
    static let defaultQuery = AssetEntityQuery()
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Asset"
    var displayRepresentation: AppIntents.DisplayRepresentation {
        let title = LocalizedStringResource(verbatim: name)
        let subtitle: LocalizedStringResource?
        let image: DisplayRepresentation.Image?
        if id != .zero {
            subtitle = LocalizedStringResource(verbatim: balance.formatted(.currency(code: currencyCode)))
            image = displayRepresentationImage
        } else {
            subtitle = nil
            image = nil
        }

        return DisplayRepresentation(title: title, subtitle: subtitle, image: image)
    }
    
    #if os(watchOS)
    var displayRepresentationImage: DisplayRepresentation.Image? {
        return DisplayRepresentation.Image(
            systemName: type.symbolName,
            symbolConfiguration: PlatformImage.SymbolConfiguration(scale: .large)
        )
    }
    #else
    var displayRepresentationImage: DisplayRepresentation.Image? {
        switch badgeProminence {
        case .standard, .increased:
            var systemName: String = type.symbolName
            if !systemName.contains(".circle") { systemName += ".circle" }
            if !systemName.contains(".fill") { systemName += ".fill" }
            return DisplayRepresentation.Image(
                systemName: systemName,
                symbolConfiguration: PlatformImage.SymbolConfiguration(hierarchicalColor: .accent)
                    .applying(PlatformImage.SymbolConfiguration(scale: .large))
            )
        case .decreased:
            fallthrough
        default:
            return DisplayRepresentation.Image(
                systemName: type.symbolName,
                symbolConfiguration: PlatformImage.SymbolConfiguration(scale: .large)
            )
        }
    }
    #endif
}
