//
//  NewTransaction.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 07.01.2024.
//

import AppIntents
import FoundationExtension
import SwiftUI
import SwiftData
import CurrencyKit
import WidgetKit

struct NewTransaction: AppIntent {
    static var title: LocalizedStringResource = "New Transaction"
    static var openAppWhenRun: Bool = false
    
    @Parameter(
        title: "Amount",
        controlStyle: .field, /* Constant is used cause of `Expect a compile-time constant literal` */
        inclusiveRange: (0.0, 1.7976931348623157e+308) /* equals to 'Double.greatestFiniteMagnitute' */,
        requestValueDialog: IntentDialog("What's the amount?")
    )
    var amount: Double
    
    @Parameter(title: "Asset", requestValueDialog: "What is the payment method?", optionsProvider: AssetOptionsProvider())
    var asset: AssetEntity
    
    @Parameter(title: "Currency Code", description: "ISO 4217", requestValueDialog: "What is the currency?", optionsProvider: CurrencyOptionsProvider())
    var currencyCode: String
    
    @Parameter(title: "Payee", default: nil)
    var payee: String?
    
    @Parameter(title: "Category", requestValueDialog: "Which category describes this transaction?", optionsProvider: CategoryOptionsProvider())
    var category: CategoryEntity
    
    @Parameter(title: "Date", kind: .date)
    var date: Date?
    
    @Dependency
    var modelContainer: ModelContainer
    
    func perform() async throws -> some IntentResult {
        guard amount != .zero else {
            throw $amount.needsValueError()
        }
        
        guard !currencyCode.isEmpty else {
            throw $currencyCode.needsValueError()
        }
        
        let asset: AssetRepresentation? = try await AssetModelQuery(modelContainer: modelContainer).model(for: asset.id)
        let category: CategoryRepresentation? = try await CategoryModelQuery(modelContainer: modelContainer).model(with: category.id)
        
        let store = StoreQuery(modelContainer: modelContainer)
        try await store.store(
            TransactionRepresentation(
                date: date ?? .now,
                amount: Decimal(category?.isIncome == true ? amount : amount * -1.0),
                currency: Currency(currencyCode),
                payee: payee ?? "",
                asset: asset?.id,
                category: category?.id
            ),
            ignoringDuplicates: true
        )
        try await store.save()
        
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

extension NewTransaction {
    private struct CurrencyOptionsProvider: DynamicOptionsProvider {
        @Dependency
        var modelContainer: ModelContainer
        
        @IntentParameterDependency<NewTransaction>(\.$asset)
        var intent
        
        func results() async throws -> [String] {
            try await CurrencyModelQuery(modelContainer: modelContainer)
                .suggestedModels()
                .map { currency in currency.identifier.uppercased() }
        }
        
        func defaultResult() async -> String? {
            if let asset = intent?.asset, asset.id != .zero {
                return asset.currencyCode
            } else {
                return nil
            }
        }
    }
    
    private struct AssetOptionsProvider: DynamicOptionsProvider {
        @Dependency
        var modelContainer: ModelContainer
        
        func results() async throws -> [AssetEntity] {
            try await AssetModelQuery(modelContainer: modelContainer).models()
                .filter { $0.isHidden == false }
                // .ordered(by: SettingKey.assetsOrder)
                .map { representation in
                    AssetEntity(representation: representation)
                } + [
                    AssetEntity.empty
                ]
        }
    }

    private struct CategoryOptionsProvider: DynamicOptionsProvider {
        @Dependency
        var modelContainer: ModelContainer
        
        func results() async throws -> [CategoryEntity] {
            try await CategoryModelQuery(modelContainer: modelContainer)
                .models()
                // .ordered(by: SettingKey.categoriesOrder)
                .map { representation in
                    CategoryEntity(representation: representation)
                } + [
                    CategoryEntity.empty
                ]
        }
    }
}
