//
//  Collection+Extension.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10/08/2025.
//

import Algorithms

extension Collection {
    public func partitioning(
      where belongsInSecondPartition: (Element) throws -> Bool
    ) rethrows -> Element? {
        let index = try partitioningIndex(where: belongsInSecondPartition)
        guard index != endIndex else { return nil }
        return self[index]
    }
}
