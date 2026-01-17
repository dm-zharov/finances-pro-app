//
//  SummaryCategoryDetailsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.11.2023.
//

import SwiftUI
import AppUI
import CurrencyKit
import FoundationExtension

@MainActor
struct SummaryCategoryDetailsView: View {
    @Environment(\.dateInterval) var dateInterval
    @Environment(\.calendar) var calendar
    @Environment(\.currency) var currency
    
    let category: Category
    
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
                    .accent(Color(colorName: ColorName(rawValue: category.colorName)))
                    
                    if granularity == .day {
                        switch calendar.granularity(for: dateInterval) {
                        case .month:
                            LabeledContent {
                                AmountText(
                                    data.map(\.amount).sum() / Decimal(calendar.range(of: .day, in: .month, for: dateInterval.start)!.upperBound),
                                    currencyCode: currency.identifier
                                )
                            } label: {
                                Text("Daily Average")
                            }
                        case .weekOfYear:
                            LabeledContent {
                                AmountText(
                                    data.map(\.amount).sum() / Decimal(7),
                                    currencyCode: currency.identifier
                                )
                            } label: {
                                Text("Daily Average")
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
                
                #if BUDGETS
                if let budgets = category.budgets, !budgets.isEmpty {
                    Section("Budgets") {
                        ForEach(budgets) { budget in
                            NavigationLink(route: .budget(id: budget.externalIdentifier)) {
                                BudgetItemRow(budget)
                            }
                        }
                    }
                    .listRowInsets(.init(top: .zero, leading: 16, bottom: .zero, trailing: 16))
                }
                #endif
                
                SummaryMerchantListContent(
                    query: MerchantQuery(
                        searchCategoryID: category.externalIdentifier,
                        searchDateInterval: dateInterval
                    )
                )
                
                NavigationLink(route: .transactions(
                    query: TransactionQuery(
                        groupBy: .payee,
                        searchCategoryID: category.externalIdentifier
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
            .task(id: category.id, priority: .high) {
                self.data = await fetch(
                    with: Request(
                        currency: currency,
                        granularity: granularity,
                        dateInterval: dateInterval,
                        categoryID: category.externalIdentifier
                    )
                )
            }
        }
        .navigationTitle(category.name)
    }
    
    init(_ category: Category) {
        self.category = category
    }
}

extension SummaryCategoryDetailsView: SummaryDetailsView {
    struct Request {
        let currency: Currency
        let granularity: Calendar.Component
        let dateInterval: DateInterval
        let categoryID: Category.ExternalID
    }
    
    typealias Response = [AmountEntry<Date>]

    nonisolated func fetch(with request: Request) async -> Response {
        let predicate = TransactionQuery.predicate(
            searchDateInterval: request.dateInterval,
            searchCategoryID: request.categoryID
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
