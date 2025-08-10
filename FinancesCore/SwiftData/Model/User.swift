//
//  User.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2022.
//

import Foundation
import SwiftData

@Model
class User: Identifiable {
    /// User's email
    var email: String?
    /// User's' name
    var name: String?
    
    init(email: String, name: String) {
        self.email = email
        self.name = name
    }
}
