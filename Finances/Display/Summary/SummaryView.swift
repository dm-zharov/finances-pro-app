//
//  SummaryView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 26.09.2023.
//

import SwiftUI
import SwiftData
import AppUI
import FoundationExtension
import CurrencyKit

extension EdgeInsets {
    static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    static let compact = EdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0)
}

struct SummaryView: View {
    // MARK: - Environment
    @Environment(\.currency) private var currency
    @Environment(\.dateInterval) private var dateInterval
    
    // MARK: - Queries
    @Query private var categories: [Category]
    @Query private var categoryGroups: [CategoryGroup]
    
    // MARK: - State
    @State private var data: [AmountEntry<String>] = []
    @State private var showIncome: Bool = false
    @State private var showTransient: Bool = false
    @State private var isLoading: Bool = true
    
    #if os(iOS)
    @State private var selection: NavigationRoute?
    #endif
    
    // MARK: - Computed Properties
    private var visibleCategories: [Category] {
        (try? categories.filter(
            Category.predicate(isIncome: showIncome, includeTransient: showTransient)
        )) ?? []
    }
    
    private var visibleData: [AmountEntry<String>] {
        data.filter { element in
            if element.isUncategorized {
                return showIncome == (element.amount > .zero)
            } else {
                return visibleCategories.contains(where: { $0.name == element.name })
            }
        }.sorted(by: \.amount, order: .forward)
    }
    
    private var hasTransientCategories: Bool {
        categories.contains(where: { $0.isTransient == true })
    }
    
    // MARK: - Body
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        Group {
            #if os(iOS)
            list
            #else
            form
            #endif
        }
        .navigationTitle("Summary")
        .toolbar {
            ToolbarSpacer(.flexible, placement: .toolbar)
            ToolbarItem(placement: .toolbar) {
                filterButton
            }
        }
        .task(id: dateInterval, priority: .high) {
            await loadData()
        }
    }
    
    // MARK: - Private Methods
    private func loadData() async {
        isLoading = true
        data = await fetch(with: Request(currency: currency, dateInterval: dateInterval))
        isLoading = false
    }
}

// MARK: - Platform-Specific Views
private extension SummaryView {
    #if os(iOS)
    @MainActor
    var list: some View {
        List {
            selectorSection
            chartSection
            breakdownSection
            shimmerSection
            
            #if BUDGETS
            if !showIncome {
                budgetSection
            }
            #endif
        }
        .listStyle(.insetGrouped)
    }
    #endif
    
    #if os(macOS)
    @MainActor
    var form: some View {
        Form {
            Section {
                selector
                chart
            }
            
            List {
                breakdown
            }
            .alternatingRowBackgrounds(.enabled)
        }
        .formStyle(.grouped)
    }
    #endif
}

// MARK: - View Components
private extension SummaryView {
    var selectorSection: some View {
        selector
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 6.0, leading: 0, bottom: 6.0, trailing: 0))
    }
    
    var chartSection: some View {
        Section("Chart") {
            chart
        }
    }
    
    var breakdownSection: some View {
        breakdown
            .listRowInsets(.init(top: .zero, leading: 16, bottom: .zero, trailing: 16))
    }
    
    var shimmerSection: some View {
        shimmers
            .listRowInsets(.init(top: .zero, leading: 16, bottom: .zero, trailing: 16))
    }
    
    #if BUDGETS
    var budgetSection: some View {
        limits
            .listRowInsets(.init(top: .zero, leading: 16, bottom: .zero, trailing: 16))
    }
    #endif
    
    var filterButton: some View {
        Group {
            if hasTransientCategories {
                Menu {
                    Button(
                        showTransient ? "Hide Excluded" : "Show Excluded",
                        systemImage: showTransient ? "eye.slash" : "eye"
                    ) {
                        showTransient.toggle()
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .symbolVariant(showTransient ? .fill : .none)
                }
            }
        }
    }
    
    var selector: some View {
        Picker(selection: $showIncome) {
            Text("Spending").tag(false)
            Text("Incomes").tag(true)
        } label: {
            Text("Kind")
        }
        .pickerStyle(.segmented)
        #if os(iOS)
        .frame(height: 32.0)
        #endif
    }
    
    var chart: some View {
        CategoryBreakdownChart(
            data: data.isEmpty ? .loading : visibleData,
            colors: categoryColorMap
        )
    }
    
    private var categoryColorMap: [String: Color] {
        Dictionary(grouping: categories, by: { $0.name })
            .mapValues { categories in
                Color(colorName: ColorName(rawValue: categories.first?.colorName))
            }
    }
    
    @ViewBuilder
    var breakdown: some View {
        if isLoading {
            loadingView
        } else if !visibleData.isEmpty {
            SummaryBreakdownContent(data: visibleData)
        } else {
            emptyStateView
        }
    }
    
    private var loadingView: some View {
        Section {
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                Spacer()
            }
        }
    }
    
    private var emptyStateView: some View {
        Text("No transactions for the selected period.")
            .foregroundStyle(.secondary)
    }
    
    #if BUDGETS
    var limits: some View {
        SummaryBudgetListContent()
    }
    #endif

    @ViewBuilder
    var shimmers: some View {
        if shouldShowShimmers {
            Section {
                ForEach(1..<visibleCategories.count, id: \.self) { _ in
                    VStack { }
                        .frame(height: 54.0)
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            #if os(iOS)
            .listSectionSpacing(.zero)
            #endif
        }
    }
    
    private var shouldShowShimmers: Bool {
        data.isEmpty && visibleCategories.count > 1
    }
}

// MARK: - Data Fetching
private extension SummaryView {
    struct Request: Sendable {
        let currency: Currency
        let dateInterval: DateInterval
    }
    
    typealias Response = [AmountEntry<String>]

    nonisolated func fetch(with request: Request) async -> Response {
        do {
            let predicate = TransactionQuery.predicate(
                dateInterval: request.dateInterval,
                includeTransient: true
            )
            return try await ArithmeticActor.shared.sum(
                predicate: predicate,
                in: request.currency
            )
        } catch {
            assertionFailure(error.localizedDescription)
            return []
        }
    }
}

// MARK: - Extensions
extension AmountEntry<String> {
    var isUncategorized: Bool {
        name == String(localized: "Uncategorized")
    }
}

private extension Array where Element == AmountEntry<String> {
    static var loading: [AmountEntry<String>] {
        [AmountEntry<String>(id: String(localized: "Calculating..."), amount: .zero)]
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SummaryView()
    }
    .modelContainer(previewContainer)
}

