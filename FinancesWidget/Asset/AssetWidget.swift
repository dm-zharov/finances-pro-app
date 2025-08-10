//
//  AssetWidget.swift
//  FinancesWidgetExtension
//
//  Created by Dmitriy Zharov on 08.01.2024.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppUI
import FoundationExtension
import CurrencyKit

struct AssetView: View {
    @Environment(\.widgetContentMargins) private var widgetContentMargins
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    @Environment(\.redactionReasons) private var redactionReasons

    var asset: AssetEntity

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack {
                    Image(systemName: asset.type.symbolName)
                        .imageScale(.small)
                        .unredacted()
                    Text(asset.currencyCode.uppercased())
                        .widgetAccentable()
                        .unredacted()
                }
                .font(.subheadline)
                .fontWeight(.medium)
            }
        case .accessoryInline:
            Label(asset.name, systemImage: asset.type.symbolName)
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Label(asset.name, systemImage: asset.type.symbolName)
                    .widgetAccentable()
                Text(asset.balance.formatted(.currency(code: asset.currencyCode)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .font(.headline)
        default:
            VStack(alignment: .leading) {
                if redactionReasons.contains(.placeholder) {
                    ContainerRelativeShape()
                        .fill(.accent.secondary)
                        .frame(width: 44.0, height: 44.0)
                } else {
                    Image(systemName: asset.type.symbolName)
                        .resizable()
                        .symbolRenderingMode(.hierarchical)
                        .symbolVariant(.circle.fill)
                        .foregroundStyle(.accent)
                        .frame(width: 44.0, height: 44.0)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2.0) {
                    Text(asset.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(asset.balance.formatted(.currency(code: asset.currencyCode)))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.5)
                }
            }
        }
    }
}

struct AssetWidget: Widget {
    let kind: String = "Asset"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: AssetConfiguration.self,
            provider: AssetProvider()
        ) { entry in
            if let asset = entry.configuration.asset {
                AssetView(asset: asset)
                    .containerBackground(.background, for: .widget)
                    .widgetURL(
                        NavigationRoute.transactions(query: TransactionQuery(searchAssetID: asset.id)).url
                    )
            }
        }
        .configurationDisplayName("Asset")
        .description("Quickly open one of your assets.")
        #if os(iOS)
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular
        ])
        #elseif os(macOS)
        .supportedFamilies([
            .systemSmall
        ])
        #elseif os(watchOS)
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular
        ])
        #endif
    }
}

#if !os(watchOS)
#Preview(as: .systemMedium) {
    AssetWidget()
} timeline: {
    AssetEntry(date: .now, configuration: {
        let configuration = AssetConfiguration()
        configuration.asset = .placeholder
        return configuration
    }())
}
#endif
