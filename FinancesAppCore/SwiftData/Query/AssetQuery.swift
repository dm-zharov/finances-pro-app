//
//  AssetQuery.swift
//  Finances
//
//  Created by Dmitriy Zharov on 18.04.2024.
//

import Foundation
import SwiftData

struct AssetQuery: Hashable, Codable {
    var sortBy: [SortDescriptor<Asset>] = [Asset.sortDescriptor()]
}

extension AssetQuery {
    var fetchDescriptor: FetchDescriptor<Asset> {
        return FetchDescriptor(sortBy: [Asset.sortDescriptor(.name)])
    }
}
