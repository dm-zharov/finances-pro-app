//
//  OpenAsset.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 08.01.2024.
//

import AppIntents
import SwiftData

struct OpenAsset: AppIntent {
    static var title: LocalizedStringResource = "Open Asset"
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Asset")
    var asset: AssetEntity
    
    func perform() async throws -> some IntentResult & OpensIntent {
        return .result(opensIntent: Navigate(asset: asset))
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$asset)")
    }
    
    init() { }
}

extension OpenAsset {
    init(asset: AssetEntity) {
        self.asset = asset
    }
}
