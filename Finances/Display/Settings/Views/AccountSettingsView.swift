//
//  AccountSettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 19.12.2023.
//

import SwiftUI
import SwiftData

struct AccountSettingsView: View {
    @Environment(\.currency) private var currency
    @Environment(\.modelContext) private var modelContext
    
    @Query private var assets: [Asset]
    @State private var editMode: EditMode = .active

    @State private var showAccountConfigurator: Bool = false
    @State private var showAssetEditor: Asset.ID?
    
    var body: some View {
        StackBox {
            if !assets.isEmpty {
                Section("Overview") {
                    LabeledContent("Balance") {
                        AmountText(assets.sum(in: currency), currencyCode: currency.identifier)
                    }
                }
                
                Section {
                    ForEach(AssetType.allCases, id: \.self) { assetType in
                        if let assets = .some(assets.filter(by: assetType)), !assets.isEmpty {
                            List(selection: $showAssetEditor) {
                                AssetListContent(assets.filter(by: assetType), id: \.id)
                            }
                        }
                    }
                } header: {
                    Text("Assets")
                } footer: {
                    #if os(macOS)
                    Button("Add Asset") {
                        showAccountConfigurator.toggle()
                    }
                    .padding(.top, 8.0)
                    #endif
                }
            } else {
                AssetsUnavailableView()
            }
        }
        .navigationTitle("Accounts")
        .sheet(item: $showAssetEditor) { assetID in
            if let asset: Asset = modelContext.registeredModel(for: assetID) {
                NavigationStack {
                    AssetEditorView(asset)
                }
            }
            
        }
        .sheet(isPresented: $showAccountConfigurator) {
            NavigationStack {
                AccountConfiguratorView(isPresented: $showAccountConfigurator)
            }
        }
    }
}

#Preview {
    AccountSettingsView()
}
