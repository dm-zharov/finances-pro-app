//
//  TransactionDetailsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 03.04.2024.
//

import SwiftUI
import CurrencyKit
import FoundationExtension
import SwiftData

struct TransactionDetailsView: View {
    @Environment(\.currency) private var currency
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showTransactionEditor: Bool = false
    
    // MARK: - Data
    
    let transaction: Transaction
    
    var body: some View {
        VStack {
            List {
                Section {
                    VStack(alignment: .center) {
                        Text(transaction.amount.magnitude.formatted(.currency(transaction.currency, usage: .standard)))
                            .font(.system(size: 64.0))
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .foregroundStyle(transaction.amount.sign == .minus ? Color.primary : Color.green)
                            .frame(maxWidth: .infinity)

                        Text("\(transaction.payeeName) · \(transaction.categoryName)")
                            .foregroundStyle(.secondary)
                        
                        Text(transaction.date.formatted(Date.FormatStyle(date: .numeric, time: .omitted)))
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                }
                .listRowInsets(.zero)
                .listRowBackground(Color.clear)
                
                Section {
                    LabeledContent("From", value: transaction.assetName)
                }
                
                if let notes = transaction.notes {
                    Section("Notes") {
                        Text(notes)
                    }
                }
                
                if transaction.currency != currency {
                    Section("Conversion Info") {
                        LabeledContent {
                            Text(transaction.amount(in: currency).magnitude.formatted(.currency(currency)))
                                .foregroundStyle(transaction.amount.sign == .minus ? Color.secondary : Color.green)
                        } label: {
                            Text("Amount in Base Currency")
                        }
                        LabeledContent {
                            Text(CurrencyRatesStore.shared.rate(
                                for: Currency(transaction.currencyCode), relativeTo: currency, on: transaction.date
                            ).formatted())
                        } label: {
                            Text("Conversion Rate")
                        }

                    }
                }
                
                if let payee = transaction.payee, let transactions = payee.transactions, transactions.count > 1 {
                    Section("Payee Statistics") {
                        LabeledContent(
                            "Average Transaction Value",
                            value: transactions.map { transaction in transaction.amount(in: currency).magnitude }.average().formatted(.currency(currency))
                        )
                        LabeledContent(
                            "Transaction Volume",
                            value: transactions.map { transaction in transaction.amount(in: currency).magnitude }.sum().formatted(.currency(currency))
                        )
                        LabeledContent(
                            "Transaction Count",
                            value: transactions.count.formatted()
                        )
                    }
                }
                
                Section {
                    Button("Delete Transaction", role: .destructive) {
                        withAnimation {
                            transaction.performWithRelationshipUpdates {
                                modelContext.delete(transaction)
                            }
                            dismiss()
                        }
                    }
                    .foregroundStyle(.red)
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            .contentMargins(.top, .compact, for: .scrollContent)
            #endif
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showTransactionEditor.toggle()
                }
            }
        }
        .sheet(isPresented: $showTransactionEditor) {
            NavigationStack {
                TransactionEditorView(transaction)
            }
        }
    }
    
    init(_ transaction: Transaction) {
        self.transaction = transaction
    }
}
