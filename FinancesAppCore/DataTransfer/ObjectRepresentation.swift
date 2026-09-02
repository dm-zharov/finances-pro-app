//
//  ObjectRepresentation.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.10.2023.
//

import Foundation

/// An object representation for representable types.
protocol ObjectRepresentation {
    associatedtype Item: ObjectRepresentable where Item.Representation == Self
    
    func validate() -> Bool
}

/// A type that can be converted to and from an object representation.
protocol ObjectRepresentable {
    associatedtype Representation: ObjectRepresentation where Representation.Item == Self
    
    var objectRepresentation: Representation { get set }
}
