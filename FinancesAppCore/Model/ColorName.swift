//
//  ColorName.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.01.2024.
//

import AppUI
import FoundationExtension
import SwiftUI

public struct ColorName: Hashable, RawRepresentable, Sendable {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension ColorName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension ColorName: DefaultValueProvidable {
    public static let defaultValue: ColorName = .gray
}

// MARK: - System

extension ColorName: CaseIterable {
    public static let red: ColorName = "red"
    public static let orange: ColorName = "orange"
    public static let yellow: ColorName = "yellow"
    public static let green: ColorName = "green"
    public static let mint: ColorName = "mint"
    public static let teal: ColorName = "teal"
    public static let cyan: ColorName = "cyan"
    public static let blue: ColorName = "blue"
    public static let indigo: ColorName = "indigo"
    public static let purple: ColorName = "purple"
    public static let pink: ColorName = "pink"
    public static let brown: ColorName = "brown"
    public static let gray: ColorName = "gray"
    
    public static let allCases: [ColorName] = [red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple, pink, brown, gray]
}

// MARK: - Web

extension ColorName {
    public static func hex(_ hexString: String) -> ColorName? {
        if let _ = CGColor.sRGB(hexString) {
            return ColorName(rawValue: hexString)
        } else {
            return nil
        }
    }
}

extension Color {
    public init(colorName: ColorName) {
        switch colorName {
        case .red:
            self = .red
        case .orange:
            self = .orange
        case .yellow:
            self = .yellow
        case .green:
            self = .green
        case .mint:
            self = .mint
        case .teal:
            self = .teal
        case .cyan:
            self = .cyan
        case .blue:
            self = .blue
        case .indigo:
            self = .indigo
        case .purple:
            self = .purple
        case .pink:
            self = .pink
        case .brown:
            self = .brown
        case .gray:
            self = .gray
        default:
            if let cgColor = CGColor.sRGB(colorName.rawValue) {
                self.init(cgColor: cgColor)
            } else {
                assertionFailure()
                self = .clear
            }
        }
    }
}

extension PlatformColor {
    public class func named(_ colorName: ColorName) -> PlatformColor {
        switch colorName {
        case .red:
            return .systemRed
        case .orange:
            return .systemOrange
        case .yellow:
            return .systemYellow
        case .green:
            return .systemGreen
        case .mint:
            return .systemMint
        case .teal:
            return .systemTeal
        case .cyan:
            return .systemCyan
        case .blue:
            return .systemBlue
        case .indigo:
            return .systemIndigo
        case .purple:
            return .systemPurple
        case .pink:
            return .systemPink
        case .brown:
            return .systemBrown
        case .gray:
            return .systemGray
        default:
            if let cgColor = CGColor.sRGB(colorName.rawValue) {
                #if canImport(UIKit)
                return self.init(cgColor: cgColor)
                #endif
                
                #if canImport(AppKit)
                return self.init(cgColor: cgColor)!
                #endif
            } else {
                assertionFailure()
                return .clear
            }
        }
    }
}
