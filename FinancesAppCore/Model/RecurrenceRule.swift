//
//  RecurrenceRule.swift
//  Finances
//
//  Created by Dmitriy Zharov on 05.04.2024.
//

import Foundation

struct RecurrenceRule {
    /// The interval at which the recurrence rule is applied.
    let interval: Int
    /// The time frame for which the rule applies.
    let frequence: RecurrenceFrequency
    
    /// Initializes the recurrence rule to the specified frequency and interval.
    init(interval: Int, frequency: RecurrenceFrequency) {
        self.interval = interval
        self.frequence = frequency
    }
}

enum RecurrenceFrequency: String, CaseIterable {
    /// A time range that repeats on a daily basis.
    case daily
    /// A date range that repeats on a weekly basis.
    case weekly
    /// A date range that repeats on a monthly basis.
    case monthly
    /// A date range that repeats on a yearly basis.
    case yearly
}
