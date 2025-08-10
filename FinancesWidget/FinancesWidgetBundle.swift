//
//  FinancesWidgetBundle.swift
//  FinancesWidget
//
//  Created by Dmitriy Zharov on 06.01.2024.
//

import AppIntents
import WidgetKit
import SwiftUI
import CurrencyKit
import SwiftData
import FoundationExtension

@main
struct FinancesWidgetBundle: WidgetBundle {
    var body: some Widget {
        AssetWidget()
        AssetFolderWidget()
    }
    
    init() {
        AppDependencyManager.shared.add(dependency: ModelContainer.default)
    }
}
