//
//  CategoryRepresentation.swift
//  Finances
//
//  Created by Dmitriy Zharov on 15.10.2023.
//

import Foundation
import AppUI
import SwiftData
import FoundationExtension

struct CategoryRepresentation: ObjectRepresentation, Hashable, Identifiable {
    typealias Item = Category
    
    var id: String = UUID().uuidString
    
    var name: String = ""
    var symbolName: SymbolName = .defaultValue
    var colorName: ColorName = .allCases.randomElement() ?? .defaultValue
    
    var groupID: UUID? = nil
    
    var isIncome: Bool = false
    var isTransient: Bool = false
    
    var creationDate: Date = .now
    var lastUpdatedDate: Date = .now
}

extension CategoryRepresentation {
    var type: CategoryType {
        switch (isIncome, isTransient) {
        case (false, false):
            return [.none]
        case (true, false):
            return [.income]
        case (false, true):
            return [.excluded]
        case (true, true):
            return [.income, .excluded]
        }
    }
}

extension CategoryRepresentation {
    func validate() -> Bool {
        !name.isEmpty
    }
}

extension Category: ObjectRepresentable {
    var objectRepresentation: CategoryRepresentation {
        get {
            CategoryRepresentation(
                id: externalIdentifier.uuidString,
                name: name,
                symbolName: SymbolName(rawValue: symbolName),
                colorName: ColorName(rawValue: colorName),
                groupID: group?.externalIdentifier,
                isIncome: isIncome,
                isTransient: isTransient,
                creationDate: creationDate,
                lastUpdatedDate: lastUpdatedDate
            )
        }
        set(representation) {
            guard let modelContext = modelContext else {
                fatalError()
            }
            
            setIdentityString(representation.id)
            name = representation.name
            symbolName = representation.symbolName.rawValue
            colorName = representation.colorName.rawValue
            isIncome = representation.isIncome
            isTransient = representation.isTransient
            creationDate = representation.creationDate
            lastUpdatedDate = representation.lastUpdatedDate
            
            if let groupID = representation.groupID {
                self.group = CategoryGroup.retrieve(groupID, modelContext: modelContext)
            } else if self.group != nil {
                self.group = nil
            }
        }
    }
}
