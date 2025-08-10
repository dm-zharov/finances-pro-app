//
//  Constants.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.01.2024.
//

import Foundation
import FoundationExtension

enum StorageKey {
    static let isGreetingScreenEnabled = "GreetingScreenEnabled"
}

enum SettingKey {
    // Appearance
    static let preferredColorScheme: String = "PreferredColorScheme"
    static let accentColor: String = "AccentColor"
    
    // Currency
    static let currencyCode: String = "CurrencyCode"
    static let isCurrencyConversionEnabled: String = "CurrencyConversionEnabled"
    
    // Privacy
    static let obscureSensitiveContent = "ObscureSensitiveContent"
    
    // Ordering
    static let assetsOrder: String = "AssetsOrder"
    static let categoriesOrder: String = "CategoriesOrder"
    static let categoryGroupsOrder = "CategoryGroupsOrder"
}

enum Constants {
    enum URL {
        static let scheme: String = "finances"
    }
    
    enum AppGroup {
        static let id: String = {
            #if DEBUG
            "group.dev.zharov.sandbox"
            #else
            "group.dev.zharov.finances"
            #endif
        }()
    }
    
    enum CloudKit {
        static let id: String = "iCloud.dev.zharov.finances"
    }
}
