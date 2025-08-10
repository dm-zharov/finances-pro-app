//
//  FinancesAppDelegate.swift
//  Finances
//
//  Created by Dmitriy Zharov on 13.11.2023.
//

import Foundation

class FinancesAppDelegate: NSObject { }

#if canImport(UIKit)
import UIKit

extension FinancesAppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = FinancesSceneDelegate.self
        return sceneConfig
    }
}
#endif

#if canImport(AppKit)
import AppKit

extension FinancesAppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        
    }
}
#endif
