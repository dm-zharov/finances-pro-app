//
//  Sequence+OrderedDictionary.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10.03.2024.
//

import OrderedCollections
import Foundation

extension Sequence {
    func grouped<T: Hashable>(by transform: (Element) -> T) -> OrderedDictionary<T, [Element]> {
        OrderedDictionary(grouping: self) { element in
            transform(element)
        }
    }

    func grouped<T: Hashable>(by keyPath: KeyPath<Element, T>) -> OrderedDictionary<T, [Element]> {
        OrderedDictionary(grouping: self) { element in
            element[keyPath: keyPath]
        }
    }
}
