//
//  CSVAccountImportOptions.swift
//  Finances
//
//  Created by Dmitriy Zharov on 29.11.2023.
//

import SwiftUI
import SwiftData
import AppUI
import OrderedCollections

struct CSVAccountImportOptions: View {
    let data: OrderedSet<String>
    @Binding var strategy: CSVParseStrategy
    
    @Query private var assets: [Asset]
    @State private var dictionary: [String: CSVParseAction] = [:]
    
    var body: some View {
        Section {
            ForEach(data, id: \.self) { row in
                Picker(selection: $dictionary[row]) {
                    Text("Create new")
                        .tag(Optional<CSVParseAction>.none)
                    Text("Don't create")
                        .tag(Optional<CSVParseAction>.some(.skip))
                    if !assets.isEmpty {
                        Section("Import to") {
                            ForEach(assets) { asset in
                                item(asset).tag(Optional<CSVParseAction>.some(
                                    .replace(with: asset.externalIdentifier.uuidString, description: asset.name)
                                ))
                            }
                        }
                    }
                } label: {
                    Text(row)
                }
                .pickerStyle(.menu)
            }
        } header: {
            Text("Options")
        } footer: {
            Text("Link the accounts found in the CSV file to destination accounts.")
                .textStyle(.footer)
        }
        .onChange(of: dictionary, initial: true) {
            strategy.transform[.account] = .replace(dictionary)
        }
        .onChange(of: data, initial: true) { oldValue, newValue in
            if oldValue != newValue || dictionary.isEmpty {
                parse()
            }
        }
    }
    
    func item(_ asset: Asset) -> some View {
        Label(asset.name, systemImage: AssetType(rawValue: asset.type).symbolName)
            .tag(Optional<String>.some(asset.name))
    }
    
    private func parse() {
        var dictionary: [String: CSVParseAction] = [:]
        for asset in assets {
            for identity in asset.identities where data.contains(identity) {
                dictionary[identity] = .replace(with: asset.externalIdentifier.uuidString, description: asset.name)
            }
        }
        self.dictionary = dictionary
    }
}

#Preview {
    CSVAccountImportOptions(data: [], strategy: .constant(.init()))
}
