//
//  EnvironmentValues+FinishedState.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.03.2024.
//

import Foundation
import SwiftUI

struct FinishedStateKey: EnvironmentKey {
    static let defaultValue: Binding<Bool>? = nil
}

extension EnvironmentValues {
    var isFinished: Binding<Bool>? {
        get { self[FinishedStateKey.self] }
        set { self[FinishedStateKey.self] = newValue }
    }
}
