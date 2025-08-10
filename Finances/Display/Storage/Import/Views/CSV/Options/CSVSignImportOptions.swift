//
//  CSVSignImportOptions.swift
//  Finances
//
//  Created by Dmitriy Zharov on 13.12.2023.
//

import SwiftUI
import OrderedCollections

struct CSVSignImportOptions: View {
    let data: OrderedSet<String>
    @Binding var strategy: CSVParseStrategy
    
    @State private var dictionary: [String: CSVParseAction] = [:]

    @State private var minus: String?
    @State private var error: Bool = false
    
    var body: some View {
        Section {
            if error {
                LabeledContent {
                    Text("Failure")
                        .foregroundStyle(.red)
                } label: {
                    Text(String(localized: FloatingPointSign.minus.localizedStringResource) + " " + String(localized: "is"))
                }
            } else {
                Picker(selection: $minus) {
                    ForEach(data, id: \.self) { row in
                        Text(row)
                            .tag(row)
                    }
                    
                } label: {
                    Text(String(localized: FloatingPointSign.minus.localizedStringResource) + " " + String(localized: "is"))
                }
            }
        } header: {
            Text("Options")
        }
        .onChange(of: minus) {
            
            var dictionary: [String: String] = [:]
            for row in data {
                if row == minus {
                    dictionary[row] = FloatingPointSign.minus.description
                } else {
                    dictionary[row] = FloatingPointSign.plus.description
                }
            }
        }
        .onChange(of: dictionary) {
            strategy.transform[.sign] = .replace(dictionary)
        }
        .onChange(of: minus) {
            parse()
        }
        .onChange(of: data, initial: true) {
            parse()
        }
    }
    
    private func parse() {
        var dictionary: [String: CSVParseAction] = [:]
        if data.count == 2 {
            for row in data {
                if row == minus {
                    dictionary[row] = .replace(with: FloatingPointSign.minus.description)
                } else {
                    dictionary[row] = .replace(with: FloatingPointSign.plus.description)
                }
            }
        } else {
            for row in data {
                dictionary[row] = .replace(with: .empty)
            }
        }
        self.dictionary = dictionary
    }
}

#Preview {
    CSVSignImportOptions(data: [], strategy: .constant(.init()))
}
