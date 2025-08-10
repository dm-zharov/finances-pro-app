//
//  SummaryPreview.swift
//  Finances
//
//  Created by Dmitriy Zharov on 02.10.2023.
//

import SwiftUI
import SwiftData
import CurrencyKit

struct SummaryPreview: View {
    private struct ID: Equatable {
        var dateInterval: DateInterval
        var currency: Currency
    }
    
    @Environment(\.editMode) private var editMode
    @Environment(\.calendar) private var calendar
    @Environment(\.currency) private var currency
    @Environment(\.dateInterval) private var dateInterval
    
    @State private var data: [DateAmount] = []
    @State private var visibleDateInterval: DateInterval = .defaultValue

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        DateSpendingChart(data: data) {
            VStack(alignment: .leading) {
                Text("Total Spending")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                AmountText(data.map(\.amount).sum().magnitude, currencyCode: currency.identifier)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(editMode.isEditing ? .secondary : .primary)
            }
        }
        .environment(\.dateInterval, visibleDateInterval)
        .task(
            id: ID(dateInterval: dateInterval, currency: currency),
            priority: .high
        ) {
            let response = await fetch(
                with: Request(
                    currency: currency,
                    granularity: {
                        if let granularity = calendar.granularity(for: dateInterval) {
                            return granularity == .year ? .month : .day
                        } else {
                            return .year
                        }
                    }(),
                    dateInterval: dateInterval
                )
            )
            self.data = response.data
            self.visibleDateInterval = response.visibleDateInterval
        }
    }
}

extension SummaryPreview {
    struct Request: Sendable {
        let currency: Currency
        let granularity: Calendar.Component
        let dateInterval: DateInterval
    }
    
    struct Response: Sendable {
        let data: [DateAmount]
        let visibleDateInterval: DateInterval
    }

    nonisolated func fetch(with request: Request) async -> Response {
        let predicate = TransactionQuery.predicate(
            dateInterval: request.dateInterval,
            isIncome: false
        )
        
        do {
            return try await Response(
                data: ArithmeticActor.shared.sum(
                    predicate: predicate,
                    granularity: request.granularity,
                    in: request.currency
                ),
                visibleDateInterval: dateInterval
            )
        } catch {
            assertionFailure(error.localizedDescription)
            return await Response(data: [], visibleDateInterval: dateInterval)
        }
    }
}

#Preview {
    List {
        SummaryPreview()
    }
}
