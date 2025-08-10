//
//  AssetDetailsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 19.04.2024.
//

import SwiftUI
import SwiftData
import AppUI
import FoundationExtension

struct AssetDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    let asset: Asset
    
    @State private var showAssetEditor: Bool = false
    
    var kind: AssetType {
        AssetType(rawValue: asset.type, default: .other)
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    VStack(alignment: .center) {
                        Image(systemName: kind.symbolName)
                            .imageSize(64.0)
                            .symbolVariant(.circle.fill)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.accent)
                        Text(asset.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(kind.localizedStringResource)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowInsets(.zero)
                .listRowBackground(Color.clear)
                
                Section {
                    LabeledContent {
                        AmountText(asset.balance, currencyCode: asset.currencyCode)
                    } label: {
                        Text(balanceName(of: kind))
                    }
                } header: {
                    Text("Details")
                } footer: {
                    Text("Created on \(asset.creationDate.formatted(date: .numeric, time: .omitted)).\nLast updated \(asset.lastUpdatedDate.formatted(date: .numeric, time: .omitted)).")
                        .textStyle(.footer)
                }
            }
            .formStyle(.grouped)
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            #endif
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                DoneButton {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showAssetEditor.toggle()
                }
            }
        }
        .sheet(isPresented: $showAssetEditor) {
            NavigationStack {
                AssetEditorView(asset)
            }
        }
        .preferredContentSize(minWidth: 500.0, minHeight: 420.0)
    }
    
    func balanceName(of assetType: AssetType) -> String {
        switch kind {
        case .cash:
            return String(localized: "Amount")
        case .checking, .savings, .brokerage:
            return String(localized: "Balance")
        case .other:
            return String(localized: "Value")
        }
    }
    
    init(_ asset: Asset) {
        self.asset = asset
    }
}

#Preview {
    NavigationStack {
        DynamicQueryView(
            query: Query(FetchDescriptor<Asset>())
        ) { assets in
            AssetDetailsView(assets[0])
        }
    }
    .modelContainer(previewContainer)
}

