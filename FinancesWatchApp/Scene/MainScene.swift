//
//  MainScene.swift
//  FinancesWatchApp
//
//  Created by Dmitriy Zharov on 10.03.2024.
//

import SwiftUI
import SwiftData

struct MainScene: Scene {
    var body: some Scene {
        WindowGroup(id: "Main") {
            ContentView()
        }
        .modelContainer(.default)
    }
}
