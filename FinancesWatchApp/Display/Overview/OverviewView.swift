//
//  OverviewView.swift
//  FinancesWatchApp
//
//  Created by Dmitriy Zharov on 10.03.2024.
//

import AppUI
import FoundationExtension
import SwiftUI
import SwiftData
import CurrencyKit

struct OverviewView: View {
    @Query(filter: #Predicate<Asset>{ asset in asset.isHidden == false }) private var assets: [Asset]
    @State private var selectedAssetID: Asset.ID?
    
    var body: some View {
        List(selection: $selectedAssetID) {
            ForEach(assets) { asset in
                Label {
                    HStack { Spacer() }
                        .overlay(alignment: .leading) {
                            VStack(alignment: .leading, spacing: .zero) {
                                Text(asset.name)
                                    .font(.body)
                                Text(asset.balance.formatted(.currency(code: asset.currencyCode)))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                } icon: {
                    Image(systemName: AssetType(rawValue: asset.type).symbolName)
                        .imageScale(.medium)
                        .foregroundStyle(.tint)
                }
            }
        }
        .overlay {
            if assets.isEmpty {
                ContentUnavailableView {
                    Label(LocalizedStringKey("No Assets"), symbolName: SymbolName.Setting.asset.rawValue)
                } description: {
                    Text("Add one on your iPhone.")
                }
            }
        }
        .navigationTitle("Assets")
        .navigationDestination(item: $selectedAssetID) { assetID in
            TransactionListView(assetID: assetID)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
