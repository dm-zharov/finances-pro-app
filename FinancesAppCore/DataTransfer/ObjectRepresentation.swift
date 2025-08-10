//
//  ObjectRepresentation.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.10.2023.
//

import Foundation

/// A object representation for representable types.
protocol ObjectRepresentation {
    associatedtype Item: ObjectRepresentable
}

/// A type that can be converted to and from an associated value.
protocol ObjectRepresentable {
    associatedtype Representation
    
    var objectRepresentation: Representation { get set }
}
