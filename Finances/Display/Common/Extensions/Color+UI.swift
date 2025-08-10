//
//  PlatformColor.swift
//  Finances
//
//  Created by Dmitriy Zharov on 12.02.2024.
//

import SwiftUI
import AppUI

extension Color {
    #if canImport(UIKit)
    static func ui(_ uiColor: UIColor) -> Color {
        Color(uiColor: uiColor)
    }
    #endif
    
    #if canImport(AppKit)
    static func ui(_ nsColor: NSColor) -> Color {
        Color(nsColor: nsColor)
    }
    #endif
}
