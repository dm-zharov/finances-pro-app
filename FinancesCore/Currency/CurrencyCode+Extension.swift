//
//  CurrencyCode+Extension.swift
//
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import Foundation
import CurrencyKit
import FoundationExtension
import AppIntents

extension CurrencyCode: @retroactive AppEntity {
    public static let typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: "Currency Code")
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(
                verbatim: Currency(rawValue).localizedDescription
            )
        )
    }
}
