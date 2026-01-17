//
//  FinancesSceneDelegate.swift
//  Finances
//
//  Created by Dmitriy Zharov on 04.04.2024.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import FoundationExtension

class FinancesSceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        windowScene.updateTraitOverrides()
        
        if let shortcutItem = connectionOptions.shortcutItem {
            // Save it off for later when we become active.
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        return true
    }
}

// MARK: - UITrait

extension UIWindowScene {
    func updateTraitOverrides() {
        @KeyValueSetting(SettingKey.preferredColorScheme, store: UserDefaults.shared) var preferredColorScheme: ColorScheme?
        if let colorScheme = preferredColorScheme {
            traitOverrides.userInterfaceStyle = UIUserInterfaceStyle(colorScheme)
        } else {
            traitOverrides.remove(UITraitUserInterfaceStyle.self)
        }
    }
}
#endif
