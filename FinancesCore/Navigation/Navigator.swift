//
//  Navigator.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 08.01.2024.
//

import SwiftUI

@Observable
final class Navigator: @unchecked Sendable {
    static let shared = Navigator()
    
    var columnVisibility: NavigationSplitViewVisibility
    var path: [NavigationRoute]
    
    private init(columnVisibility: NavigationSplitViewVisibility = .doubleColumn, path: [NavigationRoute] = []) {
        self.columnVisibility = columnVisibility
        self.path = path
    }
}

extension Navigator {
    func open(_ url: URL) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let scheme = urlComponents?.scheme, scheme == Constants.URL.scheme else {
            return
        }
        
        switch urlComponents?.host {
        case "transactions":
            if let queryItem = urlComponents?.queryItems?.first, let queryValue = queryItem.value {
                switch queryItem.name {
                case "asset":
                    if let assetID = UUID(uuidString: queryValue) {
                        root = .transactions(query: TransactionQuery(searchAssetID: assetID))
                    } else {
                        return
                    }
                case "category":
                    if let categoryID = UUID(uuidString: queryValue) {
                        root = .transactions(query: TransactionQuery(searchCategoryID: categoryID))
                    } else {
                        return
                    }
                default:
                    return
                }
            } else {
                return
            }
        default:
            return
        }
    }
}

extension Navigator {
    var root: NavigationRoute? {
        get {
            access(keyPath: \.root)
            return path.first
        }
        set {
            if newValue != path.first {
                withMutation(keyPath: \.root) {
                    path = [newValue].compactMap { $0 }
                }
            }
        }
    }
    var relativePath: [NavigationRoute] {
        get {
            access(keyPath: \.relativePath)
            return Array(path.dropFirst())
        }
        set {
            if let root = path.first {
                withMutation(keyPath: \.relativePath) {
                    path = [root] + newValue
                }
            } else {
                assertionFailure()
            }
        }
    }
}
