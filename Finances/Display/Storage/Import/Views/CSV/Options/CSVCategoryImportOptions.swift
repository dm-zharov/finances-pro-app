//
//  CSVCategoryImportOptions.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.11.2023.
//

import SwiftUI
import SwiftData
import AppUI
import OrderedCollections
import FoundationExtension

struct CSVCategoryImportOptions: View {
    let data: OrderedSet<String>
    @Binding var strategy: CSVParseStrategy
    
    @Query private var categories: [Category]
    @State private var dictionary: [String: CSVParseAction] = [:]
    
    var body: some View {
        Section {
            ForEach(data, id: \.self) { row in
                Picker(selection: $dictionary[row]) {
                    Text("Create new")
                        .tag(Optional<CSVParseAction>.none)
                    Text("Don't create")
                        .tag(Optional<CSVParseAction>.some(.skip))
                    if !categories.isEmpty {
                        Section("Import to") {
                            ForEach(categories) { category in
                                item(category)
                                    .tag(Optional<CSVParseAction>.some(
                                        .replace(with: category.externalIdentifier.uuidString, description: category.name)
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
            Text("Link the categories found in the CSV file to destination categories.")
                .textStyle(.footer)
        }
        .onChange(of: dictionary, initial: true) {
            strategy.transform[.category] = .replace(dictionary)
        }
        .onChange(of: data, initial: true) { oldValue, newValue in
            if oldValue != newValue || dictionary.isEmpty {
                parse()
            }
        }
    }
    
    func item(_ category: Category) -> some View {
        Label(category.name, systemImage: SymbolName(rawValue: category.symbolName).rawValue)
            .lineLimit(1)
    }
    
    private func parse() {
        var dictionary: [String: CSVParseAction] = [:]
        for category in categories {
            for identity in category.identities {
                if data.contains(identity) {
                    dictionary[identity] = .replace(with: category.externalIdentifier.uuidString, description: category.name)
                }
            }
        }
        self.dictionary = dictionary
    }
}

#Preview {
    CSVCategoryImportOptions(data: [], strategy: .constant(.init()))
}
