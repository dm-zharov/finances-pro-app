//
//  MainScene.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.12.2023.
//

import SwiftUI
import SwiftAuthn
import TipKit
import WidgetKit
import SwiftData

struct MainScene: Scene {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup(id: "Main") {
            ContentView()
                .authentication("View Finances", reason: Text("Finances Are Locked"))
                .onChange(of: scenePhase) {
                    if scenePhase == .inactive {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
        }
        .modelContainer(.default)
    #if os(macOS)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentSize)
        .defaultSize(width: 975, height: 400)
    #endif
    }
}
