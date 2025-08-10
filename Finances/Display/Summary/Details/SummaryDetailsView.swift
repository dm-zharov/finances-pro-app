//
//  SummaryDetailsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.04.2024.
//

import Foundation

@MainActor
protocol SummaryDetailsView {
    var dateInterval: DateInterval { get }
    var calendar: Calendar { get }
}

extension SummaryDetailsView {
    var granularity: Calendar.Component {
        if let granularity = calendar.granularity(for: dateInterval) {
            return granularity == .year ? .month : .day
        } else {
            return .day
        }
    }
}
