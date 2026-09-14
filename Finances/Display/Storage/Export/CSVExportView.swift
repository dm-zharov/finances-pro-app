//
//  CSVExportView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.11.2023.
//

import SwiftUI
import SwiftData
import AppUI
internal import UniformTypeIdentifiers

struct CommaSeparatedText: Transferable {
    static let filename = "Finances.csv"
    
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .commaSeparatedText) { csv in
            SentTransferredFile(csv.url, allowAccessingOriginalFile: true)
        }
        .suggestedFileName(CommaSeparatedText.filename)
    }
}

struct CSVExportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let onCompletion: () -> Void
    
    @Query(sort: \Asset.name, order: .forward) private var assets: [Asset]
    @Query(sort: \Category.name, order: .forward) private var categories: [Category]
    
    @State private var query = TransactionQuery()
    
    @State private var dateInterval: DateInterval = .defaultValue
    @State private var showDateIntervalPicker: Bool = false
    @State private var showFileExporter: Bool = false
    @State private var exportItem: CommaSeparatedText?
    @State private var exportError: Error?
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Picker("Account", selection: $query.searchAssetID) {
                        Text("All")
                            .tag(Optional<Asset.ExternalID>.none)
                        Divider()
                        ForEach(assets) { asset in
                            Label(asset.name, systemImage: AssetType(rawValue: asset.type)?.symbolName ?? SymbolName.defaultValue.rawValue)
                                .tag(Optional<Asset.ExternalID>.some(asset.externalIdentifier))
                        }
                    }
                    Picker("Category", selection: $query.searchCategoryID) {
                        Text("All")
                            .tag(Optional<Category.ExternalID>.none)
                        Divider()
                        ForEach(categories) { category in
                            Label(category.name, systemImage: SymbolName(rawValue: category.name).rawValue)
                                .tag(Optional<Category.ExternalID>.some(category.externalIdentifier))
                        }
                    }
                }
                
            }
            .formStyle(.grouped)
        }
        .navigationTitle("Export to a CSV File")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Export") {
                    do {
                        exportItem = CommaSeparatedText(url: try export())
                        showFileExporter = true
                    } catch {
                        exportError = error
                    }
                }
            }
        }
        .fileExporter(
            isPresented: $showFileExporter,
            item: exportItem,
            contentTypes: [.commaSeparatedText],
            defaultFilename: CommaSeparatedText.filename,
            onCompletion: { result in
                if case .success = result {
                    onCompletion()
                    dismiss()
                } else if case let .failure(error) = result {
                    exportError = error
                }
            },
            onCancellation: {
                exportItem = nil
            }
        )
        .alert(
            "Export Failed",
            isPresented: Binding(
                get: { exportError != nil },
                set: { if !$0 { exportError = nil } }
            ),
            presenting: exportError
        ) { _ in
            Button("OK") {
                exportError = nil
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .preferredContentSize(width: 600, height: 350)
    }
    
    private func export() throws -> URL {
        let csvEnclosure: String = "\""
        let csvSeparator: String = ","
        let csvHeaders: [String] = [
            "date".enclosured(csvEnclosure),
            "category".enclosured(csvEnclosure),
            "payee".enclosured(csvEnclosure),
            "amount".enclosured(csvEnclosure),
            "currency".enclosured(csvEnclosure),
            "notes".enclosured(csvEnclosure),
            "tags".enclosured(csvEnclosure),
            "account".enclosured(csvEnclosure),
            "transaction_id".enclosured(csvEnclosure)
        ]
        
        var csvString: String = csvHeaders.joined(separator: csvSeparator).appending("\n")
        
        let numberFormatter = NumberFormatter.decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.usesGroupingSeparator = false
        
        for transaction in try modelContext.fetch(query.fetchDescriptor) {
            var csvColumns: [String] = []
            
            let dateString: String = transaction.date.formatted(.iso8601.calendar())
            csvColumns.append(dateString.enclosured(csvEnclosure))
            
            let categoryString: String = transaction.category?.name ?? .empty
            csvColumns.append(categoryString.enclosured(csvEnclosure))
            
            let payeeString: String = transaction.payee?.name ?? .empty
            csvColumns.append(payeeString.enclosured(csvEnclosure))
            
            let amountString: String = numberFormatter.string(from: NSDecimalNumber(decimal: transaction.amount)) ?? .empty
            csvColumns.append(amountString.enclosured(csvEnclosure))
            
            let currencyString: String = transaction.currencyCode.lowercased()
            csvColumns.append(currencyString.enclosured(csvEnclosure))
            
            let notesString: String = transaction.notes ?? .empty
            csvColumns.append(notesString.enclosured(csvEnclosure))
            
            let tagsString: String = transaction.tags?.map(\.name).joined(separator: ", ") ?? .empty
            csvColumns.append(tagsString.enclosured(csvEnclosure))
            
            let accountString: String = transaction.asset?.name ?? .empty
            csvColumns.append(accountString.enclosured(csvEnclosure))
            
            let transactionUUIDString: String = transaction.externalIdentifier.uuidString
            csvColumns.append(transactionUUIDString.enclosured(csvEnclosure))
            
            if csvHeaders.count == csvColumns.count {
                csvString.append(
                    csvColumns.joined(separator: csvSeparator).appending("\n")
                )
            } else {
                assertionFailure()
            }
        }
        
        let fileManager = FileManager.default
        let url = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = url.appending(path: CommaSeparatedText.filename)

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }

        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}

#Preview {
    CSVExportView { }
}

extension String {
    func enclosured(_ enclosure: String = "\"") -> String {
        let escaped = replacingOccurrences(of: enclosure, with: enclosure + enclosure)
        return "\(enclosure)\(escaped)\(enclosure)"
    }
}
