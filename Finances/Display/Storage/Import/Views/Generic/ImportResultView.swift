//
//  ImportResultView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 01.12.2023.
//

import SwiftUI
import SwiftData
import SwiftCSV
import TipKit
import OrderedCollections

struct ImportResultView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let statement: Statement
    let onCompletion: () -> Void
    
    private let store = StoreQuery(modelContainer: .default)
    
    @State private var sortBy: [SortDescriptor<Transaction>] = .defaultValue
    
    // Assets & Categories
    @State private var assets: [Asset] = []
    @State private var categories: [Category] = []
    
    // Transactions
    @State private var uniques: [Transaction] = []
    @State private var duplicates: [Transaction] = []
    
    @State private var isLoading: Bool = true
    @State private var showMerging: Bool = false
    
    var description: String {
        var strings: [String] = [
            String(localized: "\(uniques.count) Transactions", comment: "Import result")
        ]
        if !categories.isEmpty {
            strings.append(
                String(localized: "\(categories.count) Categories", comment: "Import result")
            )
        }
        if !assets.isEmpty {
            strings.append(
                String(localized: "\(assets.count) Assets", comment: "Import result")
            )
        }
        return strings.joined(separator: " • ")
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            if isLoading {
                VStack(spacing: 16.0) {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Please wait...")
                }
                .task(priority: .high) {
                    await retrieve(); isLoading = false
                }
            } else if !uniques.isEmpty {
                TransactionList(uniques.sorted(using: sortBy), sortBy: $sortBy) { transaction in
                    TransactionItemRow(transaction)
                        .deleteDisabled(true)
                        .selectionDisabled()
                } header: {
                    if !duplicates.isEmpty {
                        mergeTip
                    }
                }
                .interactiveDismissDisabled()
                .status(Text("To Import"), description: Text(description))
            } else {
                List {
                    if !duplicates.isEmpty {
                        mergeTip
                    }
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .overlay {
                    ContentUnavailableView(
                        "Nothing to Import",
                        systemImage: "exclamationmark.magnifyingglass",
                        description: Text("Please ensure that data is not empty.")
                    )
                }
            }
        }
        .navigationTitle("Preview")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    Task(priority: .high) {
                        await rollback(); dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Import") {
                    Task(priority: .high) {
                        await save(); onCompletion()
                    }
                }
                .disabled(uniques.isEmpty)
            }
        }
        .sheet(isPresented: $showMerging) {
            NavigationStack {
                ImportMergeView(duplicates, onCompletion: { selection in
                    Task(priority: .high) {
                        var indexSet = IndexSet()
                        var representations: [TransactionRepresentation] = []
                        for (index, transaction) in duplicates.enumerated() {
                            if selection.contains(transaction.id) {
                                indexSet.insert(index)
                                representations.append(transaction.objectRepresentation)
                            }
                        }
                        do {
                            let (uniques, _) = try await store.store(representations, ignoringDuplicates: true)

                            self.uniques.append(contentsOf: uniques)
                            self.duplicates.remove(atOffsets: indexSet)
                        } catch {
                            assertionFailure(error.localizedDescription)
                        }
                    }
                })
            }
        }
        .preferredContentSize(minWidth: 500.0, minHeight: 420.0)
    }
    
    var mergeTip: some View {
        TipView(ImportMergeTip(count: duplicates.count), arrowEdge: nil) { action in
            showMerging.toggle()
        }
        .listRowSeparator(.hidden)
    }
    
    init(_ statement: Statement, onCompletion: @escaping () -> Void) {
        self.statement = statement
        self.onCompletion = onCompletion
    }
}

extension ImportResultView {
    func retrieve() async {
        do {
            (self.assets, _) = try await store.store(statement.assets)
            (self.categories, _) = try await store.store(statement.categories)
            (self.uniques, self.duplicates) = try await store.store(statement.transactions)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    func rollback() async {
        await store.rollback()
    }
    
    func save() async {
        do {
            try await store.save()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
