//
//  CategoryQuery.swift
//  Finances
//
//  Created by Dmitriy Zharov on 18.04.2024.
//

import Foundation
import SwiftData

struct CategoryQuery: Equatable {
    var searchGroupID: CategoryGroup.ExternalID? = nil
    var searchMerchantID: Merchant.ExternalID? = nil
    var searchDateInterval: DateInterval?
}
