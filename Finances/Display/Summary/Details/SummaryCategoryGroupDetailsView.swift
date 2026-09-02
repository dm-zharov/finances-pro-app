//
//  SummaryCategoryDetailsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.04.2024.
//

import SwiftUI
import SwiftData
import AppUI
import CurrencyKit

@MainActor
struct SummaryCategoryGroupDetailsView: View {
    private struct ID: Equatable {
        let categoryGroupID: CategoryGroup.ExternalID
        let currency: Currency
        let granularity: Calendar.Component
        let dateInterval: DateInterval
    }

    @Environment(\.dateInterval) var dateInterval
    @Environment(\.calendar) var calendar
    @Environment(\.currency) var currency
    
    let categoryGroup: CategoryGroup
    
    @State private var data: [AmountEntry<Date>] = []
    
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

                    if granularity == .day {
                        switch calendar.granularity(for: dateInterval) {
                        case .month:
                            LabeledContent(
                                "Daily Average",
                                value: (data.map(\.amount).sum() / Decimal(calendar.range(of: .day, in: .month, for: dateInterval.start)!.count) ).formatted(.currency(currency))
                            )
                        case .weekOfYear:
                            LabeledContent(
                                "Daily Average",
                                value: (data.map(\.amount).sum() / Decimal(7) ).formatted(.currency(currency))
                            )
                        default:
                            EmptyView()
                        }
                    }
                }
                
                SummaryCategoryListContent(
                    query: CategoryQuery(
                        searchGroupID: categoryGroup.externalIdentifier,
                        searchDateInterval: dateInterval
                    )
                )
            }
            .task(
                id: ID(
                    categoryGroupID: categoryGroup.externalIdentifier,
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
        .navigationTitle(categoryGroup.name)
    }
    
    init(_ categoryGroup: CategoryGroup) {
        self.categoryGroup = categoryGroup
    }

    private func loadData() async {
        self.data = await fetch(
            with: Request(
                currency: currency,
                granularity: granularity,
                dateInterval: dateInterval,
                categoryGroupID: categoryGroup.externalIdentifier
            )
        )
    }

    private func observeModelChanges() async {
        for await _ in NotificationCenter.default.notifications(named: ModelContext.didChange) {
            await loadData()
        }
    }
}

extension SummaryCategoryGroupDetailsView: SummaryDetailsView {
    struct Request: Sendable {
        let currency: Currency
        let granularity: Calendar.Component
        let dateInterval: DateInterval
        let categoryGroupID: CategoryGroup.ExternalID
    }
    
    typealias Response = [AmountEntry<Date>]

    nonisolated func fetch(with request: Request) async -> Response {
        let predicate = TransactionQuery.predicate(
            searchDateInterval: request.dateInterval,
            searchCategoryGroupID: request.categoryGroupID
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
