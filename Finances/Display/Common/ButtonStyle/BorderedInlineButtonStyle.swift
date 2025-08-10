//
//  BorderedInlineButtonStyle.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.12.2023.
//

import SwiftUI

struct BorderedInlineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 6.0)
            .padding(.horizontal, 12.0)
            .background(isEnabled ? AnyShapeStyle(.fill.secondary) : AnyShapeStyle(.clear), in: RoundedRectangle(cornerRadius: 8.0))
            .foregroundStyle(configuration.isPressed ? Color.accent : Color.primary)
            .animation(.interactiveSpring, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BorderedInlineButtonStyle {
    static var borderedInline: BorderedInlineButtonStyle {
        BorderedInlineButtonStyle()
    }
}
