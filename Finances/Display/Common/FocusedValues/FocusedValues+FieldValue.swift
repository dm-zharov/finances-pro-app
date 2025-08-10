//
//  FocusedValues+FieldValue.swift
//  Finances
//
//  Created by Dmitriy Zharov on 22.11.2023.
//

import SwiftUI

struct FocusedField: FocusedValueKey {
    enum Field {
        case payee
        case category
        case tags
        case notes
    }
    
    typealias Value = Field
}

extension FocusedValues {
    var fieldValue: FocusedField.Value? {
        get { self[FocusedField.self] }
        set { self[FocusedField.self] = newValue }
    }
}
