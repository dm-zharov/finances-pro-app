//
//  DatePeriod.swift
//  Finances
//
//  Created by Dmitriy Zharov on 18.03.2024.
//

import Foundation

enum DatePeriod: String, CaseIterable {
    case day
    case week
    case month
    case year
}

extension DatePeriod: IteratorProtocol {
    func next() -> DatePeriod? {
        switch self {
        case .day:
            return .week
        case .week:
            return .month
        case .month:
            return .year
        case .year:
            return nil
        }
    }
}

extension DatePeriod: CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .day:
            "Day"
        case .week:
            "Week"
        case .month:
            "Month"
        case .year:
            "Year"
        }
    }
}

extension Calendar {
    @_disfavoredOverload
    func startOf(_ datePeriod: DatePeriod, for date: Date) -> Date {
        switch datePeriod {
        case .day:
            startOfDay(for: date)
        case .week:
            startOfWeek(for: date)
        case .month:
            startOfMonth(for: date)
        case .year:
            startOfYear(for: date)
        }
    }
}
