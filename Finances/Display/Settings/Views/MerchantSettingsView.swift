//
//  MerchantSettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.09.2023.
//

import SwiftUI
import SwiftData

struct MerchantEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var merchant: Merchant
    
    @State private var name: String = .empty
    
    var body: some View {
        VStack {
            List {
                TextField("Name", text: $name)
                    .onSubmit {
                        if !name.isEmpty {
                            merchant.name = name
                        }
                        dismiss()
                    }
            }
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            #endif
        }
        .navigationTitle("Rename")
        .onChange(of: merchant.name, initial: true) {
            self.name = merchant.name
        }
    }
}

struct MerchantSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Merchant.name)
    var merchants: [Merchant]
    
    @State private var searchText: String = .empty
    
    var body: some View {
        VStack {
            if !merchants.isEmpty {
                List {
                    Section(searchText.isEmpty ? "All Payees" : "Results") {
                        ForEach(merchants.filter { merchant in
                            searchText.isEmpty ? true : merchant.name.lowercased().contains(searchText.lowercased())
                        }) { merchant in
                            NavigationLink {
                                MerchantEditorView(merchant: merchant)
                            } label: {
                                LabeledContent(merchant.name, value: (merchant.transactions ?? []).count.formatted())
                            }
                        }
                    }
                }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #endif
            } else {
                MerchantsUnavailableView()
            }
        }
        .searchable(text: $searchText, placement: .automatic)
        .navigationTitle("Payees")
    }
}

#Preview {
    NavigationStack {
        MerchantSettingsView()
    }
    .modelContainer(previewContainer)
}
