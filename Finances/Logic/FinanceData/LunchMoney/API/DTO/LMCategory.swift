//
//  LMCategory.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.09.2023.
//

import Foundation

struct LMCategory: Decodable, Identifiable, Hashable {
    /// A unique identifier for the category.
    let id: UInt64
    /// The name of the category. Must be between 1 and 40 characters.
    let name: String
    /// The description of the category. Must not exceed 140 characters.
    let description: String?
    /// If true, the transactions in this category will be treated as income.
    let isIncome: Bool
    /// If true, the transactions in this category will be excluded from the budget.
    let excludeFromBudget: Bool
    /// If true, the transactions in this category will be excluded from totals.
    let excludeFromTotals: Bool
    /// The date and time of when the category was last updated (in the ISO 8601 extended format).
    @StringRepresentation<Date>
    var updatedAt: String
    /// The date and time of when the category was created (in the ISO 8601 extended format).
    @StringRepresentation<Date>
    var createdAt: String
    /// If true, the category is a group that can be a parent to other categories.
    let isGroup: Bool
    /// The ID of a category group (or null if the category doesn't belong to a category group).
    let groupId: UInt64?
    /// For category groups, this will populate with the categories nested within and include id, name, description and created_at fields.
    let children: [LMCategory.Thumbnail]?
}

extension LMCategory {
    struct Thumbnail: Decodable, Identifiable, Hashable {
        /// A unique identifier for the category.
        let id: UInt64
        /// The name of the category. Must be between 1 and 40 characters.
        let name: String
        /// The description of the category. Must not exceed 140 characters.
        let description: String?
        /// The date and time of when the category was created (in the ISO 8601 extended format).
        let createdAt: String
    }
}
