//
//  EnvironmentValue+CustomKeyboard.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.10.2023.
//

import SwiftUI

import Observation

@Observable
class CustomKeyboardState {
    public enum SubmitLabel: Hashable {
        case `return`
        case equal
    }
    
    var isInverse: Bool = true
    var submitLabel: SubmitLabel = .return
}

public typealias CustomKeyboardSubmit = () -> Void

struct CustomKeyboardStateKey: EnvironmentKey {
    static let defaultValue: CustomKeyboardState = .init()
}

struct CustomKeyboardSubmitKey: EnvironmentKey {
    static let defaultValue: CustomKeyboardSubmit? = nil
}

extension EnvironmentValues {
    var customKeyboardState: CustomKeyboardState {
        get { self[CustomKeyboardStateKey.self] }
    }
    
    /// Keyboard input provides insert, delete and dismiss methods to implement simple text entry. It also lets you find out if the text object is empty.
    var customKeyboardSubmit: CustomKeyboardSubmit? {
        get { self[CustomKeyboardSubmitKey.self] }
        set { self[CustomKeyboardSubmitKey.self] = newValue }
    }
}

extension View {
    func customKeyboardSubmit(_ action: @escaping CustomKeyboardSubmit) -> some View {
        self.environment(\.customKeyboardSubmit, action)
    }
}
