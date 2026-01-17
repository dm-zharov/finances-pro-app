//
//  SettingsScene.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.12.2023.
//

#if os(macOS)
import SwiftUI
import SwiftAuthn
import SwiftData

struct SettingsScene: Scene {
    @State private var selection: Int = 0
    @State private var isPresented: Bool = false
    
    var body: some Scene {
        Settings {
            TabView(selection: $selection) {
                CurrencySettingsView()
                    .tag(0)
                    .tabItem {
                        CurrencySettingsLabel()
                    }
                
                AccountSettingsView()
                    .tag(1)
                    .tabItem {
                        AccountSettingsLabel()
                    }
                
                CategorySettingsView()
                    .tag(2)
                    .tabItem {
                        CategorySettingsLabel()
                    }
                
                if 3 == 4 {
                    SecuritySettingsView()
                        .tag(3)
                        .tabItem {
                            SecuritySettingsLabel()
                        }
                }
                
                ImportExportSettingsView()
                    .tag(4)
                    .tabItem {
                        ImportExportSettingsLabel()
                    }
                
                if 4 == 5 {
                    AboutAppView()
                        .tag(5)
                        .tabItem {
                            AboutAppLabel()
                        }
                }
            }
            .authentication("Unlock", reason: Text("Settings Are Locked"))
            .preferredContentSize(minWidth: 716, minHeight: 472)
        }
        .modelContainer(.default)
    }
}
#endif
