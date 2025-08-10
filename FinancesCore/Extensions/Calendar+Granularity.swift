//
//  Calendar+DatePeriod.swift
//  Finances
//
//  Created by Dmitriy Zharov on 12.10.2023.
//

import Foundation
import FoundationExtension

// MARK: - Start

extension Calendar {
    public func startOfWeek(for date: Date) -> Date {
        dateInterval(of: .weekOfYear, for: date)!.start
    }
    
    public func startOfMonth(for date: Date) -> Date {
        dateInterval(of: .month, for: date)!.start
    }
    
    public func startOfYear(for date: Date) -> Date {
        dateInterval(of: .year, for: date)!.start
    }
    
    public func startOf(_ component: Calendar.Component, for date: Date) -> Date? {
        dateInterval(of: component, for: date)?.start
    }
}

// MARK: - DatePeriod

extension Calendar {
    func datePeriod(of dateInterval: DateInterval) -> DatePeriod? {
        guard let beforeEnd = dateInterval.beforeEnd else {
            return nil
        }
        
        if isDate(dateInterval.start, equalTo: beforeEnd, toGranularity: .day) {
            return .day
        } else if isDate(dateInterval.start, equalTo: beforeEnd, toGranularity: .weekOfYear) {
            return .week
        } else if isDate(dateInterval.start, equalTo: beforeEnd, toGranularity: .month) {
            return .month
        } else if isDate(dateInterval.start, equalTo: beforeEnd, toGranularity: .year) {
            return .year
        }
        
        return nil
    }
    
    @_disfavoredOverload
    func dateInterval(of datePeriod: DatePeriod, for date: Date) -> DateInterval? {
        switch datePeriod {
        case .day:
            return self.dateInterval(of: .day, for: date)
        case .week:
            return self.dateInterval(of: .weekOfYear, for: date)
        case .month:
            return self.dateInterval(of: .month, for: date)
        case .year:
            return self.dateInterval(of: .year, for: date)
        }
    }

    func granularity(for dateInterval: DateInterval) -> Calendar.Component? {
        guard let beforeEnd = dateInterval.beforeEnd else {
            return nil
        }
        
        if isDate(dateInterval.start, equalTo: beforeEnd, toGranularity: .day) {
            return .day
        } else if isDate(dateInterval.start, equalTo: beforeEnd, toGranularity: .weekOfYear) {
            return .weekOfYear
        } else if isDate(dateInterval.start, equalTo: beforeEnd, toGranularity: .month) {
            return .month
        } else if isDate(dateInterval.start, equalTo: beforeEnd, toGranularity: .year) {
            return .year
        }
        
        return nil
    }
}

extension Calendar.Component: @retroactive IteratorProtocol {
    public func next() -> Calendar.Component? {
        switch self {
        case .year:
            return .era
        case .month:
            return .year
        case .weekOfYear:
            return .month
        case .day:
            return .weekOfYear
        case .hour:
            return .day
        case .minute:
            return .hour
        case .second:
            return .minute
        case .nanosecond:
            return .second
        default:
            return nil
        }
    }
}

extension DateInterval: @retroactive CustomLocalizedStringConvertible {
    public var localizedDescription: String {
        switch Calendar.current.datePeriod(of: self) {
        case .day:
            return DateFormatter.relative.string(from: start)
        case .month:
            return start.formatted(.dateTime.month().year())
        case .year:
            return start.formatted(.dateTime.year(.extended()))
        case .week:
            if let beforeEnd = beforeEnd {
                return "\(start.formatted(.dateTime.day().month())) - \(beforeEnd.formatted(.dateTime.day().month()))"
            } else {
                return "\(start.formatted(.dateTime.day().month()))"
            }
        case nil:
            if let beforeEnd = beforeEnd {
                return "\(start.formatted(.dateTime.day().month().year())) - \(beforeEnd.formatted(.dateTime.day().month().year()))"
            } else {
                return "\(start.formatted(.dateTime.day().month().year()))"
            }
        }
    }
}
