//
//  CategoryType.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 07.01.2024.
//

import Foundation
import FoundationExtension
import AppIntents

struct CategoryType: OptionSet {
    let rawValue: Int
    
    static let income    = CategoryType(rawValue: 1 << 0)
    static let excluded  = CategoryType(rawValue: 1 << 1)

    static let none: CategoryType = []
}

extension CategoryType: CustomLocalizedStringConvertible {
    var localizedDescription: String {
        var strings: [String] = []
        if contains([.income]) {
            strings.append(
                String(localized: "Income", comment: "Type of category")
            )
        }
        if contains(.excluded) {
            strings.append(
                String(localized: "Excluded", comment: "Type of category")
            )
        }
        return strings.joined(separator: ", ")
    }
}

extension CategoryType: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Kind of Category"
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(verbatim: localizedDescription)
        )
    }
}
