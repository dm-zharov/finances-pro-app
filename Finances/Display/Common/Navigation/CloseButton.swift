//
//  CloseButton.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2023.
//

import SwiftUI

struct CloseButton: View {
    let action: () -> Void
    
    var body: some View {
        #if os(iOS)
        Button(action: action) {
            Image(systemName: "xmark")
                .resizable()
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.gray)
                .frame(width: 30.0, height: 30.0)
        }
        #else
        Button("Close", action: action)
        #endif
    }
}

#Preview {
    CloseButton { }
}
