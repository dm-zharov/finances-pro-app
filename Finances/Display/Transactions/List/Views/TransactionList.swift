//
//  TransactionList.swift
//  Finances
//
//  Created by Dmitriy Zharov on 11.12.2023.
//

import SwiftUI
import SwiftData
import AppUI
import FoundationExtension
import OrderedCollections

extension Collection {
    func elements(atOffsets offsets: IndexSet) -> [Self.Element] where IndexSet.Element == Self.Index {
        offsets.map { index in self[index] }
    }
}

enum ViewStyle: String {
    case list = "List"
    case table = "Table"
}

struct TransactionList<Header, Row>: View where Header: View, Row: View {
    @Environment(\.currency) private var currency
    @Environment(\.modelContext) private var modelContext

    let header: () -> Header
    let row: (Transaction) -> Row
    
    let transactions: [Transaction]
    let selection: Binding<Set<Transaction.ID>>?
    @Binding var sortBy: [SortDescriptor<Transaction>]
    let groupBy: Transaction.GroupBy
    let viewStyle: ViewStyle

    @State private var _selection: Set<Transaction.ID> = []
    private var data: OrderedDictionary<String, [Transaction]> {
        switch groupBy {
        case .none:
            return [:]
        case .date:
            return transactions.grouped(by: \.date.localizedDescription)
        case .payee:
            return transactions.grouped(by: \.payeeName)
        case .category:
            return transactions.grouped(by: \.categoryName)
        case .asset:
            return transactions.grouped(by: \.assetName)
        case .currency:
            return transactions.grouped(by: \.currency.localizedDescription)
        }
    }

    @SceneStorage("TransactionTableConfig") private var columnCustomization: TableColumnCustomization<Transaction>
    @SceneStorage("TransactionListShowGroupTotal") private var showDailyTotal: Bool = false
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        switch viewStyle {
        case .list:
            list
        case .table:
            table
        }
    }
    
    @MainActor
    var list: some View {
        func content(for transactions: [Transaction]) -> some View {
            ForEach(transactions) { transaction in
                row(transaction)
            }
            .onDelete { indexSet in
                for transaction in transactions.elements(atOffsets: indexSet) {
                    transaction.performWithRelationshipUpdates {
                        modelContext.delete(transaction)
                    }
                }
            }
        }
        
        return List(selection: selection ?? $_selection) {
            header()
            switch groupBy {
            case .none:
                content(for: transactions)
            default:
                ForEach(data.elements, id: \.key) { value, transactions in
                    Section {
                        content(for: transactions)
                    } header: {
                        header(with: value, for: transactions)
                    }
                }
            }
        }
        .listStyle(.inset)
        .headerProminence(.increased)
    }
    
    var table: some View {
        Table(
            of: Transaction.self,
            selection: selection ?? $_selection,
            sortOrder: $sortBy,
            columnCustomization: $columnCustomization
        ) {
            TableColumn("Payee") { transaction in
                Label {
                    Text(transaction.payeeName)
                } icon: {
                    Image(systemName: SymbolName(rawValue: transaction.category?.symbolName).rawValue)
                        .foregroundStyle(Color(colorName: ColorName(rawValue: transaction.category?.colorName)))
                }
            }
            .preferredWidth(min: 150)
            .customizationID("Payee")
            .disabledCustomizationBehavior(.visibility)
            
            TableColumn("Category") { transaction in
                Text(transaction.categoryName)
            }
            .preferredWidth(min: 150)
            .customizationID("Category")
            .disabledCustomizationBehavior(.visibility)
            
            TableColumn("Asset") { transaction in
                Text(transaction.assetName)
            }
            .preferredWidth(min: 150)
            .customizationID("Asset")
            .disabledCustomizationBehavior(.visibility)
    
            TableColumn("Amount", sortUsing: Transaction.sortDescriptor(.amount)) { transaction in
                AmountText(transaction.amount, currencyCode: transaction.currencyCode)
                    .foregroundStyle(transaction.amount > 0.0 ? .green : .primary)
            }
            .preferredWidth(min: 150)
            .customizationID("Amount")
            .alignment(.numeric)
            .disabledCustomizationBehavior(.visibility)
            
            TableColumn("Date", sortUsing: Transaction.sortDescriptor(.date)) { transaction in
               Text(transaction.date.formatted(date: .numeric, time: .omitted))
            }
            .preferredWidth(min: 150)
            .customizationID("Date")
            .defaultVisibility(.hidden)
            .disabledCustomizationBehavior(.visibility)
        } rows: {
            switch groupBy {
            case .none:
                ForEach(transactions)
            default:
                ForEach(data.elements, id: \.key) { value, transactions in
                    Section {
                        ForEach(transactions)
                    } header: {
                        header(with: value, for: transactions)
                    }
                }
            }
        }
        #if os(iOS)
        .tableStyle(.inset)
        #else
        .tableStyle(.inset(alternatesRowBackgrounds: true))
        #endif
        .imageScale(.small)
    }
    
    @ViewBuilder
    private func header(with value: String, for transactions: [Transaction]) -> some View {
        if showDailyTotal {
            HStack {
                Text(value)
                Spacer()
                let sum = transactions.sum(in: currency)
                AmountText(sum, currencyCode: currency.identifier)
                    .font(.body)
                    .foregroundStyle(sum.sign == .minus ? Color.secondary : Color.green)
            }
        } else {
            Text(value)
        }
    }
    
    init(
        _ transactions: [Transaction],
        selection: Binding<Set<Transaction.ID>>? = nil,
        sortBy: Binding<[SortDescriptor<Transaction>]>,
        groupBy: Transaction.GroupBy = .defaultValue,
        viewStyle: ViewStyle = .list,
        @ViewBuilder row: @escaping (Transaction) -> Row,
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.transactions = transactions
        self.selection = selection
        self._sortBy = sortBy
        self.groupBy = groupBy
        self.viewStyle = viewStyle
        self.header = header
        self.row = row
    }
}

extension TransactionList {
    init(
        _ transactions: [Transaction],
        selection: Binding<Set<Transaction.ID>>? = nil,
        sortBy: Binding<[SortDescriptor<Transaction>]>,
        groupBy: Transaction.GroupBy = .defaultValue,
        viewStyle: ViewStyle = .list,
        @ViewBuilder row: @escaping (Transaction) -> Row
    ) where Header == EmptyView {
        self.init(
            transactions,
            selection: selection,
            sortBy: sortBy,
            groupBy: groupBy,
            viewStyle: viewStyle,
            row: row
        ) {
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        TransactionListView(
            query: TransactionQuery()
        )
    }
    .modelContainer(previewContainer)
}
