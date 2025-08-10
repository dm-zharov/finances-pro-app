//
//  SettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.10.2023.
//

import SwiftUI
import Combine
import SwiftData

struct SettingsView: View {
    @Binding var isPresented: Bool
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            List {
                data
                system
                storage
                feedback
                if 4 == 5 {
                    about
                }
            }
            .environment(\.defaultMinListRowHeight, 48.0)
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            .listRowInsets(.init(top: 10.0, leading: 16.0, bottom: 10.0, trailing: 16.0))
            #endif
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                CloseButton {
                    isPresented.toggle()
                }
            }
        }
    }
    
    var unlock: some View {
        Section {
            PromotionView()
        }
    }
    
    var data: some View {
        Section {
            NavigationLink {
                CurrencySettingsView()
            } label: {
                CurrencySettingsLabel()
            }
            
            NavigationLink {
                CategorySettingsView()
                    .environment(\.editMode, $editMode)
                    .onDisappear { if editMode.isEditing { editMode = .inactive } }
            } label: {
                CategorySettingsLabel()
            }
            
            NavigationLink {
                MerchantSettingsView()
            } label: {
                MerchantSettingsLabel()
            }
            
            NavigationLink {
                TagSettingsView()
            } label: {
                TagSettingsLabel()
            }
        }
    }
    
    var system: some View {
        Section("System") {
            NavigationLink {
                AppearanceSettingsView()
            } label: {
                AppearanceSettingsLabel()
            }
            
            if 4 == 5 {
                NavigationLink {
                    NotificationSettingsView()
                } label: {
                    NotificationSettingsLabel()
                }
            }
            
            if 4 == 5 {
                NavigationLink {
                    SyncSettingsView()
                } label: {
                    SyncSettingsLabel()
                }
            }
            
            NavigationLink {
                SecuritySettingsView()
            } label: {
                SecuritySettingsLabel()
            }
        }
    }
    
    var storage: some View {
        Section("Storage") {
            NavigationLink {
                ImportExportSettingsView()
            } label: {
                ImportExportSettingsLabel()
            }
            
            if 4 == 5 {
                NavigationLink {
                    BackupSettingsView()
                } label: {
                    BackupSettingsLabel()
                }
            }
        }
    }
    
    var feedback: some View {
        Section("Feedback") {
            ReviewButton()
            #if os(iOS)
            MailButton()
            #endif
        }
    }
    
    var about: some View {
        Section {
            NavigationLink {
                AboutAppView()
            } label: {
                AboutAppLabel()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(isPresented: .constant(true))
    }
    .modelContainer(previewContainer)
}
