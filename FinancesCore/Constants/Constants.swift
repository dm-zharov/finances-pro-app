//
//  Constants.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.01.2024.
//

import Foundation
import FoundationExtension

public enum StorageKey {
    public static let isGreetingScreenEnabled = "GreetingScreenEnabled"
}

public enum SettingKey {
    // Appearance
    public static let preferredColorScheme: String = "PreferredColorScheme"
    public static let accentColor: String = "AccentColor"
    
    // Currency
    public static let currencyCode: String = "CurrencyCode"
    public static let isCurrencyConversionEnabled: String = "CurrencyConversionEnabled"
    
    // Privacy
    public static let obscureSensitiveContent = "ObscureSensitiveContent"
    
    // Ordering
    public static let assetsOrder: String = "AssetsOrder"
    public static let categoriesOrder: String = "CategoriesOrder"
    public static let categoryGroupsOrder = "CategoryGroupsOrder"
}

public enum Constants {
    public enum URL {
        public static let scheme: String = "finances"
    }
    
    public enum AppGroup {
        public static let id: String = {
            #if DEBUG
            "group.dev.zharov.sandbox"
            #else
            "group.dev.zharov.finances"
            #endif
        }()
    }
    
    public enum CloudKit {
        public static let id: String = "iCloud.dev.zharov.finances"
    }
}
