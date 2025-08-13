//
//  CurrencySelectorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 05.11.2023.
//

import SwiftUI
import SwiftData
import CurrencyKit
import FoundationExtension

struct CurrencyItemRow: View {
    let currency: Currency
    
    var body: some View {
        LabeledContent {
            Text(currency.identifier)
                .textCase(.uppercase)
        } label: {
            Text(currency.localizedDescription)
        }
    }
    
    init(_ currency: Currency) {
        self.currency = currency
    }
}

struct CurrencySelectorRow: View {
    @Binding var selection: Currency
    let suggestions: [Currency]
    
    var body: some View {
        #if os(iOS)
        NavigationLink {
            CurrencySelectorView(selection: $selection, suggestions: suggestions)
        } label: {
            LabeledContent {
                Text(selection.localizedDescription)
            } label: {
                Text("Currency")
            }
        }
        #else
        LabeledContent {
            CurrencySelectorItem(selection: $selection)
        } label: {
            Text("Currency")
        }
        #endif
    }
}

struct CurrencySelectorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selection: Currency
    let suggestions: [Currency]
    
    @State private var searchText: String = .empty
    private var searchPredicate: Predicate<Currency> {
        return #Predicate<Currency> { currency in
            if searchText.isEmpty {
                return true
            } else {
                return currency.rawValue.localizedStandardContains(searchText)
                    || currency.localizedDescription.localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack {
            List {
                if !suggestions.isEmpty, searchText.isEmpty {
                    Picker("Suggestions", selection: $selection) {
                        ForEach((try? suggestions.filter(searchPredicate)) ?? [], id: \.self) { currencyCode in
                            CurrencyItemRow(currencyCode)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                Picker(searchText.isEmpty ? "All Currencies" : "Results", selection: $selection) {
                    ForEach((try? Currency.supportedCurrencies.filter(searchPredicate).sorted(by: \.localizedDescription)) ?? [], id: \.self) { currency in
                        CurrencyItemRow(currency)
                    }
                }
                .pickerStyle(.inline)
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
            .searchable(text: $searchText)
        }
        .navigationTitle("Choose Currency")
        .toolbarTitleDisplayMode(.inline)
        .onChange(of: selection) {
            dismiss()
        }
    }
    
    private func row(for currency: Currency) -> some View {
        LabeledContent {
            Text(currency.rawValue)
                .textCase(.uppercase)
        } label: {
            Text(currency.localizedDescription)
        }
    }
    
    init(selection: Binding<Currency>, suggestions: [Currency] = []) {
        self._selection = selection
        self.suggestions = suggestions
    }
}

struct CurrencySelectorItem: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selection: Currency

    @State private var showCurrencyPicker: Bool = false

    private var currencyCodesInUse: [Currency] {
        Currency.suggestedEntities(modelContext: modelContext)
    }
    
    @ViewBuilder
    var body: some View {
        Menu {
            Picker("Suggestions", selection: $selection) {
                ForEach(currencyCodesInUse, id: \.self) { currencyCode in
                    CurrencyItemRow(currencyCode)
                }
            }
            .pickerStyle(.inline)
            
            Divider()
            
            Button("Show More", systemImage: "ellipsis.circle") {
                showCurrencyPicker.toggle()
            }
        } label: {
            Text(selection.rawValue.uppercased())
        }
        .picker(isPresented: $showCurrencyPicker) {
            NavigationStack {
                CurrencySelectorView(selection: $selection)
                    .headerProminence(.standard)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            CancelButton {
                                showCurrencyPicker.toggle()
                            }
                        }
                    }
            }
            .tint(.accentColor)
            .frame(idealWidth: 375.0, idealHeight: 667.0)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#Preview {
    NavigationStack {
        CurrencySelectorView(selection: .constant(.current), suggestions: [])
    }
    .modelContainer(previewContainer)
}
