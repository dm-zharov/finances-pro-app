//
//  ListHeaderAccessoryModifier.swift
//  Finances
//
//  Created by Dmitriy Zharov on 25.02.2024.
//

import SwiftUI

struct ListHeaderAccessoryModifier<AccessoryView>: ViewModifier where AccessoryView: View {
    @State private var isHovered: Bool = false
    
    let accessoryView: AccessoryView
    
    func body(content: Content) -> some SwiftUI.View {
        HStack {
            content
            Spacer()
            if isHovered {
                accessoryView
                    .buttonStyle(.plain)
                    .font(.system(size: 14.0))
                    .fontWeight(.medium)
                    .foregroundStyle(.placeholder)
            }
        }
        #if os(macOS)
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        #endif
    }
}

extension View {
    func listHeaderAccessory(@ViewBuilder _ content: () -> some View) -> some View {
        modifier(ListHeaderAccessoryModifier(accessoryView: content()))
    }
}
