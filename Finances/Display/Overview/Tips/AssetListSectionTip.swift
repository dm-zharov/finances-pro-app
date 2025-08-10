//
//  AssetListSectionTip.swift
//  Finances
//
//  Created by Dmitriy Zharov on 23.11.2023.
//

import TipKit

struct AssetListSectionTip: Tip {
    var title: Text {
        Text("Space for Your Assets")
            .foregroundStyle(.accent)
    }
    
    var message: Text? {
        Text("Start by adding your first assets or importing pre-existing financial data.")
    }
}
