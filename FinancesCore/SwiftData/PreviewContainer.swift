//
//  PreviewContainer.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.09.2023.
//

import Foundation
import SwiftData
import CurrencyKit

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Asset.self, Category.self, CategoryGroup.self, Merchant.self, Tag.self, Transaction.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        for asset in PreviewData.assetList {
            container.mainContext.insert(asset)
        }
        for merchant in PreviewData.merchantList {
            container.mainContext.insert(merchant)
        }
        for tag in PreviewData.tagList {
            container.mainContext.insert(tag)
        }
        for category in PreviewData.categoryList {
            container.mainContext.insert(category)
        }
        for categoryGroup in PreviewData.categoryGroupList {
            container.mainContext.insert(categoryGroup)
        }
        for (index, transaction) in PreviewData.transactionList.enumerated() {
            container.mainContext.insert(transaction)
            switch (index) {
            case 0:
                transaction.payee = PreviewData.merchantList[0]
                transaction.asset = PreviewData.assetList[2]
                transaction.category = PreviewData.categoryList[0]
            case 1:
                transaction.asset = PreviewData.assetList[0]
                transaction.category = PreviewData.categoryList[6]
            case 2:
                transaction.asset = PreviewData.assetList[3]
                transaction.category = PreviewData.categoryList[4]
            default:
                break
            }
        }
        
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

@MainActor
enum PreviewData {
    static let assetList: [Asset] = [
        Asset(type: .cash, balance: 10000, currency: .usd, name: "US Dollar"),
        Asset(type: .checking, balance: 866.54, currency: .usd, name: "Bank of Georgia"),
        Asset(type: .checking, balance: 97568, currency: .rub, name: "Tinkoff Bank"),
        Asset(type: .checking, balance: 867.22, currency: .rub, name: "Sberbank")
    ]
    
    static let transactionList: [Transaction] = [
        Transaction(date: .now, amount: -234.8, currency: "rub"),
        Transaction(date: Date(timeIntervalSinceNow: 1 * 60 * 60 * 3), amount: -6.18, currency: .usd),
        Transaction(date: Date(timeIntervalSinceNow: 1 * 60 * 60 * 9), amount: -215.4, currency: .rub),
        Transaction(date: Date(timeIntervalSinceNow: -1 * 60 * 60 * 24), amount: -274.15, currency: .rub),
        Transaction(date: Date(timeIntervalSinceNow: -1 * 60 * 60 * 36), amount: -521.67, currency: .rub),
        Transaction(date: Date(timeIntervalSinceNow: -1 * 60 * 60 * 36), amount: 244.42, currency: .rub)
    ]
    
    static let merchantList: [Merchant] = [
        Merchant(name: "Azbuka Vkusa"),
        Merchant(name: "Starbucks"),
        Merchant(name: "Vkusvill")
    ]
    
    static let categoryList: [Category] = [
        Category(name: "Salary", symbolName: .category(.shoe), colorName: .allCases.randomElement()!, isIncome: true),
        Category(name: "Groceries", symbolName: .category(.bag), colorName: .allCases.randomElement()!),
        Category(name: "Transport", symbolName: .category(.car), colorName: .allCases.randomElement()!),
        Category(name: "House", symbolName: .category(.house), colorName: .allCases.randomElement()!),
        Category(name: "Cafe", symbolName: .category(.forkKnife), colorName: .allCases.randomElement()!),
        Category(name: "Health", symbolName: .category(.cross), colorName: .allCases.randomElement()!),
        Category(name: "Clothing", symbolName: .category(.tshirt), colorName: .allCases.randomElement()!),
        Category(name: "Entertainment", symbolName: .category(.play), colorName: .allCases.randomElement()!),
        Category(name: "Journey", symbolName: .category(.airplane), colorName: .allCases.randomElement()!),
        Category(name: "Cellular", symbolName: .category(.antenna), colorName: .allCases.randomElement()!),
        Category(name: "Gifts", symbolName: .category(.gift), colorName: .allCases.randomElement()!)
    ]
    
    static let categoryGroupList: [CategoryGroup] = [
        CategoryGroup(name: "General")
    ]
    
    static let tagList: [Tag] = [
        Tag(name: "Dubai"),
        Tag(name: "Vacation"),
        Tag(name: "Something"),
        Tag(name: "Different"),
        Tag(name: "Pending")
    ]
}
