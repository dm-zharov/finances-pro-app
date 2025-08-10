//
//  SummaryCategoryListContent.swift
//  Finances
//
//  Created by Dmitriy Zharov on 16.04.2024.
//

import SwiftUI
import SwiftData
import OrderedCollections
import FoundationExtension

struct SummaryCategoryListContent: View {
    @Environment(\.currency) private var currency
    
    let _query: CategoryQuery
    @Query private var transactions: [Transaction]
    
    @State private var showLimit: Int = 7
    
    private var data: OrderedDictionary<String, Decimal> {
        transactions.grouped(by: \.categoryName).mapValues { transactions in
            transactions.sum(in: currency)
        }
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        Section("Categories") {
            ForEach(data.sorted(by: \.value).prefix(showLimit), id: \.key) { categoryName, amount in
                LabeledContent {
                    AmountText(amount, currencyCode: currency.identifier)
                } label: {
                    Text(categoryName)
                }
            }
            if data.elements.count > showLimit {
                Button("Show More") {
                    withAnimation {
                        showLimit += 7
                    }
                }
            }
        }
    }
    
    init(query: CategoryQuery) {
        self._query = query
        self._transactions = Query(
            FetchDescriptor(predicate: TransactionQuery.predicate(
                searchDateInterval: query.searchDateInterval,
                searchCategoryGroupID: query.searchGroupID,
                searchMerchantID: query.searchMerchantID
            ))
        )
    }
}
