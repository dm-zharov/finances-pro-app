//
//  CurrencyModelQuery.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10.01.2024.
//

import SwiftData
import CurrencyKit
import FoundationExtension

actor CurrencyModelQuery: ModelActor {
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(
            modelContext: ModelContext(modelContainer)
        )
    }
    
    func models() async throws -> [Currency] {
        Currency.supportedCurrencies.sorted(by: \.localizedDescription)
    }
    
    func suggestedModels() async throws -> [Currency] {
        Currency.suggestedEntities(modelContext: modelContext)
    }
}
