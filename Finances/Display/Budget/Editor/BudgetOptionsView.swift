//
//  BudgetOptionsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.03.2024.
//

import Foundation
import SwiftUI

struct BudgetOptionsView: View {
    enum Field: Identifiable, Hashable {
        case amount
        
        var id: Self { self}
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isFinished) private var isFinished
    
    // MARK: - Editing
    
    @Binding var representation: BudgetRepresentation
    
    @FocusState private var focusedField: Field?
    
    private var editorTitle: String {
        String(localized: "Configure Budget")
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            Form {
                Section {
                    AmountField(
                        value: $representation.amount,
                        currency: representation.currency,
                        onReady: { _ in },
                        onSubmit: {
                            focusedField = nil
                        }
                    )
                    .labeled("Amount")
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .amount)
                    .submitLabel(.next)
                    
                    LabeledContent {
                        CurrencySelectorItem(selection: $representation.currency)
                            .menuStyle(.button)
                            .buttonStyle(.borderedInline)
                            .buttonBorderShape(.roundedRectangle)
                    } label: {
                        Text("Currency")
                    }
                }
                
                Section {
                    Picker("Period", selection: $representation.repeatInterval) {
                        ForEach(DatePeriod.allCases, id: \.self) { datePeriod in
                            switch datePeriod {
                            case .day:
                                Text("Daily")
                            case .week:
                                Text("Weekly")
                            case .month:
                                Text("Monthly")
                            case .year:
                                Text("Yearly")
                            }
                        }
                    }

                    DatePicker("Start Date", selection: $representation.startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                Section("Categories") {
                    ForEach(representation.categories) { categoryID in
                        if let category: Category = modelContext.existingModel(with: categoryID) {
                            CategoryItemRow(category)
                        }
                    }
                    if representation.categories.isEmpty {
                        Text("All Categories")
                    }
                }
            }
            .formStyle(.grouped)
            .scrollDismissesKeyboard(.immediately)
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            #endif
            .headerProminence(.standard)
        }
        .navigationTitle(editorTitle)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                DoneButton {
                    withAnimation {
                        if let isFinished {
                            isFinished.wrappedValue = true
                        } else {
                            dismiss()
                        }
                    }
                }
                .disabled(!representation.validate())
            }
        }
    }
}
