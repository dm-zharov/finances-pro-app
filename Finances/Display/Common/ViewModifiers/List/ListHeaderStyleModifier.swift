//
//  ListHeaderStyleModifier.swift
//  Finances
//
//  Created by Dmitriy Zharov on 29.12.2023.
//

import SwiftUI

enum ListHeaderStyle {
    case large
}

struct ListHeaderStyleModifier: ViewModifier {
    @Environment(\.editMode) private var editMode
    
    let style: ListHeaderStyle
    
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(editMode.isEditing ? .ui(.tertiaryLabel) : .primary)
            .disabled(editMode.isEditing)
        #else
        content
            .fontWeight(.bold)
            .disabled(editMode.isEditing)
        #endif
    }
}

extension View {
    func listHeaderStyle(_ style: ListHeaderStyle) -> some View {
        modifier(ListHeaderStyleModifier(style: style))
    }
}

