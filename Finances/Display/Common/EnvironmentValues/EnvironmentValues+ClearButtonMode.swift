//
//  EnvironmentValues+ClearButtonMode.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.12.2023.
//

import SwiftUI

enum ClearButtonMode: Int, Sendable {
    case never
    case whileEditing
    case unlessEditing
    case always
}

struct ClearButtonModeKey: EnvironmentKey {
    static let defaultValue: ClearButtonMode = .never
}

extension EnvironmentValues {
    var clearButtonMode: ClearButtonMode {
        get { self[ClearButtonModeKey.self] }
        set { self[ClearButtonModeKey.self] = newValue }
    }
}

extension View {
    func clearButtonMode(_ mode: ClearButtonMode) -> some View {
        environment(\.clearButtonMode, mode)
    }
}
