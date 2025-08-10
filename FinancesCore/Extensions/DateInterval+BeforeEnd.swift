//
//  DateInterval+BeforeEnd.swift
//  Finances
//
//  Created by Dmitriy Zharov on 13.10.2023.
//

import Foundation

extension DateInterval {
    var beforeEnd: Date? {
        if duration >= 1 {
            return end.addingTimeInterval(-1)
        } else {
            return nil
        }
    }
}
