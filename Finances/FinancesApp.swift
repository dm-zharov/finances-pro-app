//
//  FinancesApp.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2022.
//

import SwiftUI
import SwiftData
import OSLog
import AppIntents
import CurrencyKit
import TipKit

struct FeatureToggle {
    static let sharing: Bool = true
}

@main
struct FinancesApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(FinancesAppDelegate.self) var appDelegate
#endif
    
#if os(macOS)
    @NSApplicationDelegateAdaptor(FinancesAppDelegate.self) var appDelegate
#endif
    
    var body: some Scene {
        MainScene()
    #if os(macOS)
        SettingsScene()
    #endif
    }
    
    init() {
        CurrencyBackingStore.shared.setSupportedCurrencies(
            Set(CurrencyCode.allCases.map { currencyCode in Currency(currencyCode.rawValue) })
        )
        CurrencyBackingStore.shared.setCurrencyDigits(
            CurrencyDigits(fractionDigits: 8, roundingIncrement: 0),
            for: CurrencyCode.btc.rawValue
        )
        
    #if DEBUG
        try? Tips.resetDatastore()
        Tips.showTipsForTesting([])
    #endif
        try? Tips.configure([
            .datastoreLocation(.applicationDefault),
            .displayFrequency(.immediate)
        ])
        
        AppDependencyManager.shared.add(dependency: Navigator.shared)
        AppDependencyManager.shared.add(dependency: ModelContainer.default)
    }
}

#if DEBUG
extension View {
    func printOutput(_ value: Any) -> Self {
        print(value)
        return self
    }
}
#endif
