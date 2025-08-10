//
//  CSVParseStrategy+Transform.swift
//  Finances
//
//  Created by Dmitriy Zharov on 01.12.2023.
//

import Foundation

protocol ValueTransformer: Hashable, Codable {
    associatedtype TransformInput
    associatedtype TransformOutput
    
    func transform(_ value: TransformInput) -> TransformOutput
}

enum CSVParseAction: Hashable, Codable {
    case replace(with: String, description: String? = nil)
    case skip
}

extension CSVParseStrategy {
    enum CSVColumnTransformer: ValueTransformer {
        case date(_ format: String)
        case replace(_ dictionary: [String: CSVParseAction])
        
        func transform(_ value: String) -> String? {
            switch self {
            case let .date(format):
                let dateComponents = value.components(separatedBy: CharacterSet.dateSeparators)
                let dateString = Array(dateComponents.prefix(3)).joined(separator: "-")
                let dateFormatter = DateFormatter.fixed
                dateFormatter.dateFormat = format
                return dateFormatter.date(from: dateString)?.formatted(.iso8601.calendar()) ?? .empty
            case let .replace(dictionary):
                switch dictionary[value] {
                case .none:
                    return value
                case let .replace(target, description: _):
                    return target
                case .skip:
                    return nil
                }
            }
        }
        
        func description(_ value: String) -> String? {
            if case let .replace(dictionary) = self, case let .replace(with: value, description) = dictionary[value] {
                return description ?? transform(value)
            } else {
                return transform(value)
            }
        }
    }
}

