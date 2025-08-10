//
//  AssetListSection.swift
//  Finances
//
//  Created by Dmitriy Zharov on 23.11.2023.
//

import SwiftUI
import AppUI
import SwiftData
import OSLog
import FinancesCore

struct AssetListSection: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.editMode) private var editMode
    
    @Binding var selection: Set<SelectedValue>
    
    @Query(sort: \Asset.lastUpdatedDate, order: .reverse, animation: .default) private var assets: [Asset]

    @State private var valueAssetList: SelectedValue?
    @State private var editAssetList: EditMode = .inactive
    @State private var showAssetList: Bool = false
    @State private var showImportView: Bool = false
    
    @State private var showAccountConfigurator = false
    
    private var visibleAssets: [Asset] {
        editMode.isEditing ? assets : assets.filter { $0.isHidden == false }
    }
    
    @MainActor
    var header: some View {
        HStack {
            #if os(iOS)
            Button {
                showAssetList.toggle()
            } label: {
                HStack(spacing: 4.0) {
                    Text("Assets")
                        .listHeaderStyle(.large)
                    
                    if !editMode.isEditing && !assets.isEmpty {
                        Image(systemName: "chevron.forward")
                            .tint(.secondary)
                            .fontWeight(.bold)
                    }
                }
            }
            .disabled(editMode.isEditing)
            .allowsHitTesting(!assets.isEmpty)
            #else
            Text("Assets")
                .listHeaderStyle(.large)
                .listHeaderAccessory {
                    if !assets.isEmpty {
                        Button("", systemImage: "plus.circle") {
                            showAccountConfigurator.toggle()
                        }
                    }
                }
            #endif
            
            if assets.isEmpty {
                Spacer()
                
                Button {
                    showImportView.toggle()
                } label: {
                    Text("Import")
                        .textCase(.uppercase)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 4.0)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
        }
        .listRowInsets(.init(top: 10.0, leading: 0, bottom: 8.0, trailing: 0))
        .headerProminence(.increased)
        .onChange(of: editMode.isEditing) { wasEditing, isEditing in
            if wasEditing == false, isEditing == true {
                // Automatically select visible assets on editing.
                selection = Set(assets.filter { $0.isHidden == false }.map { asset in
                    return .transactions(query: TransactionQuery(searchAssetID: asset.externalIdentifier))
                })
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            if editMode.isEditing { // Update visibility of the assets.
                assets.forEach { asset in
                    if !asset.isHidden != selection.contains(
                        .transactions(query: TransactionQuery(searchAssetID: asset.externalIdentifier))
                    ) {
                        asset.isHidden.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showAssetList, onDismiss: {
            if let route = valueAssetList {
                navigator.root = route; valueAssetList = nil
            }
        }) {
            NavigationStack {
                AssetListView(displayRoute: $valueAssetList)
                    .environment(\.editMode, $editAssetList)
                    .onDisappear { if editAssetList.isEditing { editAssetList = .inactive } }
            }
        }
        .sheet(isPresented: $showAccountConfigurator) {
            NavigationStack {
                AccountConfiguratorView(isPresented: $showAccountConfigurator)
            }
        }
        .sheet(isPresented: $showImportView) {
            NavigationStack {
                ImportView(isPresented: $showImportView)
            }
        }
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        // Assets
        Section {
            if !visibleAssets.isEmpty {
                ForEach(visibleAssets.ordered(by: SettingKey.assetsOrder), id: \.route) { asset in
                    NavigationLink(route: .transactions(
                        query: TransactionQuery(searchAssetID: asset.externalIdentifier)
                    )) {
                        AssetItemRow(asset)
                    }
                }
                .onMove { source, destination in
                    Logger.maths.debug("Move from \(source) to \(destination)")
                    visibleAssets.reorder(SettingKey.assetsOrder, fromOffsets: source, toOffset: destination)
                }
            } else if assets.isEmpty {
                TipItem(AssetListSectionTip())
                Button("Add Asset", systemImage: "plus.circle") {
                    showAccountConfigurator.toggle()
                }
            } else {
                transactions
            }
        } header: {
            header
        }
        #if os(macOS)
        .collapsible(false)
        .badgeProminence(.decreased)
        #endif
        
        // Finances
        if !visibleAssets.isEmpty {
            transactions
                #if os(iOS)
                .listSectionSpacing(.custom(16.0))
                #endif
        }
    }
    
    var transactions: some View {
        Section {
            NavigationLink(route: editMode.isEditing ? nil : .transactions()) {
                Label {
                    Text("Show All Transactions")
                } icon: {
                    Image(systemName: "calendar.day.timeline.leading")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.accent, .secondary)
                }
            }
            .selectionDisabled(editMode.isEditing)
        }
        .disabled(editMode.isEditing)
    }
}

private extension Asset {
    var route: NavigationRoute {
        .transactions(query: TransactionQuery(searchAssetID: externalIdentifier))
    }
}

#Preview {
    List {
        AssetListSection(selection: .constant([]))
    }
    .modelContainer(previewContainer)
}
