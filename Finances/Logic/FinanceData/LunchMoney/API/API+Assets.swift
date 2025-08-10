//
//  API+Assets.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import Combine
import CKNetworking

// MARK: - Get All Assets
extension API {
    struct Assets: Decodable {
        let assets: [LMAsset]
    }
    
    /// Use this endpoint to get a flattened list of all categories in alphabetical order associated with the user's account.
    func getAssets() -> AnyPublisher<Assets, Error> {
        get("/assets")
    }
}

// MARK: - Create Asset
extension API { }

// MARK: - Update Asset
extension API { }
