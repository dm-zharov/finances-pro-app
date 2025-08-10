//
//  EnvironmentValues+InlineMenuVisibilityKey.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.04.2024.
//

import SwiftUI

struct InlineMenuVisibilityKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isInlineMenuVisible: Bool {
        get { self[InlineMenuVisibilityKey.self] }
        set { self[InlineMenuVisibilityKey.self] = newValue }
    }
}

extension View {
    @available(macOS, unavailable)
    func inlineMenuVisibility(_ isVisible: Bool) -> some View {
        environment(\.isInlineMenuVisible, isVisible)
    }
}
