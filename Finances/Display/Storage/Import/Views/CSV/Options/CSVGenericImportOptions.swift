//
//  CSVGenericImportOptions.swift
//  Finances
//
//  Created by Dmitriy Zharov on 01.12.2023.
//

import SwiftUI

struct CSVGenericImportOptions: View {
    let field: Statement.Field
    @Binding var strategy: CSVParseStrategy
    
    var body: some View {
        Section {
            Text("No Options")
                .foregroundStyle(.secondary)
        } header: {
            Text("Options")
        }
        .onChange(of: field, initial: true) {
            strategy.transform[field] = .replace([:])
        }
    }
}

#Preview {
    CSVGenericImportOptions(field: .payee, strategy: .constant(.init()))
}
