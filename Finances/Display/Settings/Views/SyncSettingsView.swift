//
//  SyncSettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.11.2023.
//

import SwiftUI

struct SyncSettingsView: View {
    var body: some View {
        VStack {
            List {
                
            }
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            #endif
        }
        .navigationTitle("iCloud Sync")
    }
}


#Preview {
    SyncSettingsView()
}
