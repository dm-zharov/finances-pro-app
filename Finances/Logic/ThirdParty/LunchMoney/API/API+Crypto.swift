//
//  API+Crypto.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import Combine
import CKNetworking

// MARK: - Get All Crypto
extension API {
    enum GetCrypto {
        struct Response: Decodable {
            let crypto: [LMCrypto]
        }
    }
    
    /// Use this endpoint to get a list of all cryptocurrency assets associated with the user's account. Both crypto balances from synced and manual accounts will be returned.
    func getCrypto() -> AnyPublisher<GetCrypto.Response, Error> {
        get("/crypto")
    }
}

// MARK: - Update Manual Crypto Asset
extension API {
    enum UpdateCrypto {
        struct Body: Encodable {
            /// Official or full name of the account. Max 45 characters
            var name: String?
            /// Display name for the account. Max 25 characters
            var display_name: String?
            /// Name of provider that holds the account. Max 50 characters
            var institution_name: String?
            /// Numeric value of the current balance of the account. Do not include any special characters aside from a decimal point!
            var balance: Int?
            /// Cryptocurrency that is supported for manual tracking in our database
            var currency: String?
        }
    }
    
    /// Use this endpoint to update a single manually-managed crypto asset (does not include assets received from syncing with your wallet/exchange/etc). These are denoted by source: manual from the GET call above.
    func updateCrypto(with id: String, body: UpdateCrypto.Body = .init()) -> AnyPublisher<Void, Error> {
        put("/crypto/manual/\(id)", data: body.asParams())
    }
}
