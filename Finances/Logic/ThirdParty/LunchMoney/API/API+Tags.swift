//
//  API+Tags.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import Combine
import CKNetworking

// MARK: - Get All Tags
extension API {
    /// Use this endpoint to get a list of all tags associated with the user's account.
    func getTags() -> AnyPublisher<[LMTag], Error> {
        get("/tags")
    }
}
