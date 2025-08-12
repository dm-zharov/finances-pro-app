//
//  AssetListView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 21.12.2022.
//

import SwiftUI
import SwiftData

struct AssetListView: View {
    // MARK: - Environment

    @Environment(\.currency) private var currency
    @Environment(\.editMode) private var editMode
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Binding var displayRoute: NavigationRoute?
    
    @State private var selection: Asset.ID?
    
    // MARK: - State
    
    @State private var showAccountConfigurator = false
    @State private var showAssetEditor: Container<Asset.ID>?
    
    @SceneStorage("AssetListGroupBy") private var groupBy: Asset.GroupBy = .defaultValue
    
    var body: some View {
        DynamicQueryView(
            query: Query(AssetQuery(sortBy: [Asset.sortDescriptor()]).fetchDescriptor)
        ) { assets in
            if !assets.isEmpty {
                AssetList(assets, selection: $selection, groupBy: groupBy)
                #if os(iOS)
                    .inlineMenuVisibility(editMode.isEditing)
                #endif
                    .contextMenu(forSelectionType: Asset.ID.self) { selection in
                        EmptyView()
                    } primaryAction: { selection in
                        switch selection.count {
                        case 1:
                            if let assetID = selection.first, let asset: Asset = modelContext.registeredModel(for: assetID) {
                                displayRoute = .transactions(
                                    query: TransactionQuery(searchAssetID: asset.externalIdentifier)
                                )
                                dismiss()
                            }
                        default:
                            return
                        }
                    }
                    .onChange(of: selection) {
                        if let selection {
                            showAssetEditor = Container(id: selection)
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .status) {
                            VStack {
                                Text("Balance")
                                AmountText(assets.sum(in: currency), currencyCode: currency.identifier)
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)
                        }
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            } else {
                ContentUnavailableView(
                    "No Assets",
                    systemImage: "folder.badge.plus",
                    description: Text("Add Asset to get started.")
                )
            }
        }
        .navigationTitle("Assets")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                CancelButton {
                    dismiss()
                }
            }
            
            #if os(iOS)
            ToolbarItemGroup(placement: .primaryAction) {
                if !editMode.isEditing {
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
                    }
                } else {
                    EditButton()
                }
            }
            #endif
            
            ToolbarItemGroup(placement: .toolbar) {
                _ToolbarSpacer()

                Button("Add Asset") {
                    showAccountConfigurator.toggle()
                }
            }
        }
        .sheet(item: $showAssetEditor, onDismiss: { selection = nil }) { container in
            NavigationStack {
                if let assetID = container.id, let asset: Asset = modelContext.registeredModel(for: assetID) {
                    AssetEditorView(asset)
                }
            }
        }
        .sheet(isPresented: $showAccountConfigurator) {
            NavigationStack {
                AccountConfiguratorView(isPresented: $showAccountConfigurator)
            }
        }
        .preferredContentSize(width: 480.0, height: 600.0)
    }
}

#Preview {
    NavigationStack {
        AssetListView(displayRoute: .constant(nil))
    }
    .modelContainer(previewContainer)
}
