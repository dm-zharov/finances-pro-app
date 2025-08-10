//
//  AssetListTip.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.11.2023.
//

import TipKit

struct AssetListTip: Tip {
    var title: Text {
        Text("All Assets")
    }
    
    var message: Text? {
        Text("You could hide rarely used assets from the main screen. They will always be accessible from here.")
    }
    
    var options: [TipOption] {
        Tips.MaxDisplayCount(3)
    }
}
