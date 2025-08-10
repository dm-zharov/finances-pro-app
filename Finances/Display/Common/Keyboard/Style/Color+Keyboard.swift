//
//  Color+Keyboard.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.11.2023.
//

#if os(iOS)
import AppUI
import SwiftUI

extension Color {
    static func keyboard(style: KeyStyle, isHighlighted: Bool, isSelected: Bool = false) -> Color {
        switch style {
        case .key:
            isHighlighted ? keyboard(style: .modifier, isHighlighted: false) : isSelected ? Color.ui(.green) : Color.ui(.systemKeyboardKeyBackground)
        case .modifier:
            isHighlighted ? keyboard(style: .key, isHighlighted: false) : isSelected ? Color.ui(.green) : Color.ui(.systemKeyboardModifierKeyBackground)
        case .toolbar:
            isHighlighted ? keyboard(style: .key, isHighlighted: false) : isSelected ? Color.ui(.green) :  Color.ui(.systemOpaqueToolbarBackground)
        }
    }
}
#endif
