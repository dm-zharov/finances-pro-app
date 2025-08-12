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
    static let zero = EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
    static let compact = EdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0)
}

struct SummaryView: View {
    @Environment(\.currency) private var currency
    @Environment(\.dateInterval) private var dateInterval
    
    @State private var data: [AmountEntry<String>] = [] {
        didSet {
            isLoading = false
        }
    }
    var visibleData: [AmountEntry<String>] {
        let visibleCategories = visibleCategories
        return data.filter { element in
            if element.isUncategorized {
                return showIncome == (element.amount > .zero)
            } else {
                return visibleCategories.contains(where: { category in category.name == element.name })
            }
        }.sorted(by: \.amount, order: .forward)
    }

    @Query private var categories: [Category]
    var visibleCategories: [Category] {
        return (try? categories.filter(
            Category.predicate(isIncome: showIncome, includeTransient: showTransient))
        ) ?? []
    }
    
    @Query private var categoryGroups: [CategoryGroup]

    @State private var showIncome: Bool = false
    @State private var showTransient: Bool = false

    #if os(iOS)
    @State private var selection: NavigationRoute?
    #endif
    @State private var isLoading: Bool = true
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            #if os(iOS)
                list
            #else
                form
            #endif
        }
        .navigationTitle("Summary")
        .toolbar {
            ToolbarItemGroup(placement: .toolbar) {
                _ToolbarSpacer()
                if categories.contains(where: { $0.isTransient == true }) {
                    Menu {
                        if showTransient {
                            Button("Hide Excluded", systemImage: "eye.slash") {
                                showTransient = false
                            }
                        } else {
                            Button("Show Excluded", systemImage: "eye") {
                                showTransient = true
                            }
                        }
                    } label: {
                        Label {
                            Text("Filter")
                        } icon: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .symbolVariant(showTransient ? .fill : .none)
                        }
                    }
                }
            }
        }
        .task(id: dateInterval, priority: .high) {
            self.data = await fetch(
                with: Request(currency: currency, dateInterval: dateInterval)
            )
        }
    }
    
    #if os(iOS)
    @MainActor
    var list: some View {
        List {
            selector
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6.0, leading: 0, bottom: 6.0, trailing: 0))
            
            Section("Chart") {
                chart
            }
            
            breakdown
                .listRowInsets(.init(top: .zero, leading: 16, bottom: .zero, trailing: 16))
            shimmers
                .listRowInsets(.init(top: .zero, leading: 16, bottom: .zero, trailing: 16))
            
            #if BUDGETS
            if !showIncome {
                limits
                    .listRowInsets(.init(top: .zero, leading: 16, bottom: .zero, trailing: 16))
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
    
    var selector: some View {
        Picker(selection: $showIncome) {
            Text("Spending")
                .tag(false)
            Text("Incomes")
                .tag(true)
        } label: {
            Text("Kind")
        }
        .pickerStyle(.segmented)
        #if os(iOS)
        .frame(height: 32.0)
        #endif
    }
    
    var chart: some View {
        if !data.isEmpty {
            CategoryBreakdownChart(
                data: visibleData,
                colors: Dictionary(grouping: categories) { category in
                    category.name
                }.mapValues { categories in
                    Color(colorName: ColorName(rawValue: categories.first?.colorName))
                }
            )
        } else {
            CategoryBreakdownChart(
                data: .loading,
                colors: [:]
            )
        }
    }
    
    @ViewBuilder
    var breakdown: some View {
        if isLoading {
            Section {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                }
            }
        } else if let visibleData = .some(visibleData), !visibleData.isEmpty {
            SummaryBreakdownContent(data: visibleData)
        } else {
            Text("No transactions for the selected period.")
                .foregroundStyle(.secondary)
        }
    }
    
    #if BUDGETS
    var limits: some View {
        SummaryBudgetListContent()
    }
    #endif

    @ViewBuilder
    var shimmers: some View {
        // Prevents toolbar flickering on push transition.
        if data.isEmpty, let visibleCategories = .some(visibleCategories), visibleCategories.count > 1 {
            Section {
                ForEach(1..<visibleCategories.count, id: \.self) { number in
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
}

private extension SummaryView {
    struct Request {
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

#Preview {
    NavigationStack {
        SummaryView()
    }
    .modelContainer(previewContainer)
}

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
