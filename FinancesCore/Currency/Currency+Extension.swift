//
//  Currency+Extension.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.09.2023.
//

import SwiftUI 
import SwiftData
import FoundationExtension
import CurrencyKit

// MARK: - Current

extension Currency {
    static var current: Currency {
        // guard #available(iOS 13.0, iOSApplicationExtension 13.0, *) else {
        //     return Currency(CurrencyCode.usd.rawValue)
        // }
        // if let currencyCode = UserDefaults.shared.string(forKey: SettingKey.currencyCode) {
        //     return Currency(currencyCode.lowercased())
        // } else {
        //     return Currency(CurrencyCode.usd.rawValue)
        // }
        
        return Currency(CurrencyCode.usd.rawValue)
    }
}

// MARK: - Common

extension Currency {
    static let usd = Currency(CurrencyCode.usd.rawValue)
    static let eur = Currency(CurrencyCode.eur.rawValue)
    static let rub = Currency(CurrencyCode.rub.rawValue)
}

// MARK: - Crypto

extension Currency {
    static let btc = Currency(CurrencyCode.btc.rawValue)
}

extension Currency {
    public static func suggestedEntities(modelContext: ModelContext) -> [Currency] {
        func assetCurrencies() -> [Currency] {
            var fetchDescriptor = FetchDescriptor<Asset>(sortBy: [SortDescriptor(\.lastUpdatedDate, order: .reverse)])
            fetchDescriptor.propertiesToFetch = [\.currencyCode]
            
            if let assets = try? modelContext.fetch(fetchDescriptor) {
                return assets.map { Currency($0.currencyCode) }
            } else {
                return []
            }
        }
        
        func transactionCurrencies() -> [Currency] {
            var fetchDescriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.lastUpdatedDate, order: .reverse)])
            fetchDescriptor.propertiesToFetch = [\.currencyCode]
            fetchDescriptor.fetchLimit = 25
            
            if let transactions = try? modelContext.fetch(fetchDescriptor) {
                return transactions.map { Currency($0.currencyCode) }
            } else {
                return []
            }
        }
        
        return Set([Currency.current] + transactionCurrencies() + assetCurrencies()).sorted(by: \.localizedDescription)
    }
}

extension Currency: @retroactive CustomLocalizedStringConvertible {
    public var localizedDescription: String {
        if let localizedString = Locale.current.localizedString(forCurrencyCode: identifier) {
            return localizedString.prefix(1).localizedCapitalized + localizedString.dropFirst()
        } else {
            return identifier.uppercased()
        }
    }
}
