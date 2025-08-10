//
//  API+User.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2022.
//

import Combine
import CKNetworking

extension API {
    /// Use this endpoint to get details on the current user.
    func getUser() -> AnyPublisher<LMUser, Error> {
        get("/me")
    }
}
