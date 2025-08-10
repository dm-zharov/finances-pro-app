//
//  MerchantQuery.swift
//  Finances
//
//  Created by Dmitriy Zharov on 18.04.2024.
//

import Foundation
import SwiftData

struct MerchantQuery: Equatable {
    var searchCategoryID: Category.ExternalID? = nil
    var searchDateInterval: DateInterval?
}
