//
//  PayeeSelectorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 07.10.2023.
//

import SwiftUI
import SwiftData

struct PayeeSelectorView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Merchant.name) private var merchants: [Merchant]
    
    @Binding var selection: String
    
    private var suggestions: [Merchant] {
        if selection.isEmpty {
            merchants
        } else {
            merchants.filter { merchant in
                merchant.name.contains(selection) && merchant.name != selection
            }
        }
    }
    
    var body: some View {
        VStack {
            List {
                Section {
                    TextField("Name", text: $selection)
                        .textContentType(.organizationName)
                        .submitLabel(.done)
                    
                }
                
                if !suggestions.isEmpty {
                    Section("Suggestions") {
                        ForEach(suggestions, id: \.self) { merchant in
                            Button(merchant.name) {
                                selection = merchant.name; dismiss()
                            }
                            .tint(.primary)
                        }
                    }
                }
            }
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            #endif
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    PayeeSelectorView(selection: .constant(""))
        .modelContainer(previewContainer)
}
