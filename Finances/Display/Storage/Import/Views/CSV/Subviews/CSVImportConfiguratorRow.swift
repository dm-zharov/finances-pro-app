//
//  CSVImportConfiguratorRow.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.11.2023.
//

import Foundation
import SwiftUI

struct CSVImportConfiguratorRow: View {
    let value: String
    let transform: CSVParseStrategy.CSVColumnTransformer?
    
    var body: some View {
        LabeledContent {
            HStack {
                Image(systemName: "arrow.forward")
                    .imageScale(.small)
                    .foregroundStyle(.accent)
                
                if let transform, let description = transform.description(value) {
                    if description.isEmpty {
                        Text("Failure")
                            .foregroundStyle(.red)
                    } else {
                        Text(description)
                            .foregroundStyle(.primary)
                    }
                } else {
                    Text("Skip")
                        .foregroundStyle(.placeholder)
                }
            }
        } label: {
            Text(value.description)
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
    }
    
    init(_ value: String, transform: CSVParseStrategy.CSVColumnTransformer? = nil) {
        self.value = value
        self.transform = transform
    }
}

#Preview {
    CSVImportConfiguratorRow("Hello, World!")
}
