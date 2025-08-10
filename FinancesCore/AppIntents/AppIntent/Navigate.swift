//
//  OpenRoute.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 09.01.2024.
//

import AppIntents
import SwiftData
import FoundationExtension

struct Navigate: AppIntent {
    static let title: LocalizedStringResource = "Navigate"
    static let openAppWhenRun: Bool = true
    
    @Parameter(title: "Asset")
    var asset: AssetEntity?
    
    @Dependency
    var navigator: Navigator
    
    @Dependency
    var modelContainer: ModelContainer
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            if let assetID = asset?.id {
                navigator.root = .transactions(query: TransactionQuery(searchAssetID: assetID))
            } else {
                navigator.root = nil
            }
        }
        return .result()
    }
    
    static let isDiscoverable: Bool = false
    
    init() { }
}

extension Navigate {
    init(asset: AssetEntity? = nil) {
        self.asset = asset
    }
}
