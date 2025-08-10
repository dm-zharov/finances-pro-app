//
//  AssetListProvider.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 07.01.2024.
//

import WidgetKit
import AppIntents

struct AssetListEntry: TimelineEntry {
    let date: Date
    let configuration: AssetListConfiguration
}

struct AssetListProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> AssetListEntry {
        let configuration = AssetListConfiguration()
        configuration.assets = [
            .placeholder,
            .placeholder
        ]
        return AssetListEntry(date: Date(), configuration: configuration)
    }
    
    func recommendations() -> [AppIntentRecommendation<AssetListConfiguration>] {
        []
    }
    
    func snapshot(for configuration: AssetListConfiguration, in context: Context) async -> AssetListEntry {
        if context.isPreview {
            return AssetListEntry(date: Date(), configuration: configuration)
        } else {
            return AssetListEntry(date: Date(), configuration: configuration)
        }
    }
    
    func timeline(for configuration: AssetListConfiguration, in context: Context) async -> Timeline<AssetListEntry> {
        return await Timeline(entries: [snapshot(for: configuration, in: context)], policy: .never)
    }
}
