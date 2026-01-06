//
//  OverviewView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 02.10.2023.
//

import SwiftUI
import SwiftData
import OrderedCollections
import AppUI

struct SearchTextKey: FocusedValueKey {
    typealias Value = String
}

extension FocusedValues {
    var searchText: String? {
        get { self[SearchTextKey.self] }
        set { self[SearchTextKey.self] = newValue }
    }
}

extension Optional where Wrapped == Binding<EditMode> {
    var isEditing: Bool {
        switch self {
        case .some(let editMode):
            return editMode.wrappedValue.isEditing
        case .none:
            return false
        }
    }
}

typealias SelectedValue = NavigationRoute

struct OverviewView: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    @Environment(\.navigator) private var navigator
    @Environment(\.editMode) private var editMode
    @Environment(\.dateInterval) private var dateInterval
    
    @State private var selection: Set<SelectedValue> = []
    @State private var searchText: String = .empty
    @State private var showSettings: Bool = false
    
    var body: some View {
        @Bindable var navigator = navigator
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            List(selection: editMode.isEditing ? $selection : $navigator.root.selection) {
                SummarySection()
                AssetListSection(selection: $selection)
                TagsSection()
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.sidebar)
            #endif
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .searchable(text: $searchText, prompt: "Search transactions")
            .focusedSceneValue(\.searchText, searchText)
            .searchSuggestions {
                if !searchText.isEmpty {
                    DynamicQueryView(
                        query: Query(TransactionQuery(
                            searchText: searchText,
                            searchDateInterval: dateInterval
                        ).fetchDescriptor)
                    ) { transactions in
                        ForEach(transactions.grouped(by: \.date.localizedDescription).elements, id: \.key) { value, transactions in
                            Section(value) {
                                ForEach(transactions) { transaction in
                                    NavigationLink(route: .transaction(id: transaction.externalIdentifier)) {
                                        TransactionItemRow(transaction)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Finances")
        .toolbarTitleDisplayMode(.automatic)
        #if os(iOS)
        .toolbar {
            if editMode.isEditing {
                ToolbarItemGroup(placement: .primaryAction) {
                    EditButton()
                }
            } else {
                ToolbarItemGroup(placement: .primaryAction) {
                    if userInterfaceIdiom == .phone {
                        CurrencyConversionButton()
                    }
                    
                    Menu("Menu", systemImage: "ellipsis.circle") {
                        Button("Edit Assets", systemImage: "pencil") {
                            withAnimation {
                                editMode?.wrappedValue = .active
                            }
                        }
                        
                        Button {
                            showSettings.toggle()
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            }
        }
        #endif
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView(isPresented: $showSettings)
            }
            .interactiveDismissDisabled()
        }
        .connectionStatus()
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
