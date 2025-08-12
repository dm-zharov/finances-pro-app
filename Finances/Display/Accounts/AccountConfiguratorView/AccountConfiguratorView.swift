//
//  AccountConfiguratorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.09.2023.
//

import SwiftUI
import AppUI
import AppIntents

struct AccountConfiguratorView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Form {
                NavigationTitle(
                    "Add Account",
                    description: "Keep all the financial resources in one place."
                )
                .navigationTitleStyle(.large)

                Section {
                    ForEach(AssetType.allCases, id: \.self) { assetType in
                        NavigationLink(value: assetType) {
                            row(
                                title: AssetType.caseDisplayRepresentations[assetType]!.title,
                                subtitle: AssetType.caseDisplayRepresentations[assetType]!.subtitle,
                                symbolName: SymbolName(rawValue: assetType.symbolName)
                            )
                        }
                    }
                    .listRowInsets(.init(top: 11.0, leading: 16.0, bottom: 11.0, trailing: 16.0))
                } header: {
                    Text("Asset")
                }
                
                Section {
                    ForEach(LiabilityType.allCases, id: \.self) { liabilityType in
                        NavigationLink {
                            
                        } label: {
                            row(
                                title: LiabilityType.caseDisplayRepresentations[liabilityType]!.title,
                                subtitle: LiabilityType.caseDisplayRepresentations[liabilityType]!.subtitle,
                                symbolName: SymbolName(rawValue: liabilityType.symbolName)
                            )
                        }
                        .disabled(true)
                        .listRowInsets(.init(top: 11.0, leading: 16.0, bottom: 11.0, trailing: 16.0))
                    }
                } header: {
                    HStack {
                        Text("Liability")
                        Spacer()
                        Text("Coming Soon \(Image(systemName: "info.circle"))")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .headerProminence(.increased)
            #if os(iOS)
            .contentMargins(.top, .zero, for: .scrollContent)
            .environment(\.defaultMinListRowHeight, 40)
            #endif
        }
        .navigationDestination(for: AssetType.self) { assetType in
            AssetEditorView(assetType: assetType)
                .environment(\.isFinished, $isPresented.reversed())
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton {
                    isPresented.toggle()
                }
            }
        }
        .preferredContentSize(width: 600, height: 600)
    }
    
    func row(
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource?,
        symbolName: SymbolName
    ) -> some View {
        Label {
            HStack { Spacer() }
                .frame(height: 40.0)
                .overlay(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(String(localized: title))
                        if let subtitle {
                            Text(String(localized: subtitle))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
        } icon: {
            HStack {
                if symbolName.rawValue == "c.circle" {
                    Image(systemName: "c")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolVariant(.square.fill)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.accent)
                        .frame(width: 30.0, height: 30.0)
                } else {
                    RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .foregroundStyle(.accent.tertiary)
                        .frame(width: 30.0, height: 30.0)
                        .overlay {
                            Image(systemName: symbolName.rawValue).resizable()
                                .aspectRatio(contentMode: .fit)
                                .symbolVariant(.fill)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.accent)
                                .frame(width: 18.0, height: 18.0)
                        }
                }
            }
            .frame(height: 40.0)
        }
    }
}

#Preview {
    NavigationStack {
        AccountConfiguratorView(isPresented: .constant(true))
    }
}

extension Binding where Value == Bool {
    func reversed() -> Self {
        Binding(get: { !wrappedValue }, set: { newValue in wrappedValue = !newValue })
            .transaction(transaction)
    }
}
