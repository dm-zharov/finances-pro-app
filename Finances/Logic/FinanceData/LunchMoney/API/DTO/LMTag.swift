//
//  LMTag.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.09.2023.
//

import Foundation

struct LMTag: Codable, Identifiable, Hashable {
    /// Unique identifier for tag
    let id: UInt64
    /// User-defined name of tag
    let name: String
    /// User-defined description of tag
    let description: String?
}

