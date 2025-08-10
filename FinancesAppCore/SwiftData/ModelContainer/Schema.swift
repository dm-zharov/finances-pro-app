//
//  Schema.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.12.2023.
//

import SwiftData

enum SchemaV1: VersionedSchema {
    static let models: [any PersistentModel.Type] = [Asset.self, Category.self, CategoryGroup.self, Merchant.self, Tag.self, Transaction.self]
    static let versionIdentifier = Schema.Version(1, 0, 0)
}

extension VersionedSchema {
    typealias Latest = SchemaV1
}

extension Schema {
    static let `default` = Schema(versionedSchema: VersionedSchema.Latest.self)
}
