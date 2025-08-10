//
//  LiabilityType.swift
//  Finances
//
//  Created by Dmitriy Zharov on 08.11.2023.
//

import Foundation
import AppUI
import AppIntents

enum LiabilityType: String, CaseIterable, Sendable, Codable {
    case loan
    case credit
    case other
}

extension LiabilityType: CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .loan:
            "Loan"
        case .credit:
            "Credit"
        case .other:
            "Other"
        }
    }
}

extension LiabilityType {
    var symbolName: String {
        switch self {
        case .loan:
            "folder"
        case .credit:
            "folder"
        case .other:
            "folder"
        }
    }
}

extension LiabilityType: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Kind of Liability"
    static let caseDisplayRepresentations: [LiabilityType : DisplayRepresentation] = [
        .loan: DisplayRepresentation(
            title: "Loan",
            subtitle: "Fixed-rate over a specified term",
            image: .init(systemName: "folder")
        ),
        .credit: DisplayRepresentation(
            title: "Credit",
            subtitle: "Flexible borrowing",
            image: .init(systemName: "folder")
        ),
        .other: DisplayRepresentation(
            title: "Other",
            subtitle: nil,
            image: .init(systemName: "folder")
        ),
    ]
}
