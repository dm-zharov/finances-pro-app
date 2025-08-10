//
//  TransactionListView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2022.
//

import SwiftUI
import SwiftData
import AppUI
import FoundationExtension
import OSLog
import OrderedCollections
import CurrencyKit

struct Container<ID>: Hashable, Identifiable where ID: Hashable & Identifiable {
    var id: ID?
}

struct TransactionListView: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.currency) private var currency
    @Environment(\.dateInterval) private var dateInterval
    @Environment(\.modelContext) private var modelContext

    @SceneStorage("TransactionListViewStyle") private var viewStyle: ViewStyle = {
        #if os(macOS)
        .table
        #else
        .list
        #endif
    }()
    @SceneStorage("TransactionListShowGroupTotal") private var showDailyTotal: Bool = false
    
    @State private var showQuickEditor: Bool = false
    @State private var showTransactionEditor: Container<Transaction.ID>?
    @State private var showTransactionDetails: Transaction.ID?
    @State private var showAssetDetails: Asset.ID?
    @State private var quickEditorID = UUID()
    
    // MARK: - Public
    
    @State private var query: TransactionQuery
    
    // MARK: - Private
    
    private var title: String {
        if let assetID = query.searchAssetID, let asset = modelContext.existingModel(Asset.self, with: assetID) {
            return asset.name
        } else {
            return String(localized: "Transactions")
        }
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        DynamicQueryView(
            query: Query(query.fetchDescriptor, animation: .default)
        ) { transactions in
            if !transactions.isEmpty || showQuickEditor {
                ScrollViewReader { proxy in
                    list(transactions: transactions)
                        #if os(iOS)
                        .status(
                            Text(dateInterval.localizedDescription),
                            description: Text("\(transactions.count) Transactions")
                        )
                        #else
                        .status(Text("\(transactions.count) Transactions"))
                        #endif
                        .onChange(of: showQuickEditor) {
                            if showQuickEditor {
                                proxy.scrollTo(quickEditorID, anchor: .top)
                            }
                        }
                        .onChange(of: horizontalSizeClass) {
                            if horizontalSizeClass == .compact {
                                viewStyle = .list
                            }
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            } else {
                ContentUnavailableView(
                    "No Transactions",
                    systemImage: "bag.badge.questionmark",
                    description: Text("No transactions for the selected period.")
                )
            }
        }
        .navigationTitle(title)
        #if os(iOS)
        .toolbarTitleDisplayMode(.large)
        #endif
        .toolbar {
            ToolbarItemGroup(placement: userInterfaceIdiom != .mac ? .primaryAction : .secondaryAction) {
                if userInterfaceIdiom == .mac {
                    if let assetID = query.searchAssetID, let asset = modelContext.existingModel(Asset.self, with: assetID) {
                        Button("Show Asset Info", systemImage: "info.circle") {
                            showAssetDetails = asset.id
                        }
                        
                        Divider()
                    }
                    
                    styleSelector
                    Divider()
                }
                
                CurrencyConversionButton()
                
                if userInterfaceIdiom != .mac {
                    Menu("Menu", systemImage: "ellipsis.circle") {
                        if let assetID = query.searchAssetID, let asset = modelContext.existingModel(Asset.self, with: assetID) {
                            Button("Show Asset Info", systemImage: "info.circle") {
                                showAssetDetails = asset.id
                            }
                            
                            Divider()
                        }
                        
                        if horizontalSizeClass != .compact {
                            styleSelector
                            Divider()
                        }
                        
                        sortBySelector
                        
                        groupBySelector
                        
                        Divider()
                        
                        Toggle(
                            !showDailyTotal ? "Show Group Total" : "Hide Group Total",
                            systemImage: !showDailyTotal ? "eye" : "eye.slash",
                            isOn: $showDailyTotal
                        )
                    }
                }
            }
            
            ToolbarItemGroup(placement: .toolbar) {
                ToolbarSpacer()

                if query.searchAssetID != nil, viewStyle == .list, userInterfaceIdiom != .mac {
                    TransactionButton(isQuick: true) {
                        withAnimation {
                            quickEditorID = UUID(); showQuickEditor.toggle()
                        }
                    }
                    .disabled(showQuickEditor)
                } else {
                    TransactionButton(isQuick: false) {
                        showTransactionEditor = Container(id: nil)
                    }
                }
            }
        }
        .sheet(item: $showTransactionEditor) { container in
            NavigationStack {
                if let transactionID = container.id, let transaction: Transaction = modelContext.registeredModel(for: transactionID) {
                    TransactionEditorView(transaction)
                } else {
                    TransactionEditorView(nil)
                }
            }
        }
        .sheet(item: $showAssetDetails) { assetID in
            NavigationStack {
                if let asset: Asset = modelContext.registeredModel(for: assetID) {
                    AssetDetailsView(asset)
                }
            }
        }
    }
    
    private func list(transactions: [Transaction]) -> some View {
        TransactionList(
            transactions,
            sortBy: $query.sortBy,
            groupBy: query.groupBy,
            viewStyle: viewStyle
        ) { transaction in
            TransactionItemRow(transaction)
        } header: {
            if showQuickEditor {
                TransactionEditorRow(query: query) { result in
                    withAnimation {
                        showQuickEditor = false
                    }
                }
                .id(quickEditorID)
            }
        }
        .contextMenu(forSelectionType: Transaction.ID.self) { selection in
            switch selection.count {
            case 0:
                EmptyView()
            case 1:
                if let transactionID = selection.first {
                    Button("Edit", systemImage: "pencil") {
                        showTransactionEditor = Container(id: transactionID)
                    }
                    Divider()
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        if let transaction: Transaction = modelContext.registeredModel(for: transactionID) {
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
            case 1 where showQuickEditor == false:
                if let transactionID = selection.first, let transaction: Transaction = modelContext.registeredModel(for: transactionID) {
                    #if os(macOS)
                    showTransactionEditor = Container(id: transaction.id)
                    #else
                    navigator.path.append(.transaction(id: transaction.externalIdentifier))
                    #endif
                }
            default:
                break
            }
        }
    }
    
    private var styleSelector: some View {
        Picker(selection: $viewStyle) {
            Label("List", systemImage: "list.bullet")
                .tag(ViewStyle.list)
            Label("Table", systemImage: "tablecells")
                .tag(ViewStyle.table)
        } label: {
            #if os(iOS)
            EmptyView()
            #else
            Text("Style")
            #endif
        }
        .pickerStyle(.inline)
        .disabled(showQuickEditor)
    }
    
    private var sortBySelector: some View {
        Menu("Sort By", systemImage: "arrow.up.arrow.down") {
            ForEach(
                Transaction.SortOrder.allCases.filter({ sortBy in
                    switch sortBy {
                    case .amount:
                        return query.searchAssetID != nil
                    default:
                        return true
                    }
                }),
                id: \.self
            ) { sortOrder in
                if let sortDescriptor = query.sortBy.first(where: { sortDescriptor in
                    sortDescriptor.keyPath == Transaction.sortDescriptor(sortOrder).keyPath
                }) {
                    Button(String(localized: sortOrder.localizedStringResource), systemImage: sortDescriptor.order.symbolName) {
                        guard let sortDescriptorIndex = query.sortBy.lastIndex(where: { sortDescriptor in
                            sortDescriptor.keyPath == Transaction.sortDescriptor(sortOrder).keyPath
                        }) else {
                            return
                        }
                        query.sortBy[sortDescriptorIndex].order.toggle()
                    }
                } else {
                    Button(String(localized: sortOrder.localizedStringResource)) {
                        query.sortBy = [Transaction.sortDescriptor(sortOrder)]
                    }
                }
            }
        }
    }
    
    private var groupBySelector: some View {
        Picker("Group By", systemImage: "square.stack.3d.up", selection: $query.groupBy) {
            ForEach(
                Transaction.GroupBy.allCases.filter({ groupBy in
                    switch groupBy {
                    case .category:
                        return query.searchCategoryID == nil
                    case .asset:
                        return query.searchAssetID == nil
                    default:
                        return true
                    }
                }),
                id: \.self
            ) { groupBy in
                Text(String(localized: groupBy.localizedStringResource))
                    .tag(groupBy)
            }
        }
        .pickerStyle(.menu)
    }
    
    /// - Attention: Force reinitialization by changing view identity.
    init(query: TransactionQuery) {
        _query = State(wrappedValue: query)
    }
}

#Preview {
    NavigationStack {
        TransactionListView(query: TransactionQuery())
    }
    .modelContainer(previewContainer)
}

extension Transaction {
    var container: Container<Transaction.ID> {
        Container(id: id)
    }
}
