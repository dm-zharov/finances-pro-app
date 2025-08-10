//
//  AssetListContent.swift
//  Finances
//
//  Created by Dmitriy Zharov on 03.04.2024.
//

import SwiftUI
import SwiftData
import AppUI
import FoundationExtension
import OrderedCollections
import CurrencyKit

struct AssetListContent<ID>: View where ID: Hashable {
    @Environment(\.currency) private var currency
    @Environment(\.editMode) private var editMode
    
    let assets: [Asset]
    let id: KeyPath<Asset, ID>
    let groupBy: Asset.GroupBy
    
    private var data: OrderedDictionary<String, [Asset]> {
        switch groupBy {
        case .type:
            OrderedDictionary<String, [Asset]>(
                uniqueKeysWithValues: AssetType.allCases.map { assetType in
                    (String(localized: assetType.localizedStringResource), assets.filter(by: assetType))
                }.filter { value in !value.1.isEmpty }
            )
        case .currency:
            OrderedDictionary<String, [Asset]>(
                uniqueKeysWithValues: assets.grouped(by: { asset in
                    asset.currencyCode
                }).sorted(by: { lhs, rhs in
                    lhs.value.sum(in: currency) > rhs.value.sum(in: currency)
                })
            )
        }
    }
    
    var body: some View {
        ForEach(data.elements, id: \.key) { value, assets in
            Section {
                ForEach(assets) { asset in
                    AssetItemRow(asset)
                }
            } header: {
                HStack {
                    Text(value)
                    Spacer()
                    AmountText(assets.sum(in: currency), currencyCode: currency.identifier)
                }
                .imageScale(.small)
            }
        }
    }
    
    func header(_ title: String, with assets: [Asset]) -> some View {
        HStack {
            Text(title)
            Spacer()
            AmountText(assets.sum(in: currency), currencyCode: currency.identifier)
        }
        .imageScale(.small)
    }
    
    init(
        _ assets: [Asset],
        id: KeyPath<Asset, ID> = \Asset.id,
        groupBy: Asset.GroupBy = .defaultValue
    ) {
        self.assets = assets
        self.id = id
        self.groupBy = groupBy
    }
}
