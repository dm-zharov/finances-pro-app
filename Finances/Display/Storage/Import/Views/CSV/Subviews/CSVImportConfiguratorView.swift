//
//  CSVImportConfiguratorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.11.2023.
//

import SwiftUI
import SwiftCSV
import SwiftData
import OrderedCollections
import TipKit

struct CSVImportConfiguratorView: View {
    let csv: CSV<Named>
    let onCompletion: () -> Void
    
    @State private var strategy = CSVParseStrategy()
    
    @State private var currentColumn: Int = 0
    private var numberOfColumns: Int {
        csv.header.count
    }
    
    @State private var showLimit: Int = 5
    @State private var showPreview: Bool = false
    
    func selection(for field: Statement.Field) -> Binding<String?> {
        Binding<String?>(
            get: {
                strategy.header(for: field)
            },
            set: { newValue, transaction in
                if let newValue {
                    strategy.mapping[newValue] = field
                } else {
                    if let currentValue = strategy.header(for: field) {
                        strategy.mapping.removeValue(forKey: currentValue)
                    }
                }
            }
        )
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            TabView(selection: $currentColumn) {
                ForEach(csv.header.indices, id: \.self) { index in
                    list(for: csv.header[index])
                        .tag(index)
                        .tabItem {
                            Text(index.formatted())
                        }
                }
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Color.ui(.systemGroupedBackground))
            #endif
        }
        .interactiveDismissDisabled()
        .navigationTitle("Import from a CSV")
        .sheet(isPresented: $showPreview) {
            NavigationStack {
                ImportResultView((try? strategy.parse(csv)) ?? Statement()) {
                   onCompletion()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Preview") {
                    showPreview.toggle()
                }
                .disabled(!strategy.mapping.values.contains(.amount))
            }
            
            #if os(iOS)
            ToolbarItem(placement: .status) {
                PageControl(currentPage: $currentColumn, numberOfPages: numberOfColumns)
            }
            #endif
            
            #if os(iOS)
            ToolbarItemGroup(placement: .bottomBar) {
                _ToolbarSpacer()
            }
            #endif
        }
        .onChange(of: currentColumn) {
            showLimit = 5
        }
        .preferredContentSize(minWidth: 600, minHeight: 750)
    }
    
    func list(for header: String) -> some View {
        Form {
            TipItem(CSVImportTip())
                .listRowSeparator(.hidden)

            Section {
                LabeledContent {
                    Text(header)
                        .foregroundStyle(.secondary)
                } label: {
                    Text("Column")
                }
            }
            #if os(iOS)
            .listSectionSpacing(.compact)
            #endif
            
            if let column = csv.columns?[header], let rows = .some(OrderedSet(column.filter({ !$0.isEmpty }))), !rows.isEmpty {
                Section {
                    ForEach(rows.prefix(showLimit), id: \.self) { row in
                        if let field = strategy.mapping[header], let transform = strategy.transform[field] {
                            CSVImportConfiguratorRow(row, transform: transform)
                        } else {
                            CSVImportConfiguratorRow(row)
                        }
                    }
                    if Set(rows).count > showLimit {
                        Button("Show More") {
                            withAnimation {
                                showLimit += 5
                            }
                        }
                    }
                } header: {
                    EmptyView()
                } footer: {
                    Text("These entries are provided for the convenience of choosing an import action for the column.")
                        .textStyle(.footer)
                }
                
                Section("Action") {
                    Picker(selection: $strategy.mapping[header]) {
                        Section {
                            Text("None")
                                .tag(Optional<Statement.Field>.none)
                        }
                        ForEach(Statement.Field.grouped, id: \.self) { group in
                            if let items = .some(group.items.filter { field in
                                Set(strategy.mapping.values).contains(field) == false || strategy.mapping[header] == field
                            }), !items.isEmpty {
                                Section {
                                    ForEach(items, id: \.self) { field in
                                        Label {
                                            Text(String(localized: field.localizedStringResource))
                                        } icon: {
                                            Image(systemName: field.symbolName.rawValue)
                                        }
                                        .tag(Optional<Statement.Field>.some(field))
                                    }
                                } header: {
                                    if let header = group.header {
                                        Text(header)
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("Import as")
                    }
                    .tint(.accent)
                }
                
                switch strategy.mapping[header] {
                case .date:
                    CSVDateImportOptions(data: rows, strategy: $strategy)
                case .category:
                    CSVCategoryImportOptions(data: rows, strategy: $strategy)
                case .account:
                    CSVAccountImportOptions(data: rows, strategy: $strategy)
                case .amount:
                    CSVAmountImportOptions(data: rows, strategy: $strategy)
                case .currency:
                    CSVCurrencyImportOptions(data: rows, strategy: $strategy)
                case .sign:
                    CSVSignImportOptions(data: rows, strategy: $strategy)
                case .payee, .notes, .tags, .id:
                    CSVGenericImportOptions(field: strategy.mapping[header]!, strategy: $strategy)
                case nil:
                    EmptyView()
                }
            } else {
                Text("No Data")
                    .foregroundStyle(.placeholder)
            }
        }
        .formStyle(.grouped)
        .headerProminence(.increased)
        #if os(iOS)
        .contentMargins(.top, .compact, for: .scrollContent)
        #endif
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
}
