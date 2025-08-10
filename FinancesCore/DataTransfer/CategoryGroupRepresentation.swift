//
//  CategoryGroupRepresentation.swift
//  Finances
//
//  Created by Dmitriy Zharov on 22.02.2024.
//

import Foundation
import SwiftData

struct CategoryGroupRepresentation: ObjectRepresentation, Hashable, Identifiable {
    typealias Item = CategoryGroup
    
    var id: UUID = UUID()
    
    var name: String = ""
    var categories: [UUID] = []
}

extension CategoryGroupRepresentation {
    func validate() -> Bool {
        !name.isEmpty
    }
}

extension CategoryGroup: ObjectRepresentable {
    var objectRepresentation: CategoryGroupRepresentation {
        get {
            CategoryGroupRepresentation(
                id: externalIdentifier,
                name: name,
                categories: categories?.map { category in
                    category.externalIdentifier
                } ?? []
            )
        }
        set(representation) {
            guard let _ = modelContext else {
                fatalError()
            }
            
            externalIdentifier = representation.id
            name = representation.name
        }
    }
}
