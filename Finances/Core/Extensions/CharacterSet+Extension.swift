//
//  CharacterSet+Extension.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10/08/2025.
//

import Foundation

extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(contains(_:))
    }
}
