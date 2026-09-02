//
//  SummaryMerchantDetailsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.04.2024.
//

import SwiftUI
import SwiftData
import AppUI
import CurrencyKit

@MainActor
struct SummaryMerchantDetailsView: View {
    private struct ID: Equatable {
        let merchantID: Merchant.ExternalID
        let currency: Currency
        let granularity: Calendar.Component
        let dateInterval: DateInterval
    }

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
            .task(
                id: ID(
                    merchantID: payee.externalIdentifier,
                    currency: currency,
                    granularity: granularity,
                    dateInterval: dateInterval
                ),
                priority: .high
            ) {
                await loadData()
            }
            .task(priority: .high) {
                await observeModelChanges()
            }
        }
        .navigationTitle(payee.name)
    }
    
    init(_ payee: Merchant) {
        self.payee = payee
    }

    private func loadData() async {
        self.data = await fetch(
            with: Request(
                currency: currency,
                granularity: granularity,
                dateInterval: dateInterval,
                merchantID: payee.externalIdentifier
            )
        )
    }

    private func observeModelChanges() async {
        for await _ in NotificationCenter.default.notifications(named: ModelContext.didChange) {
            await loadData()
        }
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
