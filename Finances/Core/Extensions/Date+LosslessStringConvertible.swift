//
//  Date+LosslessStringConvertible.swift
//  Finances
//
//  Created by Dmitriy Zharov on 26.09.2023.
//

import Foundation

extension Date: LosslessStringConvertible {
    public init?(_ description: String) {
        if let iso8601Date = try? Date(description, strategy: .iso8601) {
            self = iso8601Date
        } else if let iso8601CalendarDate = try? Date(description, strategy: .iso8601.calendar()) {
            self = iso8601CalendarDate
        } else {
            return nil
        }
    }
}

extension Date.ISO8601FormatStyle {
    public func calendar() -> Date.ISO8601FormatStyle {
        year().month().day() // YYYY-MM-dd
    }
}
