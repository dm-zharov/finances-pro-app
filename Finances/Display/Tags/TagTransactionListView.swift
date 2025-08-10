//
//  TagTransactionListView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.12.2023.
//

import SwiftUI
import SwiftData

struct TagTransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var tags: [Tag]
    @State private var sortBy: [SortDescriptor<Transaction>] = .defaultValue
    @State private var showTransactionEditor: Container<PersistentIdentifier>?
    
    private var title: String {
        switch tags.count {
        case 0: return "All Tags"
        case 1: return "#" + (tags.first?.name ?? "Undefined")
        default:
            return "\(tags.count.formatted()) Tags"
        }
    }
    
    var body: some View {
        VStack {
            if let transactions = .some(tags.reduce([], { result, tag in result + (tag.transactions ?? []) })), !transactions.isEmpty {
                TransactionList(transactions, sortBy: $sortBy) { transaction in
                    TransactionItemRow(transaction)
                }
                .contextMenu(forSelectionType: Transaction.ID.self) { selection in
                    switch selection.count {
                    case 0:
                        EmptyView()
                    case 1:
                        if let id = selection.first, selection.count == 1 {
                            Button("Edit", systemImage: "pencil") {
                                showTransactionEditor = Container(id: id)
                            }
                            Divider()
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                if let transaction: Transaction = modelContext.registeredModel(for: id) {
                                    withAnimation {
                                        transaction.performWithRelationshipUpdates {
                                            modelContext.delete(transaction)
                                        }
                                    }
                                }
                            }
                        }
                    default:
                        EmptyView()
                    }
                } primaryAction: { selection in
                    switch selection.count {
                    case 1:
                        if let id = selection.first {
                            showTransactionEditor = Container(id: id)
                        }
                    default:
                        break
                    }
                }
                .status(Text("Entire Period"), description: Text("\(transactions.count) Transactions"))
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .onAppear {
                        tags.forEach { tag in
                            modelContext.delete(tag)
                        }
                        dismiss()
                    }
            }
        }
        .navigationTitle(title)
        .toolbar {
            #if os(iOS)
            ToolbarItemGroup(placement: .primaryAction) {
                menu
            }
            #else
            ToolbarItemGroup(placement: .secondaryAction) {
                menu
            }
            #endif
        }
        .sheet(item: $showTransactionEditor) { container in
            NavigationStack {
                if let transactionID = container.id, let transaction: Transaction = modelContext.registeredModel(for: transactionID) {
                    TransactionEditorView(transaction)
                }
            }
        }
    }
    
    @ViewBuilder
    private var menu: some View {
        CurrencyConversionButton()
        
        Menu("Menu", systemImage: "ellipsis.circle") {
            if tags.count == 1, let tag = tags.first {
                Button("Delete Tag", systemImage: "trash") {
                    modelContext.delete(tag)
                }
                
                Divider()
            }
        }
    }
    
    init(tags: Set<Tag.ExternalID>) {
        self._tags = Query(filter: #Predicate<Tag> { tag in
            tags.contains(tag.name)
        }, animation: .default)
    }
}
