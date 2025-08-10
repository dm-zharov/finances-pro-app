//
//  AssetItemRow.swift
//  Finances
//
//  Created by Dmitriy Zharov on 02.10.2023.
//

import SwiftUI
import AppUI
import SwiftData

struct AssetItemRow: View {
    @Environment(\.isInlineMenuVisible) private var isInlineMenuVisible
    @Environment(\.badgeProminence) private var badgeProminence
    @Environment(\.backgroundProminence) private var backgroundProminence
    @Environment(\.modelContext) private var modelContext
    
    let asset: Asset
    
    @State private var showAssetEditor: Bool = false
    @State private var showAssetDetails: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    private let height: CGFloat = 40.0
    
    var body: some View {
        LabeledContent {
            if isInlineMenuVisible {
                Menu {
                    menuItems
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.accent)
                        .imageScale(.large)
                }
            }
        } label: {
            Label {
                HStack { Spacer() }
                    .frame(height: height)
                    .overlay(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text(asset.name)
                                .font(.body)
                            AmountText(asset.balance, currencyCode: asset.currencyCode)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .imageScale(.small)
                    }
            } icon: {
                HStack {
                    Image(systemName: asset.symbolName)
                        .imageSize(badgeProminence != .decreased ? 24.0 : nil)
                        .symbolVariant(badgeProminence != .decreased ? .circle.fill : .none)
                        .symbolRenderingMode(badgeProminence != .decreased ? .hierarchical : .none)
                        .foregroundStyle(backgroundProminence == .standard ? (!asset.isHidden ? .accent : .secondary) : .white)
                }
                .frame(height: height)
            }
            .lineLimit(1)
        }
        .frame(height: height)
        .contextMenu {
            menuItems
        }
        .sheet(isPresented: $showAssetEditor) {
            NavigationStack {
                AssetEditorView(asset)
            }
        }
        .sheet(isPresented: $showAssetDetails) {
            NavigationStack {
                AssetDetailsView(asset)
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete \(asset.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible,
            actions: {
                Button("Hide the asset") {
                    asset.isHidden = true
                }
                Button("Delete the asset only", role: .destructive) {
                    modelContext.delete(asset)
                }
                Button("Delete the asset with transactions", role: .destructive) {
                    for transaction in (asset.transactions ?? []) {
                        transaction.performWithRelationshipUpdates([.payee, .tags]) {
                            modelContext.delete(transaction)
                        }
                    }
                    modelContext.delete(asset)
                }
                Button("Cancel", role: .cancel) {
                    showDeleteConfirmation.toggle()
                }
            }, message: {
                Text("Deleting the asset could affect financial reports.\nChoose wisely. You cannot undo this action.")
            }
        )
        .frame(height: height)
    }
    
    @ViewBuilder
    private var menuItems: some View {
        Button("Edit Asset", systemImage: "pencil") {
            showAssetEditor.toggle()
        }
        Button("Get Info", systemImage: "info.circle") {
            showAssetDetails.toggle()
        }
        Divider()
        if asset.isHidden {
            Button("Show on Main Screen", systemImage: "eye") {
                asset.isHidden.toggle()
            }
        } else {
            Button("Hide from Main Screen", systemImage: "eye.slash") {
                asset.isHidden.toggle()
            }
        }
        Button("Delete", systemImage: "trash", role: .destructive) {
            showDeleteConfirmation.toggle()
        }
    }
    
    init(_ asset: Asset) {
        self.asset = asset
    }
}
