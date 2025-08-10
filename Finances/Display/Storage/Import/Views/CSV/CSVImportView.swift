//
//  CSVImportView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 13.12.2023.
//

import SwiftUI
import SwiftCSV
internal import UniformTypeIdentifiers

struct CSVPickerView: View {
    @Binding var csv: CSV<Named>?
    
    @State private var showPicker: Bool = false
    @State private var error: Error?
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Button("Select a CSV File") {
                        showPicker.toggle()
                    }
                    if let error {
                        Text(error.localizedDescription)
                    }
                } header: {
                    EmptyView()
                } footer: {
                    Text("The chosen CSV file can have any structure.")
                        .textStyle(.footer)
                }
            }
            .formStyle(.grouped)
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            #endif
        }
        .navigationTitle("Import from a CSV File")
        .fileImporter(isPresented: $showPicker, allowedContentTypes: [.commaSeparatedText]) { result in
            switch result {
            case .success(let url):
                do {
                    _ = url.startAccessingSecurityScopedResource()
                    self.csv = try CSV<Named>(url: url)
                    url.stopAccessingSecurityScopedResource()
                } catch {
                    self.error = error
                }
            case .failure(let error):
                self.error = error
            }
        }
        .preferredContentSize(width: 600, height: 350)
    }
}

struct CSVImportView: View {
    @State private var csv: CSV<Named>?
    let onCompletion: () -> Void
    
    var body: some View {
        VStack {
            if let csv {
                CSVImportConfiguratorView(csv: csv, onCompletion: onCompletion)
            } else {
                CSVPickerView(csv: $csv)
            }
        }
    }
}

#Preview {
    CSVImportView {
        
    }
}
