//
//  String+Empty.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.09.2023.
//

import Foundation

extension String {
    static var empty: String {
        ""
    }
}

extension Collection where Element: ExpressibleByArrayLiteral {
    static var empty: Element {
        []
    }
}

extension Collection where Element: ExpressibleByDictionaryLiteral {
    static var empty: Element {
        [:]
    }
}
