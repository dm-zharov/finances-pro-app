//
//  AssetType.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.09.2023.
//

import Foundation
import FoundationExtension
import SwiftUI
import AppUI
import AppIntents

enum AssetType: String, CaseIterable, Codable, Sendable {
    case cash
    case checking
    case savings
    case brokerage
    case other
    
    var intValue: Int {
        switch self {
        case .cash:
            0
        case .checking:
            1
        case .savings:
            2
        case .brokerage:
            3
        case .other:
            4
        }
    }
}

extension AssetType: Comparable {
    static func < (lhs: AssetType, rhs: AssetType) -> Bool {
        lhs.intValue < rhs.intValue
    }
}

extension AssetType: CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .cash:
            "Physical Cash"
        case .checking:
            "Checking Account"
        case .savings:
            "Savings Account"
        case .brokerage:
            "Brokerage Account"
        case .other:
            "Other"
        }
    }
}

extension AssetType {
    var symbolName: String {
        switch self {
        case .cash:
            "c.circle"
        case .checking:
            "creditcard"
        case .savings:
            "building.columns"
        case .brokerage:
            "chart.line.uptrend.xyaxis"
        case .other:
            "folder"
        }
    }
}

extension AssetType: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Kind of Asset"
    static let caseDisplayRepresentations: [AssetType : DisplayRepresentation] = [
        .cash: DisplayRepresentation(
            title: "Physical Cash",
            subtitle: "Banknotes, coins",
            image: .init(systemName: "c")
        ),
        .checking: DisplayRepresentation(
            title: "Checking Account",
            subtitle: "Card, digital wallet",
            image: .init(systemName: "creditcard")
        ),
        .savings: DisplayRepresentation(
            title: "Savings Account",
            subtitle: "Grows over time",
            image: .init(systemName: "building.columns")
        ),
        .brokerage: DisplayRepresentation(
            title: "Brokerage Account",
            subtitle: "Investments",
            image: .init(systemName: "chart.line.uptrend.xyaxisl")
        ),
        .other: DisplayRepresentation(
            title: "Other",
            subtitle: "Estate, goods, etc.",
            image: .init(systemName: "folder")
        )
    ]
}

extension Optional<AssetType>: @retroactive CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .some(let wrapped):
            wrapped.localizedStringResource
        case .none:
            "Unknown"
        }
    }
    
    public var symbolName: String {
        switch self {
        case .some(let wrapped):
            wrapped.symbolName
        case .none:
            Wrapped.defaultValue.symbolName
        }
    }
}

extension AssetType: DefaultValueProvidable {
    static let defaultValue: AssetType = .other
}
