//
//  AssetFolderView.swift
//  FinancesWidget
//
//  Created by Dmitriy Zharov on 06.01.2024.
//

import WidgetKit
import SwiftUI
import FoundationExtension
import CurrencyKit

struct AssetFolderView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetContentMargins) private var widgetContentMargins
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    @Environment(\.redactionReasons) private var redactionReasons
    
    var assets: [AssetEntity]

    var body: some View {
        switch assets.count {
        case 1:
            VStack(spacing: 8.0) {
                if let asset = assets[safe: 0] {
                    item(asset: asset)
                }
                HStack { }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case 2:
            VStack(spacing: 8.0) {
                if let asset = assets[safe: 0] {
                    item(asset: asset)
                }
                if let asset = assets[safe: 1] {
                    item(asset: asset)
                }
            }
        default:
            Grid(horizontalSpacing: 8.0, verticalSpacing: 8.0) {
                GridRow {
                    if let asset = assets[safe: 0] {
                        item(asset: asset)
                    }
                    if let asset = assets[safe: 2] {
                        item(asset: asset)
                    }
                }
                GridRow {
                    if let asset = assets[safe: 1] {
                        item(asset: asset)
                    }
                    if let asset = assets[safe: 3] {
                        item(asset: asset)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func item(asset: AssetEntity) -> some View {
        Link(destination: NavigationRoute.transactions(query: TransactionQuery(searchAssetID: asset.id)).url) {
            HStack(alignment: .center, spacing: 12.0) {
                if redactionReasons.contains(.placeholder) {
                    ContainerRelativeShape()
                        .fill(.accent.secondary)
                        .frame(width: 24.0, height: 24.0)
                } else {
                    Image(systemName: asset.type.symbolName)
                        .resizable()
                        .symbolRenderingMode(.hierarchical)
                        .symbolVariant(.circle.fill)
                        .foregroundStyle(.accent)
                        .frame(width: 24.0, height: 24.0)
                }
                
                VStack(alignment: .leading, spacing: 2.0) {
                    Text(asset.name)
                        .widgetAccentable()
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(asset.balance.formatted(.currency(code: asset.currencyCode)))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .font(.footnote)
            .padding(.vertical, 8.0)
            .padding(.horizontal, 12.0)
            .background(
                colorScheme == .light ? AnyShapeStyle(.background) : AnyShapeStyle(.fill.tertiary),
                in: ContainerRelativeShape()
            )
        }
    }
}

struct AssetFolderWidget: Widget {
    let kind: String = "Asset Folder"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: AssetListConfiguration.self,
            provider: AssetListProvider()
        ) { entry in
            AssetFolderView(assets: entry.configuration.assets ?? [])
                .containerBackground(.fill.tertiary, for: .widget)
                .padding(.all, 8.0)
        }
        .configurationDisplayName("Assets Folder")
        .description("Quickly open your assets.")
        #if os(watchOS)
        .supportedFamilies([
            .accessoryRectangular,
        ])
        #else
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
        #endif
        .contentMarginsDisabled()
    }
}

#if os(iOS) || os(macOS)
#Preview(as: .systemSmall) {
    AssetFolderWidget()
} timeline: {
    AssetListEntry(date: .now, configuration: {
        let configuration = AssetListConfiguration()
        configuration.assets = [
            AssetEntity(id: .zero, name: "Apple Card", type: .checking, balance: 1234.56, currency: .usd),
            AssetEntity(id: .zero, name: "Crypto", type: .other, balance: 1.00, currency: .btc),
            AssetEntity(id: .zero, name: "Euro", type: .cash, balance: 123.45, currency: .eur),
        ]
        return configuration
    }())
}
#endif
