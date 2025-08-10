//
//  EnvironmentValues+DateInterval.swift
//  Finances
//
//  Created by Dmitriy Zharov on 12.10.2023.
//

import SwiftUI

struct DateIntervalKey: EnvironmentKey {
    static let defaultValue: DateInterval = DateInterval(start: .distantPast, end: .distantFuture)
}

extension EnvironmentValues {
    var dateInterval: DateInterval {
        get { self[DateIntervalKey.self] }
        set { self[DateIntervalKey.self] = newValue }
    }
}
