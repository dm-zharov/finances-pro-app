//
//  ImportView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.11.2023.
//

import SwiftUI
import AppUI

struct ImportView: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            #if os(iOS)
            list
            #else
            form
            #endif
        }
        .toolbar {
            ToolbarItem(placement: .closeAction) {
                CloseButton {
                    isPresented.toggle()
                }
            }
        }
        .preferredContentSize(width: 600, height: 350)
    }
    
    #if os(iOS)
    @MainActor
    var list: some View {
        List {
            content
        }
        .contentMargins(.top, .zero, for: .scrollContent)
        .listStyle(.insetGrouped)
        .listRowInsets(.init(top: 10.0, leading: 16.0, bottom: 10.0, trailing: 16.0))
        .environment(\.defaultMinListRowHeight, 48.0)
    }
    #endif
    
    #if os(macOS)
    var form: some View {
        Form {
            content
        }
        .formStyle(.grouped)
        .headerProminence(.increased)
    }
    #endif
    
    @ViewBuilder
    var content: some View {
        NavigationTitle(
            "Import Your Accounts &\u{00A0}Transactions",
            description: "Get your existing financial data into the app.",
            systemImage: userInterfaceIdiom == .mac ? "square.and.arrow.down.on.square" : nil
        )
        .navigationTitleStyle(.large)
        
        Section {
            NavigationLink {
                LunchMoneyImportView {
                    isPresented.toggle()
                }
            } label: {
                Label("From a Lunch Money", systemImage: "cloud")
            }
        } header: {
            Text("Service")
        } footer: {
            Text("Automatically imports everything at once.")
                .textStyle(.footer)
        }
        
        Section {
            NavigationLink {
                CSVImportView {
                    isPresented.toggle()
                }
            } label: {
                Label("From a CSV File", systemImage: "list.triangle")
            }
        } header: {
            Text("File")
        } footer: {
            Text("Manual import process with flexible customization.")
                .textStyle(.footer)
        }
    }
}

#Preview {
    ImportView(isPresented: .constant(true))
}
