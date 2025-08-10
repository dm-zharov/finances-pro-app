//
//  CSVImportTip.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.11.2023.
//

import TipKit

struct CSVImportTip: Tip {
    var title: Text {
        Text("Choose Actions for Columns")
    }
    
    var message: Text? {
        Text("The CSV is a freeform table format. Only you have precise knowledge of the meaning of each column.")
    }
    
    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}
