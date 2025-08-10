//
//  ImportMergeView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10.12.2023.
//

import TipKit
import SwiftUI
import OrderedCollections
import SwiftData

struct ImportMergeTip: Tip {
    @Parameter
    static var isEnabled: Bool = true
    
    private let count: Int
    
    var title: Text {
        Text("\(count) Duplicates Found")
    }
    
    var message: Text? {
        Text("Duplicate transactions are automatically skipped. Review for accuracy if needed.")
    }
    
    var actions: [Action] {
        [Action(title: "Review Duplicates")]
    }
    
    var rules: [Rule] {
        #Rule(Self.$isEnabled) {
            $0 == true
        }
    }
    
    init(count: Int) {
        self.count = count
    }
}

struct ImportMergeView: View {
    @Environment(\.modelContext) private var privateContext
    @Environment(\.dismiss) private var dismiss
    
    let transactions: [Transaction]
    let onCompletion: (Set<Transaction.ID>) -> Void
    
    @State private var selection: Set<Transaction.ID> = []
    @State private var sortBy: [SortDescriptor<Transaction>] = .defaultValue
    
    var confirmationTitle: String {
        switch selection.count {
        case 0:
            "Nothing to Import"
        case 1:
            "Import 1 Transaction"
        default:
            "Import \(selection.count) Transactions"
        }
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        TransactionList(transactions, selection: $selection, sortBy: $sortBy) { transaction in
            TransactionItemRow(transaction)
                .deleteDisabled(true)
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Duplicates Found")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .confirmationContainer {
            Button(confirmationTitle) {
                onCompletion(selection); dismiss()
            }
            .disabled(selection.isEmpty)
            
            Button("Ignore All", role: .cancel) {
                dismiss()
            }
        }
        .preferredContentSize(minWidth: 500.0, minHeight: 420.0)
    }
    
    init(_ transactions: [Transaction], onCompletion: @escaping (Set<Transaction.ID>) -> Void) {
        self.transactions = transactions
        self.onCompletion = onCompletion
    }
}

#Preview {
    NavigationStack {
        ImportMergeView([], onCompletion: { _ in })
    }
    .modelContainer(previewContainer)
}
