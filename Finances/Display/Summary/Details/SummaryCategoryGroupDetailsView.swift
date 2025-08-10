//
//  SummaryCategoryDetailsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 09.04.2024.
//

import SwiftUI
import AppUI
import CurrencyKit

@MainActor
struct SummaryCategoryGroupDetailsView: View {
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
                                value: (data.map(\.amount).sum() / Decimal(calendar.range(of: .day, in: .month, for: dateInterval.start)!.upperBound) ).formatted(.currency(currency))
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
            .task(id: categoryGroup.id, priority: .high) {
                self.data = await fetch(
                    with: Request(
                        currency: currency,
                        granularity: granularity,
                        dateInterval: dateInterval,
                        categoryIDs: (categoryGroup.categories ?? []).map(\.externalIdentifier)
                    )
                )
            }
        }
        .navigationTitle(categoryGroup.name)
    }
    
    init(_ categoryGroup: CategoryGroup) {
        self.categoryGroup = categoryGroup
    }
}

extension SummaryCategoryGroupDetailsView: SummaryDetailsView {
    struct Request: Sendable {
        let currency: Currency
        let granularity: Calendar.Component
        let dateInterval: DateInterval
        let categoryIDs: [Category.ExternalID]
    }
    
    typealias Response = [AmountEntry<Date>]

    nonisolated func fetch(with request: Request) async -> Response {
        do {
            let data = try await withThrowingTaskGroup(of: [AmountEntry<Date>].self) { taskGroup in
                for categoryID in request.categoryIDs {
                    let predicate = TransactionQuery.predicate(
                        searchDateInterval: request.dateInterval,
                        searchCategoryID: categoryID
                    )
                    taskGroup.addTask {
                        try await ArithmeticActor.shared.sum(
                            predicate: predicate,
                            granularity: request.granularity,
                            in: currency
                        )
                    }
                }
                
                var result: [AmountEntry<Date>] = []
                for try await data in taskGroup {
                    result.append(contentsOf: data)
                }
                return result
            }
            
            return data
        } catch {
            assertionFailure(error.localizedDescription)
            return []
        }
    }
}
