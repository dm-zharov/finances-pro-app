//
//  SortOrder.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10/08/2025.
//

import AppUI
import Foundation

extension SortOrder: @retroactive CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .forward:
            "Forward"
        case .reverse:
            "Reverse"
        }
    }
}

extension SortOrder {
    public var symbolName: String {
        switch self {
        case .forward: "chevron.up"
        case .reverse: "chevron.down"
        }
    }
}

extension SortOrder {
    mutating func toggle() {
        switch self {
        case .forward:
            self = .reverse
        case .reverse:
            self = .forward
        }
    }
}
