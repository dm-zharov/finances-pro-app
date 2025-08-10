//
//  SummaryMerchantListContent.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.04.2024.
//

import SwiftUI
import SwiftData
import OrderedCollections
import FoundationExtension

struct SummaryMerchantListContent: View {
    @Environment(\.currency) private var currency
    
    let _query: MerchantQuery
    @Query private var transactions: [Transaction]
    
    @State private var showLimit: Int = 7
    
    private var data: OrderedDictionary<String, Decimal> {
        transactions.grouped(by: \.payeeName).mapValues { transactions in
            transactions.sum(in: currency)
        }
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        Section("Payees") {
            ForEach(data.sorted(by: \.value).prefix(showLimit), id: \.key) { payeeName, amount in
                NavigationLink(route: .merchant(id: payeeName)) {
                    LabeledContent {
                        AmountText(amount, currencyCode: currency.identifier)
                    } label: {
                        Text(payeeName)
                    }
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
    
    init(query: MerchantQuery) {
        self._query = query
        self._transactions = Query(
            FetchDescriptor(predicate: TransactionQuery.predicate(
                searchDateInterval: query.searchDateInterval,
                searchCategoryID: query.searchCategoryID
            ))
        )
    }
}
