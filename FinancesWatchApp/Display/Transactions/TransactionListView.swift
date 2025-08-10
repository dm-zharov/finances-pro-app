//
//  TransactionListView.swift
//  FinancesWatchApp
//
//  Created by Dmitriy Zharov on 10.03.2024.
//

import AppUI
import FoundationExtension
import SwiftUI
import SwiftData
import CurrencyKit
import OrderedCollections

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var transactions: [Transaction]
    
    private var data: OrderedDictionary<String, [Transaction]> {
        transactions.grouped(by: \.date.localizedDescription)
    }
    
    var body: some View {
        List {
            ForEach(data.elements, id: \.key) { value, transactions in
                Section {
                    ForEach(transactions) { transaction in
                        HStack {
                            Image(systemName: SymbolName(rawValue: transaction.category?.symbolName))
                                .symbolVariant(.circle.fill)
                                .symbolRenderingMode(.palette)
                                .font(.body)
                                .imageScale(.large)
                                .foregroundStyle(.white, Color(colorName: ColorName(rawValue: transaction.category?.colorName)))
                            
                            VStack(alignment: .leading) {
                                Text(transaction.payeeName)
                                    .foregroundColor(.primary)
                                Text(transaction.amount.magnitude, format: .currency(
                                    code: transaction.currencyCode
                                ))
                                .font(.caption)
                                .foregroundStyle(transaction.amount > .zero ? .green : .secondary)
                            }
                            .font(.body)
                            .imageScale(.small)
                        }
                    }
                } header: {
                    Text(value)
                }
            }
        }
        .overlay {
            if transactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions",
                    systemImage: "bag.badge.questionmark",
                    description: nil
                )
            }
        }
        .navigationTitle("Transactions")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button("Add transaction", systemImage: "square.and.pencil") { }
                    .hidden()
            }
        }
    }
    
    init(assetID: Asset.ID?) {
        if let assetID {
            self._transactions = Query(filter: #Predicate<Transaction> { transaction in
                transaction.asset?.persistentModelID == assetID
            }, sort: .defaultValue)
        } else {
            self._transactions = Query(sort: .defaultValue)
        }
    }
}

#Preview {
    NavigationStack {
        TransactionListView(assetID: nil)
    }
    .modelContainer(previewContainer)
}
