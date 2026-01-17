//
//  SummaryMerchantDetailsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.04.2024.
//

import SwiftUI
import AppUI
import CurrencyKit

@MainActor
struct SummaryMerchantDetailsView: View {
    @Environment(\.dateInterval) var dateInterval
    @Environment(\.calendar) var calendar
    @Environment(\.currency) var currency
    
    let payee: Merchant
    
    @State private var data: [AmountEntry<Date>] = []
    @State private var selection: NavigationRoute?
    
    var body: some View {
        VStack {
            List {
                Section("Chart") {
                    DateSpendingChart(data: data) {
                        VStack(alignment: .leading) {
                            Text(dateInterval.localizedDescription)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            AmountText(
                                data.map(\.amount).sum().magnitude,
                                currencyCode: currency.identifier
                            )
                            .font(.title)
                            .fontWeight(.semibold)
                        }
                    }
                }
                
                SummaryCategoryListContent(
                    query: CategoryQuery(
                        searchMerchantID: payee.externalIdentifier,
                        searchDateInterval: dateInterval
                    )
                )
                
                NavigationLink(route: .transactions(
                    query: TransactionQuery(
                        groupBy: .category,
                        searchMerchantID: payee.externalIdentifier
                    )
                )) {
                    Label {
                        Text("Show Transactions")
                    } icon: {
                        Image(systemName: "calendar.day.timeline.leading")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.accent, .secondary)
                    }
                }
                #if os(iOS)
                .listSectionSpacing(.compact)
                #endif
            }
            .task(id: payee.id, priority: .high) {
                self.data = await fetch(
                    with: Request(
                        currency: currency,
                        granularity: granularity,
                        dateInterval: dateInterval,
                        merchantID: payee.externalIdentifier
                    )
                )
            }
        }
        .navigationTitle(payee.name)
    }
    
    init(_ payee: Merchant) {
        self.payee = payee
    }
}

extension SummaryMerchantDetailsView: SummaryDetailsView {
    struct Request {
        let currency: Currency
        let granularity: Calendar.Component
        let dateInterval: DateInterval
        let merchantID: Merchant.ExternalID
    }
    
    typealias Response = [AmountEntry<Date>]

    nonisolated func fetch(with request: Request) async -> Response {
        let predicate = TransactionQuery.predicate(
            searchDateInterval: request.dateInterval,
            searchMerchantID: request.merchantID
        )
        
        do {
            return try await ArithmeticActor.shared.sum(
                predicate: predicate,
                granularity: request.granularity,
                in: request.currency
            )
        } catch {
            assertionFailure(error.localizedDescription)
            return []
        }
    }
}
