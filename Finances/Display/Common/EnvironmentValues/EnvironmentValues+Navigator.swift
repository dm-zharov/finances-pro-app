//
//  EnvironmentValues+Navigator.swift
//  Finances
//
//  Created by Dmitriy Zharov on 19.03.2024.
//

import SwiftUI

struct NavigatorKey: EnvironmentKey {
    static let defaultValue = Navigator.shared
}

extension EnvironmentValues {
    var navigator: Navigator {
        get { self[NavigatorKey.self] }
    }
}
