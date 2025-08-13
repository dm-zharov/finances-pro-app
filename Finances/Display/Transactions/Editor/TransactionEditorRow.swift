//
//  TransactionEditorRow.swift
//  Finances
//
//  Created by Dmitriy Zharov on 26.10.2023.
//

import SwiftUI
import SwiftData
import AppUI
import FoundationExtension
import CurrencyKit
import HapticFeedback

#if canImport(SwiftUIIntrospect)
import SwiftUIIntrospect
#endif

#if canImport(KeyboardKit)
import KeyboardKit
#endif

protocol AutocompleteSuggestion: Hashable, CustomStringConvertible { }

struct TransactionAssignmentSuggestion: AutocompleteSuggestion {
    var payee: String
    var categoryID: UUID?
}

extension TransactionAssignmentSuggestion: CustomStringConvertible {
    var description: String {
        payee
    }
}

struct TransactionEditorRow: View {
    enum Field: Hashable {
        typealias Element = Self
        
        case payee
        case amount
    }
    
    @Environment(\.isPresented) private var isPresented
    @Environment(\.calendar) private var calendar
    @Environment(\.modelContext) private var modelContext
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var query: TransactionQuery
    private var completion: ((Bool) -> Void)? = nil
    
    // MARK: - State
    
    @State private var representation = TransactionRepresentation()
    
    @Query private var assets: [Asset]
    @Query private var categories: [Category]
    
    @FocusState private var focusedField: Field?
    @FocusedValue(\.fieldValue) private var focusedSubfield
    @State private var suggestions: [TransactionAssignmentSuggestion] = []
    
    private var isIncome: Bool {
        if let selectedCategoryID = representation.categoryID,
           let category: Category = modelContext.existingModel(with: selectedCategoryID)
        {
            return category.isIncome
        } else {
            return false
        }
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        HStack(alignment: .firstTextBaseline, spacing: 12.0) {
            if let categoryID = representation.categoryID, let category: Category = modelContext.existingModel(with: categoryID) {
                Image(systemName: category.symbolName ?? SymbolName.defaultValue.rawValue)
                    .symbolVariant(.circle.fill)
                    .symbolRenderingMode(.palette)
                    .font(.body)
                    .imageScale(.large)
                    .foregroundStyle(.white, Color(colorName: ColorName(rawValue: category.colorName)))
            } else {
                Image(systemName: SymbolName.defaultValue.rawValue)
                    .symbolVariant(.circle.fill)
                    .symbolRenderingMode(.palette)
                    .font(.body)
                    .imageScale(.large)
                    .foregroundStyle(.white, Color(colorName: ColorName.defaultValue))
            }
            
            VStack(alignment: .leading, spacing: 4.0) {
                HStack {
                    payeeField
                    
                    Spacer()
                    
                    amountField
                        .foregroundStyle(isIncome ? Color.green : Color.primary)
                }
                .font(.body)
                
                HStack {
                    categoryText
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let assetID = representation.assetID, let asset: Asset = modelContext.existingModel(with: assetID) {
                        Text(asset.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Unaccounted")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if !representation.notes.isEmpty {
                    Text(representation.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !calendar.isDateInToday(representation.date) {
                    Text(DateFormatter.relative.string(from: representation.date))
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                
                if !representation.tags.isEmpty {
                    Text(representation.tags.map { "#" + $0 }.joined(separator: " "))
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            .lineLimit(1)
        }
        .toolbarRole(.editor)
        .toolbar {
            if horizontalSizeClass == .compact {
                ToolbarItem(placement: .keyboard) {
                    TransactionEditorToolbar(representation: $representation)
                }
            }

            if horizontalSizeClass == .regular, userInterfaceIdiom != .mac {
                ToolbarItem(placement: .secondaryAction) {
                    DateSelectorItem(selection: $representation.date)
                }

                ToolbarItem(placement: .secondaryAction) {
                    CategorySelectorItem(selection: $representation.categoryID)
                }

                ToolbarItem(placement: .secondaryAction) {
                    TagsSelectorItem(selection: $representation.tags)
                }

                ToolbarItem(placement: .secondaryAction) {
                    NotesSelectorItem(selection: $representation.notes)
                }
            }
        }
        .task(id: query, priority: .userInitiated) {
            if let searchAssetID = query.searchAssetID, let asset = modelContext.existingModel(Asset.self, with: searchAssetID) {
                self.representation.currency = Currency(asset.currencyCode)
                self.representation.assetID = asset.externalIdentifier
            }
            if let searchCategoryID = query.searchCategoryID, let category = modelContext.existingModel(Category.self, with: searchCategoryID) {
                self.representation.categoryID = category.externalIdentifier
            }
        }
        .onChange(of: focusedField) { _, focusedField in
            if focusedField == nil, focusedSubfield == nil {
                withAnimation {
                    completion?(false)
                }
            }
        }
    }
    
    private var payeeField: some View {
        InlinePredictionField("Payee", text: $representation.payee, completions: suggestions.map(\.payee))
            .suggestible(representation.payee, suggestions: $suggestions)
            .focused($focusedField, equals: .payee)
            .textContentType(.organizationName)
            .submitLabel(.next)
            .onDidAppear {
                focusedField = .payee
            }
            #if os(iOS)
            .customReturn()
            #endif
            .customKeyboardSubmit {
                if let completion = suggestions.first(where: { $0.payee.hasPrefix(representation.payee) }) {
                    representation.payee = completion.payee
                    if representation.categoryID == nil {
                        representation.categoryID = completion.categoryID
                    }
                }
                withAnimation {
                    focusedField = .amount
                }
            }
    }
    
    private var categoryText: some View {
        VStack {
            if let selectedCategoryID = representation.categoryID,
               let category: Category = modelContext.existingModel(with: selectedCategoryID)
            {
                Text(category.name)
            } else if let suggestedCategoryID = suggestions.first(where: { $0.payee.hasPrefix(representation.payee) })?.categoryID,
                      let category: Category = modelContext.existingModel(with: suggestedCategoryID)
            {
                Text(category.name)
                    .foregroundStyle(.secondary)
            } else {
                Text("Select Category")
                    .foregroundStyle(Color.ui(.placeholderText))
            }
        }
    }
    
    private var amountField: some View {
        AmountField(value: $representation.amount, currency: representation.currency, onReady: { _ in }) {
            withAnimation {
                if representation.validate() {
                    save(); completion?(true)
                } else {
                    completion?(false)
                }
            }
        }
        .focused($focusedField, equals: .amount)
        .foregroundStyle(representation.amount.sign == .minus ? Color.primary : Color.green)
        .multilineTextAlignment(.trailing)
        .submitLabel(.next)
        .onChange(of: representation.categoryID) { _, categoryID in
            guard
                let categoryID,
                let category: Category = modelContext.existingModel(with: categoryID)
            else {
                return
            }
            
            let categorySign: FloatingPointSign = category.isIncome ? .plus : .minus
            
            if representation.amount.sign != categorySign {
                representation.amount = representation.amount.reversed
            }
        }
    }
    
    init(query: TransactionQuery, _ onCompletion: ((Bool) -> Void)? = nil) {
        self.query = query
        self.completion = onCompletion
    }
}

// MARK: - Operations

extension TransactionEditorRow {
    @MainActor
    private func save() {
        let transaction = Transaction()
        modelContext.insert(transaction)

        transaction.performWithRelationshipUpdates {
            transaction.objectRepresentation = representation
        }
        
        HapticFeedback.impact(flexibility: .soft).play()
    }
}

#Preview {
    List {
        TransactionEditorRow(query: .init())
    }
    .modelContainer(previewContainer)
}
