//
//  API+Categories.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2022.
//

import Combine
import CKNetworking

// MARK: - Get All Categories
extension API {
    enum GetCategories {
        struct Response: Decodable {
            let categories: [LMCategory]
        }
    }
    
    /// Use this endpoint to get a flattened list of all categories in alphabetical order associated with the user's account.
    func getCategories() -> AnyPublisher<GetCategories.Response, Error> {
        get("/categories")
    }
}

// MARK: - Get Single Category
extension API {
    /// Use this endpoint to get hydrated details on a single category
    /// - Note: If this category is part of a category group, its properties (is_income, exclude_from_budget, exclude_from_totals) will inherit from the category group.
    func getCategory(with id: LMCategory.ID) -> AnyPublisher<LMCategory, Error> {
        get("/category/\(id)")
    }
}

// MARK: - Create Category
extension API {
    /// Use this endpoint to create a single category
    /// - Returns: Returns the ID of the newly-created category.
    func createCategory() -> AnyPublisher<LMCategory.ID, Error> {
        post("/categories")
    }
}

// MARK: - Create Category Group
extension API {
    
}

// MARK: - Update Category
extension API { }

// MARK: - Add to Category Group
extension API { }

// MARK: - Delete Category
extension API { }

// MARK: - Force Delete Category
extension API { }
