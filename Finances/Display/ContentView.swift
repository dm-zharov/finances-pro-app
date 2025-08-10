//
//  ContentView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 24.12.2022.
//

import SwiftUI
import SwiftData
import OSLog
import CurrencyKit
import FoundationExtension

@MainActor
struct ContentView: View {
    // MARK: - Environment
    
    #if os(iOS)
    @Environment(\.isSceneCaptured) private var isSceneCaptured
    #endif
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // MARK: - Navigation
    
    @State private var navigator = Navigator.shared
    
    // MARK: - Default

    @AppStorage("GreetingScreenEnabled") private var showGreeting: Bool = true
    @AppStorage(SettingKey.currencyCode, store: .shared) private var currency: Currency = .current
    @AppStorage(SettingKey.isCurrencyConversionEnabled, store: .shared) private var isCurrencyConversionEnabled: Bool = false
    @AppStorage(SettingKey.obscureSensitiveContent, store: .shared) private var shouldObscureSensitiveContent: Bool = true
    
    // MARK: - State
    
    @State private var dateInterval: DateInterval = .defaultValue
    @State private var editMode: EditMode = .inactive
    @State private var showTransactionEditor: Bool = false
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        Group {
            if horizontalSizeClass == .compact {
                compact
            } else {
                regular
            }
        }
        .sheet(isPresented: $showGreeting) {
            NavigationStack {
                GreetingView()
            }
            .preferredContentSize(width: 480, height: 600)
        }
        .sheet(isPresented: $showTransactionEditor) {
            NavigationStack {
                TransactionEditorView()
            }
        }
        .onOpenURL { url in
            navigator.open(url)
        }
        .environment(navigator)
        .environment(\.dateInterval, dateInterval)
        .environment(\.currency, currency)
        .environment(\.isCurrencyConversionEnabled, isCurrencyConversionEnabled)
        .environment(\.currencyConversionMode, $isCurrencyConversionEnabled)
        #if os(iOS)
        .redacted(reason: shouldObscureSensitiveContent && isSceneCaptured ? .privacy : .invalidated)
        #endif
    }
    
    @MainActor
    var compact: some View {
        NavigationStack(path: $navigator.path) {
            OverviewView()
                .environment(\.editMode, $editMode)
                .navigationDestination(for: NavigationRoute.self) { route in
                    view(for: route)
                }
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .topBarLeading) {
                        CalendarButton(selection: $dateInterval)
                    }
                    #endif
                    
                    ToolbarItemGroup(placement: .toolbar) {
                        ToolbarSpacer()
                        TransactionButton {
                            showTransactionEditor.toggle()
                        }
                    }
                }
        }
    }
    
    @MainActor
    var regular: some View {
        NavigationSplitView(columnVisibility: $navigator.columnVisibility) {
            OverviewView()
                .environment(\.editMode, $editMode)
                .preferredNavigationSplitViewColumnWidth(min: 220.0, ideal: 250.0, max: 280.0)
        } detail: {
            NavigationStack(path: $navigator.relativePath) {
                view(for: navigator.root ?? .transactions())
                    .navigationDestination(for: NavigationRoute.self) { route in
                        view(for: route)
                    }
                    .toolbar {
                        #if os(macOS)
                        ToolbarItem(placement: .navigation) {
                            CalendarButton(selection: $dateInterval)
                        }
                        #else
                        ToolbarItem(placement: .topBarLeading) {
                            CalendarButton(selection: $dateInterval)
                        }
                        #endif
                    }
            }
            .navigationSplitViewColumnWidth(min: 350, ideal: 700)
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    var placeholderView: some View {
        Group {
            EmptyView()
        }
        .navigationTitle(String.empty)
        .toolbar {
            ToolbarItemGroup(placement: .toolbar) {
                ToolbarSpacer()
                TransactionButton { }
            }
        }
    }
}

extension ContentView {
    @ViewBuilder
    func view(for route: NavigationRoute) -> some View {
        switch route {
        case .summary:
            SummaryView()
        case let .transaction(id: transactionID):
            if let transaction = modelContext.existingModel(Transaction.self, with: transactionID) {
                TransactionDetailsView(transaction)
            }
        case let .category(id: categoryID):
            if let category = modelContext.existingModel(Category.self, with: categoryID) {
                SummaryCategoryDetailsView(category)
            }
        case let .categoryGroup(id: categoryGroupID):
            if let category = modelContext.existingModel(CategoryGroup.self, with: categoryGroupID) {
                SummaryCategoryGroupDetailsView(category)
            }
        case let .merchant(id: merchantID):
            if let merchant = modelContext.existingModel(Merchant.self, with: merchantID) {
                SummaryMerchantDetailsView(merchant)
            }
        #if BUDGETS
        case let .budget(id: budgetID):
            if let budget = modelContext.existingModel(Budget.self, with: budgetID) {
                BudgetDetailsView(budget)
            }
        #endif
        case let .transactions(query: query):
            TransactionListView(
                query: query.dateInterval(dateInterval)
            )
            .id(query.dateInterval(dateInterval))
        case let .tags(IDs):
            TagTransactionListView(tags: IDs)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}

extension View {
    public func preferredContentSize(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        #if os(iOS)
        self
        #else
        frame(minWidth: width, maxWidth: width, minHeight: height, maxHeight: height)
        #endif
    }
    
    public func preferredContentSize(minWidth: CGFloat? = nil, minHeight: CGFloat? = nil) -> some View {
        #if os(iOS)
        self
        #else
        frame(minWidth: minWidth, minHeight: minHeight)
        #endif
    }
    
    public func preferredNavigationSplitViewColumnWidth(
        min: CGFloat? = nil,
        ideal: CGFloat,
        max: CGFloat? = nil
    ) -> some View {
        #if os(iOS)
        self
        #else
        navigationSplitViewColumnWidth(min: min, ideal: ideal, max: max)
        #endif
    }
}

extension TableColumn {
    public func preferredWidth(min: CGFloat? = nil, ideal: CGFloat? = nil, max: CGFloat? = nil) -> TableColumn<RowValue, Sort, Content, Label> {
        #if os(iOS)
        self
        #else
        width(min: min, ideal: ideal, max: max)
        #endif
    }
}
