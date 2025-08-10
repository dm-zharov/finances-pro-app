//
//  EnvironmentValues+Accent.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.04.2024.
//

import SwiftUI

struct AccentStyleKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle = AnyShapeStyle(.accent)
}

extension EnvironmentValues {
    var accentStyle: AnyShapeStyle {
        get { self[AccentStyleKey.self] }
        set { self[AccentStyleKey.self] = newValue }
    }
}

struct AccentStyleModifier: ViewModifier {
    var style: AnyShapeStyle

    func body(content: Content) -> some View {
        content.environment(\.accentStyle, style)
    }
    
    init(style: AnyShapeStyle) {
        self.style = style
    }
}

extension View {
    public func accent<S>(_ accent: S?) -> some View where S: ShapeStyle {
        modifier(
            AccentStyleModifier(
                style: accent.map { AnyShapeStyle($0) } ?? AccentStyleKey.defaultValue
            )
        )
    }
}
