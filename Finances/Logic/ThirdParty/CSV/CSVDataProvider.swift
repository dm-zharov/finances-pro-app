//
//  CSVDataProvider.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.11.2023.
//

import Foundation
import SwiftCSV

class CSVDataProvider {
    private let csv: CSV<Named>
    
    init(_ csv: CSV<Named>) {
        self.csv = csv
    }
}

extension CSVDataProvider: ThirdPartyDataProvider {
    func loadAssets() async throws -> [AssetRepresentation] {
        []
    }
    
    func loadCategories() async throws -> [CategoryRepresentation] {
        []
    }
    
    func loadTransactions() async throws -> [TransactionRepresentation] {
        []
    }
}
