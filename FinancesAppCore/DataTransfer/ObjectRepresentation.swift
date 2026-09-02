//
//  ObjectRepresentation.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.10.2023.
//

import Foundation

/// An object representation for representable types.
protocol ObjectRepresentation {
    func validate() -> Bool
}

/// A type that can be converted to and from an object representation.
protocol ObjectRepresentable {
    associatedtype Representation: ObjectRepresentation
    
    var objectRepresentation: Representation { get set }
}
