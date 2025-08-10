//
//  ThirdPartyDataProvider.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.10.2023.
//

import Foundation

enum ThirdPartyDataProviderError: Error {
    case undefined
}

protocol ThirdPartyDataProvider {
    // MARK: - Accounts
    
    func loadAssets() async throws -> [AssetRepresentation]
    
    // MARK: - Categories
    
    func loadCategories() async throws -> [CategoryRepresentation]
    
    // MARK: - Transactions
    func loadTransactions() async throws -> [TransactionRepresentation]
}
