//
//  SummaryBudgetListContent.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.03.2024.
//

import SwiftUI
import SwiftData
import CurrencyKit

#if BUDGETS

struct BudgetItemRow: View {
    @Environment(\.currency) private var currency
    
    let budget: Budget
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        SummaryItemRow(
            CategoryAmount(category: budget.displayName, amount: budget.amount(in: currency) / 2.0),
            total: budget.amount(in: currency),
            symbolName: .defaultValue,
            color: .accentColor
        )
    }
    
    init(_ budget: Budget) {
        self.budget = budget
    }
}

struct SummaryBudgetListContent: View {
    @Environment(\.currency) private var currency
    
    @Query(sort: \Budget.creationDate, order: .forward) private var budgets: [Budget]
    
    @State private var showBudgetEditor: Bool = false
    
    var body: some View {
        Section("Budgets") {
            ForEach(budgets) { budget in
                NavigationLink(route: .budget(id: budget.externalIdentifier)) {
                    BudgetItemRow(budget)
                }
            }

            Button("Add Budget") {
                showBudgetEditor.toggle()
            }
            .sheet(isPresented: $showBudgetEditor) {
                NavigationStack {
                    BudgetEditorView()
                }
            }
        }
    }
}
#endif
