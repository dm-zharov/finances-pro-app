//
//  AssetList.swift
//  Finances
//
//  Created by Dmitriy Zharov on 03.04.2024.
//

import SwiftUI
import SwiftData
import AppUI
import FoundationExtension

struct AssetList: View {
    let assets: [Asset]
    let selection: Binding<Asset.ID?>
    let groupBy: Asset.GroupBy
    
    @State private var searchText: String = .empty
    private var searchPredicate: Predicate<Asset> {
        return #Predicate<Asset>{ asset in
            if searchText.isEmpty {
                return true
            } else {
                return asset.name.localizedLowercase.contains(searchText.localizedLowercase)
            }
        }
    }
    
    private var data: [Asset] {
        if searchText.isEmpty {
            return assets
        } else {
            return (try? assets.filter(searchPredicate)) ?? []
        }
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        List(selection: selection) {
            if searchText.isEmpty {
                TipItem(AssetListTip())
                    .listRowSeparator(.hidden)
            }
            AssetListContent(data, id: \.id, groupBy: groupBy)
        }
#if os(iOS)
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, placement: .navigationBarDrawer)
#endif
    }
    
    init(
        _ assets: [Asset],
        selection: Binding<Asset.ID?>,
        groupBy: Asset.GroupBy = .defaultValue
    ) {
        self.assets = assets
        self.selection = selection
        self.groupBy = groupBy
    }
}
