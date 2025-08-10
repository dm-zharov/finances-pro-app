//
//  UserDefaults+Shared.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.01.2024.
//

import Foundation
import FoundationExtension

extension UserDefaults {
    @available(iOSApplicationExtension, unavailable)
    public static let shared: UserDefaults = SyncedDefaults(groupContainerIdentifier: Constants.AppGroup.id)
}
