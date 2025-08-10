//
//  APIService.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2022.
//

import Foundation
import Combine
import CKNetworking

class APIService: NSObject, NetworkingService, ObservableObject {
    let network: NetworkingClient

    init(token: String) {
        let client = NetworkingClient(
            baseURL: URL(string: "https://dev.lunchmoney.app/v1")!,
            securityPolicy: .defaultPolicy,
            authenticationCredential: .init(
                session: .serverTrust,
                task: .bearer(token: token)
            ),
            configuration: .default
        )
        
        client.parameterEncoding = .json
        client.timeout = 45
        
        client.storeResponseFilesInCacheDirectory = false
        client.logLevels = .debug
        
        self.network = client
    }
}

// MARK: - URLSessionDelegate, URLSessionTaskDelegate
extension APIService: URLSessionDelegate, URLSessionTaskDelegate { }

