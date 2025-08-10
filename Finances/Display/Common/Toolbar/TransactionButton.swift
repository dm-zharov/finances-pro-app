//
//  TransactionButton.swift
//  Finances
//
//  Created by Dmitriy Zharov on 04.10.2023.
//

import SwiftUI
import SwiftData

struct TransactionButton: View {
    let isQuick: Bool
    let action: () -> Void
    
    @Query private var assets: [Asset]
    
    var body: some View {
        button
            .help("Add a new transaction")
            .disabled(assets.isEmpty)
    }
    
    var button: some View {
#if os(iOS)
        Button {
            action()
        } label: {
            if isQuick {
                Image(systemName: "square.and.pencil")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.primary, .accent)
            } else {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(.accent)
            }
        }
        .buttonStyle(.plain)
#else
        Button("Add transaction", systemImage: "square.and.pencil", action: action)
#endif
    }
    
    init(isQuick: Bool = false, action: @escaping () -> Void) {
        self.isQuick = isQuick
        self.action = action
    }
}

#Preview {
    TransactionButton { }
}
