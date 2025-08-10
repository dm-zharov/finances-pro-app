//
//  ParsingStrategy.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import Foundation

@propertyWrapper
struct StringRepresentation<T: LosslessStringConvertible> {
    let wrappedValue: String
    let projectedValue: T?
    
    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
        self.projectedValue = T(wrappedValue)
    }
    
}

extension StringRepresentation: Decodable {
    init(from decoder: Decoder) throws {
        let string = try String(from: decoder)
        self.init(wrappedValue: string)
    }
}

extension StringRepresentation: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension StringRepresentation: Hashable {
    func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
    
    var hashValue: Int {
        wrappedValue.hashValue
    }
}
