//
//  AssetProvider.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 08.01.2024.
//

import WidgetKit
import AppIntents

struct AssetEntry: TimelineEntry {
    let date: Date
    let configuration: AssetConfiguration
}

struct AssetProvider: AppIntentTimelineProvider {
    func recommendations() -> [AppIntentRecommendation<AssetConfiguration>] {
        []
    }
    
    func placeholder(in context: Context) -> AssetEntry {
        let configuration = AssetConfiguration()
        configuration.asset = .placeholder
        return AssetEntry(date: Date(), configuration: configuration)
    }
    
    func snapshot(for configuration: AssetConfiguration, in context: Context) async -> AssetEntry {
        if let assetID = configuration.asset?.id, let asset = try? await AssetEntityQuery().entities(for: [assetID]).first {
            configuration.asset = asset
        } else {
            configuration.asset = .placeholder
        }
        return AssetEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: AssetConfiguration, in context: Context) async -> Timeline<AssetEntry> {
        return await Timeline(entries: [snapshot(for: configuration, in: context)], policy: .never)
    }
}
