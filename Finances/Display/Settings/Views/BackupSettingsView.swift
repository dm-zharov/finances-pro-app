//
//  BackupSettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.11.2023.
//

import SwiftUI

struct BackupSettingsView: View {
    var body: some View {
        VStack {
            List {
                
            }
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            #endif
        }
        .navigationTitle("Backups")
    }
}

#Preview {
    BackupSettingsView()
}
