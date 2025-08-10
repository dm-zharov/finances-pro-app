//
//  AssetSelectorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import SwiftUI
import SwiftData
import CurrencyKit

struct StackBox<Content>: View where Content: View {
    let content: Content
    
    var body: some View {
        #if os(iOS)
        VStack {
            content
        }
        #else
        Form {
            content
        }
        .formStyle(.grouped)
        #endif
    }
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
}

struct AssetSelectorView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.currency) private var currency
    @Environment(\.editMode) private var editMode
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selection: UUID?
    
    // MARK: - State
    
    @Query private var assets: [Asset]
    @State private var selectedAssetID: Asset.ID?
    @State private var showAssetEditor: Container<Asset.ID>?
    @State private var showAccountConfigurator: Bool = false
    
    @SceneStorage("AssetListGroupBy") private var groupBy: Asset.GroupBy = .defaultValue
    @State private var showHidden: Bool = false
    
    var body: some View {
        VStack {
            List(selection: $selectedAssetID) {
                AssetListContent(assets.filter { $0.isHidden == false || showHidden }, id: \.id, groupBy: groupBy)
                #if os(iOS)
                    .inlineMenuVisibility(editMode.isEditing)
                #endif
                if let _ = selection, !editMode.isEditing {
                    Button("Unaccounted") {
                        selection = .none; dismiss()
                    }
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
        }
        .navigationTitle("Asset")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            #if os(iOS)
            ToolbarItemGroup(placement: .primaryAction) {
                if !editMode.isEditing, assets.contains(where: { $0.isHidden == true }) {
                    Menu("Edit") {
                        Button("Edit Assets", systemImage: "pencil") {
                            withAnimation {
                                editMode?.wrappedValue = .active
                            }
                        }

                        Divider()
                        
                        Picker("Group By", systemImage: "square.stack.3d.up", selection: $groupBy) {
                            ForEach(Asset.GroupBy.allCases, id: \.self) { groupBy in
                                Text(String(localized: groupBy.localizedStringResource))
                                    .tag(groupBy)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Divider()

                        Button(
                            showHidden ? "Hide Hidden Assets" : "Show Hidden Assets",
                            systemImage: showHidden ? "eye.slash" : "eye"
                        ) {
                            showHidden.toggle()
                        }
                    }
                } else {
                    EditButton()
                }
            }
            #endif
            
            ToolbarItemGroup(placement: .toolbar) {
                if editMode.isEditing {
                    ToolbarSpacer()
                    Button("Add Asset") {
                        showAccountConfigurator.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showAccountConfigurator) {
            NavigationStack {
                AccountConfiguratorView(isPresented: $showAccountConfigurator)
            }
        }
        .sheet(item: $showAssetEditor, onDismiss: { selectedAssetID = nil }) { container in
            NavigationStack {
                if let assetID = container.id, let asset: Asset = modelContext.registeredModel(for: assetID) {
                    AssetEditorView(asset)
                } else {
                    AssetEditorView()
                }
            }
        }
        .onChange(of: selectedAssetID) {
            if let selectedAssetID {
                if editMode.isEditing {
                    showAssetEditor = Container(id: selectedAssetID)
                } else {
                    if let asset: Asset = modelContext.registeredModel(for: selectedAssetID) {
                        selection = asset.externalIdentifier; dismiss()
                    } else {
                        return assertionFailure()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AssetSelectorView(selection: .constant(nil))
    }
    .modelContainer(previewContainer)
}
