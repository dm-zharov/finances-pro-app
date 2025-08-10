//
//  NavigationRoute.swift
//  Finances
//
//  Created by Dmitriy Zharov on 26.12.2023.
//

import AppIntents
import SwiftUI

enum NavigationRoute: Hashable, Codable, Sendable {
    case summary
    case transaction(id: Transaction.ExternalID)
    case category(id: Category.ExternalID)
    case categoryGroup(id: CategoryGroup.ExternalID)
    case merchant(id: Merchant.ExternalID)
    #if BudgetFeature
    case budget(id: Budget.ExternalID)
    #endif
    case transactions(query: TransactionQuery = .defaultValue)
    case tags(ids: Set<Tag.ExternalID>)
}

extension NavigationRoute {
    var url: URL {
        let schema: String = "finances"
        var path: String
        switch self {
        case .summary:
            path = "summary"
        case .transaction(id: let transactionID):
            path = "transaction?id=\(transactionID.entityIdentifierString)"
        case .category(id: let categoryID):
            path = "summary/category?id=\(categoryID.entityIdentifierString)"
        case .categoryGroup(id: let categoryGroupID):
            path = "summary/categoryGroup?id=\(categoryGroupID.entityIdentifierString)"
        case .merchant(id: let merchantID):
            path = "summary/merchant?id=\(merchantID.entityIdentifierString)"
        #if BudgetFeature
        case .budget(let budgetID):
            path = "summary/budget?=id\(budgetID.entityIdentifierString)"
        #endif
        case .transactions(let query):
            if let assetID = query.searchAssetID {
                path = "transactions?asset=\(assetID.entityIdentifierString)"
            } else if let categoryID = query.searchCategoryID {
                path = "transactions?category=\(categoryID.entityIdentifierString)"
            } else if let merchantID = query.searchMerchantID {
                path = "transactions?merchant=\(merchantID.entityIdentifierString)"
            } else {
                path = "transactions"
            }
        case .tags(let IDs):
            path = "tags?names=\(IDs.map(\.entityIdentifierString).joined(separator: ","))"
        }
        return URL(string: "\(schema)://\(path)")!
    }
}

extension NavigationLink where Destination == Never {
    init(route: NavigationRoute?, @ViewBuilder label: () -> Label) {
        self.init(value: route, label: label)
    }
}

extension Optional where Wrapped == NavigationRoute {
    var selection: Set<NavigationRoute> {
        get {
            switch self {
            case .some(let singleValue):
                return Set([singleValue])
            case .none:
                return Set()
            }
        }
        set {
            if let singleValue = newValue.first(where: { self != $0 }) {
                self = singleValue
            }
        }
    }
}
