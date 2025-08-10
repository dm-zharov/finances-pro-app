//
//  ToolbarItemPlacement.swift
//  Finances
//
//  Created by Dmitriy Zharov on 26.12.2023.
//

import SwiftUI

extension ToolbarItemPlacement {
    public static let toolbar: ToolbarItemPlacement = {
        #if os(iOS)
        return .bottomBar
        #else
        return .primaryAction
        #endif
    }()
    
    public static let closeAction: ToolbarItemPlacement = {
        #if os(iOS)
        return .confirmationAction
        #else
        return .cancellationAction
        #endif
    }()
}
