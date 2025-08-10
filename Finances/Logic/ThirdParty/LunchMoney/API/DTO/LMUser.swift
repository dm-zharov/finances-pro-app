//
//  LMUser.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.09.2023.
//

import Foundation
import CKNetworking

struct LMUser: Decodable, Identifiable {
    /// Unique identifier for user
    let id: UInt64
    /// User's' name
    let name: String
    /// User's email
    let email: String
    /// Unique identifier for the associated budgeting account
    let accountId: UInt64
    /// Name of the associated budgeting account
    let budgetName: String
    /// User-defined label of the developer API key used. Returns null if nothing has been set.
    let apiKeyLabel: String
    
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case name = "userName"
        case email = "userEmail"
        case accountId
        case budgetName
        case apiKeyLabel
    }
}

extension LMUser {
    static let preview = try! LMUser.decode(
        """
        {
          "user_name": "User 1",
          "user_email": "user-1@lunchmoney.dev",
          "user_id": 18328,
          "account_id": 18221,
          "budget_name": "🏠 Family budget"
          "api_key_label": "Side project dev key"
        }
        """
    )
}
