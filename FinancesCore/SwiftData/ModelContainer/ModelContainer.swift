//
//  ModelContainer.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.12.2023.
//

import Foundation
import SwiftData

// MARK: - Default

extension ModelContainer {
    public static let `default`: ModelContainer = {
        do {
            return try ModelContainer(for: .default)
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
}
