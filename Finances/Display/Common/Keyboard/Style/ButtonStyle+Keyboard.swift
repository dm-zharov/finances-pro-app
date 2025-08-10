//
//  ButtonStyle+Keyboard.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.11.2023.
//

#if os(iOS)
import SwiftUI
import AppUI

struct KeyboardButton: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    let style: KeyStyle
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            configuration.label
                .symbolVariant(configuration.isPressed ? .fill : .none)
                .background {
                    RoundedRectangle(cornerRadius: 6.0, style: .continuous)
                        .fill(Color.keyboard(style: style, isHighlighted: configuration.isPressed))
                        .background {
                            RoundedRectangle(cornerRadius: 6.0, style: .continuous)
                                .fill(Color.ui(.systemKeyboardKeyShadow))
                                .offset(x: 0.0, y: 0.5)
                        }
                }
        }
    }
}
#endif
