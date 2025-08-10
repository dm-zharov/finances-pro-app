//
//  BudgetRepresentation.swift
//  Finances
//
//  Created by Dmitriy Zharov on 18.03.2024.
//

import Foundation
import CurrencyKit
import SwiftData
import FoundationExtension

struct BudgetRepresentation: ObjectRepresentation, Hashable, Identifiable {
    typealias Item = Budget
    
    var id: UUID = UUID()
    
    var amount: Decimal = .zero
    var currency: Currency = .current
    var repeatInterval: DatePeriod = .month
    
    var categories: [UUID] = []
    
    var startDate: Date = Calendar.autoupdatingCurrent.startOfMonth(for: .now)
    var creationDate: Date = .now
}

extension BudgetRepresentation {
    func validate() -> Bool {
        amount > .zero
    }
}

extension Budget: ObjectRepresentable {
    var objectRepresentation: BudgetRepresentation {
        get {
            BudgetRepresentation(
                id: externalIdentifier,
                amount: amount,
                currency: Currency(currencyCode),
                repeatInterval: DatePeriod(rawValue: repeatInterval) ?? .month,
                categories: (categories ?? []).map { category in
                    category.externalIdentifier
                },
                startDate: startDate,
                creationDate: creationDate
            )
        }
        set(representation) {
            guard let modelContext = modelContext else {
                fatalError()
            }
            
            externalIdentifier = representation.id
            amount = representation.amount
            currencyCode = representation.currency.identifier
            repeatInterval = representation.repeatInterval.rawValue
            
            categories = representation.categories.compactMap { categoryID in
                if let category = Category.retrieve(categoryID, modelContext: modelContext) {
                    return category
                } else {
                    assertionFailure()
                    return nil
                }
            }
            
            startDate = Calendar.current.startOfMonth(for: representation.startDate, in: .gmt)
            creationDate = representation.creationDate
        }
    }
}
