//
//  TransactionItemRow.swift
//  Finances
//
//  Created by Dmitriy Zharov on 29.10.2023.
//

import SwiftUI
import AppUI
import FoundationExtension
import SwiftData

struct TransactionItemRow: View {
    @Environment(\.editMode) private var editMode
    @Environment(\.modelContext) private var modelContext
    
    let transaction: Transaction
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12.0) {
            if editMode?.wrappedValue == .inactive {
                Image(systemName: SymbolName(rawValue: transaction.category?.symbolName).rawValue)
                    .symbolVariant(.circle.fill)
                    .symbolRenderingMode(.palette)
                    .font(.body)
                    .imageScale(.large)
                    .foregroundStyle(.white, Color(
                        colorName: ColorName(rawValue: transaction.category?.colorName))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4.0) {
                HStack {
                    Text(transaction.payeeName)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    AmountText(transaction.amount, currencyCode: transaction.currencyCode, on: transaction.date)
                        .foregroundStyle(transaction.amount > 0.0 ? .green : .primary)
                }
                .font(.body)
                .imageScale(.small)
                
                HStack {
                    Text(transaction.categoryName)
                    
                    Spacer()
                    
                    Text(transaction.assetName)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if let notes = transaction.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let tags = transaction.tags, !tags.isEmpty {
                    Text(tags.map { "#" + $0.name }.joined(separator: " "))
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            .lineLimit(1)
        }
    }
    
    init(_ transaction: Transaction) {
        self.transaction = transaction
    }
}

#Preview {
    NavigationStack {
        TransactionListView(query: TransactionQuery())
    }
    .modelContainer(previewContainer)
}
