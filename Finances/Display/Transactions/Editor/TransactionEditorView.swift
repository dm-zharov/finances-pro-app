//
//  TransactionEditorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 22.12.2022.
//

import SwiftUI
import SwiftData
import AppUI
import CurrencyKit
import HapticFeedback
import AppIntents
import FoundationExtension

#if os(iOS)
import SwiftUIIntrospect
import AppIntents
import FoundationExtension
#endif

struct TransactionEditorView: View {
    enum Field: Identifiable, Hashable {
        case category
        case payee
        case asset
        case amount
        case currency
        case tags
        
        var id: Self { self}
    }
    
    @Environment(\.calendar) private var calendar
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) private var dismiss
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // MARK: - Data
    
    let transaction: Transaction?
    
    // MARK: - State
    
    @State private var representation = TransactionRepresentation()
    
    @Query(sort: \Asset.name) private var assets: [Asset]
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var selectedField: Field?
    @FocusState private var focusedField: Field?
    @State private var editMode: EditMode = .inactive
    @State private var suggestions: [TransactionAssignmentSuggestion] = []
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            if userInterfaceIdiom == .mac {
                form
            } else {
                list
            }
        }
        .navigationTitle("Transaction")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                CancelButton {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .confirmationAction) {
                Button(
                    transaction == nil ? String(localized: "Add") : String(localized: "Save"),
                    systemImage: "checkmark"
                ) {
                    withAnimation {
                        save(); dismiss()
                    }
                }
                .disabled(!representation.validate())
            }
            if horizontalSizeClass == .compact {
                ToolbarItemGroup(placement: .keyboard) {
                    TransactionEditorToolbar(representation: $representation)
                }
            }
        }
        .toolbarRole(.editor)
        .sheet(item: $selectedField) { field in
            NavigationStack {
                switch field {
                case .asset:
                    AssetSelectorView(selection: $representation.assetID)
                        .environment(\.editMode, $editMode)
                        .onDisappear { if editMode.isEditing { editMode = .inactive } }
                case .category:
                    CategorySelectorView(selection: $representation.categoryID)
                        .environment(\.editMode, $editMode)
                        .onDisappear { if editMode.isEditing { editMode = .inactive } }
                case .tags:
                    TagsSelectorView(selection: $representation.tags)
                default:
                    fatalError()
                }
            }
        }
        .onAppear {
            if let transaction, transaction.externalIdentifier.entityIdentifierString != representation.id {
                representation = transaction.objectRepresentation
            } else if let asset = assets.sorted(by: \.lastUpdatedDate, order: .reverse).first {
                representation.assetID = asset.externalIdentifier
                representation.currency = Currency(asset.currencyCode)
            }
        }
        .onChange(of: representation.assetID) {
            if let assetID = representation.assetID, let asset: Asset = modelContext.existingModel(with: assetID) {
                representation.currency = Currency(asset.currencyCode)
            }
        }
        .interactiveDismissDisabled(focusedField != nil)
        .preferredContentSize(minWidth: 500.0, minHeight: 386)
    }
    
    @MainActor
    private var list: some View {
        List(selection: $selectedField) {
            Section {
                NavigationLink(value: Field.category) {
                    LabeledContent {
                        if let selectedCategoryID = representation.categoryID,
                           let category: Category = modelContext.existingModel(with: selectedCategoryID) {
                            Text(category.name)
                        } else if let suggestedCategoryID = suggestions.first(where: { $0.payee.hasPrefix(representation.payee) })?.categoryID,
                                  let category: Category = modelContext.existingModel(with: suggestedCategoryID)
                        {
                            Text(category.name)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Uncategorized")
                        }
                    } label: {
                        Label {
                            Text("Category")
                        } icon: {
                            SettingImage(.paperclip)
                        }
                    }
                }

                Label {
                    Spacer()
                        .frame(maxWidth: .infinity)
                        .overlay {
                            payeeField
                        }
                } icon: {
                    SettingImage(.storefront)
                }
            }

            Section {
                NavigationLink(value: Field.asset) {
                    LabeledContent {
                        if let assetID = representation.assetID,
                           let asset: Asset = modelContext.existingModel(with: assetID) {
                            Text(asset.name)
                        } else {
                            Text("Unaccounted")
                        }
                    } label: {
                        Label {
                            Text(representation.amount.isSignMinus ? "From": "To", comment: "Asset")
                        } icon: {
                            SettingImage(.asset)
                        }
                    }
                }

                Label {
                    LabeledContent {
                        CurrencySelectorItem(selection: $representation.currency)
                            .menuStyle(.button)
                            .buttonStyle(.borderedInline)
                            .buttonBorderShape(.roundedRectangle)
                            .disabled(representation.asset != nil)
                    } label: {
                        amountField
                    }
                } icon: {
                    SettingImage(.pencil)
                        .backgroundStyle(representation.amount.isSignMinus ? AnyShapeStyle(.fill) : AnyShapeStyle(.green))
                }
            }

            Section {
                DatePicker(selection: $representation.date, displayedComponents: .date) {
                    Label {
                        Text("Date")
                    } icon: {
                        SettingImage(.date)
                    }
                }
                .datePickerStyle(.compact)
                
                if 4 == 5 {
                    Picker(selection: $representation.repetition.frequency) {
                        Text("None")
                            .tag(Optional<DatePeriod>.none)
                        Divider()
                        Text("Every Day")
                            .tag(Optional<DatePeriod>.some(DatePeriod.day))
                        Text("Every Week")
                            .tag(Optional<DatePeriod>.some(DatePeriod.week))
                        Text("Every Month")
                            .tag(Optional<DatePeriod>.some(DatePeriod.month))
                        Text("Every Year")
                            .tag(Optional<DatePeriod>.some(DatePeriod.year))
                    } label: {
                        Label {
                            Text("Repeat")
                        } icon: {
                            SettingImage(.repeat)
                        }
                    }
                    .onChange(of: representation.repetition.frequency) {
                        if representation.repetition.frequency == nil {
                            representation.repetition.endDate = nil
                        }
                    }
                    
                    if let repetitionFrequency = representation.repetition.frequency {
                        Picker("End Repeat", selection: $representation.repetition.hasEnding) {
                            Text("Never")
                                .tag(false)
                            Text("On Date")
                                .tag(true)
                        }
                        .onChange(of: representation.repetition.hasEnding) {
                            if representation.repetition.hasEnding {
//                                representation.repetition.endDate = calendar
//                                    .date(byAdding: repetitionFrequency, to: representation.date)
                            }
                        }
                        
                        if let endDate = representation.repetition.endDate {
                            DatePicker(
                                selection: Binding<Date>(
                                    get: { endDate },
                                    set: { endDate in representation.repetition.endDate = endDate }
                                ),
                                displayedComponents: .date
                            ) {
                                Text("End Date")
                            }
                            .datePickerStyle(.compact)
                        }
                    }
                }
            }

            Section {
                NavigationLink(value: Field.tags) {
                    LabeledContent {
                        Text(representation.tags.isEmpty ? String.empty : "\(representation.tags.count) Selected")
                    } label: {
                        Label {
                            Text("Tags")
                        } icon: {
                            SettingImage(.number)
                        }
                    }
                }
            }

            Section {
                notesField
            }
        }
        .environment(\.defaultMinListRowHeight, 48.0)
        .scrollDismissesKeyboard(.interactively)
#if os(iOS)
        .contentMargins(.top, .compact, for: .scrollContent)
        .listStyle(.insetGrouped)
        .listSectionSpacing(.custom(16.0))
        .listRowInsets(.init(top: 10.0, leading: 16.0, bottom: 10.0, trailing: 16.0))
#endif
        .headerProminence(.increased)
        .navigationBarBackButtonHidden()
    }
    
    private var form: some View {
        Form {
            Section {
                Picker(selection: $representation.categoryID) {
                    Label("Uncategorized", systemImage: SymbolName.defaultValue.rawValue)
                        .tag(Optional<UUID>.none)
                    
                    Section("Expense") {
                        ForEach(categories.filter { $0.isIncome == false }) { category in
                            Label(category.name, systemImage: SymbolName(rawValue: category.symbolName).rawValue)
                                .tag(Optional<UUID>.some(category.externalIdentifier))
                        }
                    }
                    
                    Section("Income") {
                        ForEach(categories.filter { $0.isIncome == true }) { category in
                            Label(category.name, systemImage: SymbolName(rawValue: category.symbolName).rawValue)
                                .tag(Optional<UUID>.some(category.externalIdentifier))
                        }
                    }
                } label: {
                    Label {
                        Text("Category")
                    } icon: {
                        SettingImage(.paperclip)
                    }
                }
                .pickerStyle(.menu)

                payeeField
            }

            Section {
                Picker(selection: $representation.assetID) {
                    Text("Unaccounted")
                        .tag(Optional<UUID>.none)
                    
                    Divider()
                    
                    ForEach(assets.filter { $0.isHidden == false }) { asset in
                        Label(asset.name, systemImage: asset.symbolName)
                            .tag(Optional<UUID>.some(asset.externalIdentifier))
                    }
                } label: {
                    Label {
                        Text(representation.amount.isSignMinus ? "From": "To", comment: "Asset")
                    } icon: {
                        SettingImage(.asset)
                    }
                }
                .pickerStyle(.menu)
                
                if representation.asset == nil {
                    CurrencyPicker(
                        selection: $representation.currency,
                        suggestions: Array(Set(assets.map { Currency($0.currencyCode) }))
                    )
                }
                
                amountField
            }

            Section {
                DatePicker(selection: $representation.date, displayedComponents: .date) {
                    Label {
                        Text("Date")
                    } icon: {
                        SettingImage(.date)
                    }
                }
                .datePickerStyle(.compact)
            }

            Section {
                LabeledContent {
                    TagsSelectorItem(selection: $representation.tags)
                } label: {
                    Label {
                        Text("Tags")
                    } icon: {
                        SettingImage(.number)
                    }
                }
            }

            Section {
                notesField
            }
        }
        .formStyle(.grouped)
    }
    
    init(_ transaction: Transaction? = nil) {
        self.transaction = transaction
    }
}

// MARK: - Fields

extension TransactionEditorView {
    func categoryField(@ViewBuilder content: () -> some View) -> some View {
        LabeledContent {
            content()
        } label: {
            Label {
                Text("Category")
            } icon: {
                SettingImage(.paperclip)
            }
        }
    }
    
    var payeeField: some View {
        InlinePredictionField(
            text: $representation.payee,
            prompt: userInterfaceIdiom == .mac ? "Name" : nil,
            completions: suggestions.map(\.payee),
            label: {
                Label {
                    Text("Payee")
                } icon: {
                    SettingImage(.storefront)
                }
            }
        )
        .suggestible(representation.payee, suggestions: $suggestions)
        .focused($focusedField, equals: .payee)
        .textContentType(.organizationName)
        .clearButtonMode(.whileEditing)
        .submitLabel(.next)
        .onDidAppear {
            if transaction == nil {
                focusedField = .payee
            }
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
    
    @ViewBuilder
    var amountField: some View {
        AmountField(value: $representation.amount, currency: representation.currency, onReady: { _ in }) {
            withAnimation {
                focusedField = nil
            }
        }
        .foregroundStyle(representation.amount.isSignMinus ? Color.primary : Color.green)
        .multilineTextAlignment(.leading)
        .focused($focusedField, equals: .amount)
        .submitLabel(.next)
        #if os(iOS)
        .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18, .v26)) { textField in
            textField.clearButtonMode = .whileEditing
         }
        #endif
        .onChange(of: representation.categoryID) { _, categoryID in
            guard
                let categoryID,
                let category: Category = modelContext.existingModel(with: categoryID)
            else {
                return
            }
            
            if (representation.amount.sign == .plus) != category.isIncome {
                representation.amount = representation.amount.reversed
            }
        }
    }
    
    var notesField: some View {
        TextField(
            "Note",
            text: $representation.notes,
            prompt: userInterfaceIdiom == .mac ? Text("Freeform Text") : nil
        )
    }
}

// MARK: - Operation

extension TransactionEditorView {
    @MainActor
    private func save() {
        let transaction = transaction ?? {
            let transaction = Transaction()
            modelContext.insert(transaction)
            return transaction
        }()

        transaction.performWithRelationshipUpdates {
            transaction.objectRepresentation = representation
        }
        
        HapticFeedback.impact(flexibility: .soft).play()
    }
}

#Preview {
    NavigationStack {
        TransactionEditorView()
    }
    .modelContainer(previewContainer)
}


struct SuggestibleModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    let value: String
    @Binding var suggestions: [TransactionAssignmentSuggestion]
    
    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _, currentText in
                guard !currentText.isEmpty else {
                    return suggestions = []
                }

                var fetchDescriptor = FetchDescriptor<Transaction>(
                    predicate: TransactionQuery.predicate(searchPayee: currentText),
                    sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
                )
                fetchDescriptor.relationshipKeyPathsForPrefetching = [\Transaction.category, \Transaction.payee]
                
                let transactions: [Transaction] = (try? modelContext.fetch(fetchDescriptor, limit: 10)) ?? []
                
                var seen = Set<String>()
                suggestions = transactions
                    .compactMap { transaction -> TransactionAssignmentSuggestion? in
                        if let payee = transaction.payee?.name {
                            return TransactionAssignmentSuggestion(
                                payee: payee,
                                categoryID: transaction.category?.externalIdentifier
                            )
                        } else {
                            return nil
                        }
                    }
                    .filter { seen.insert($0.description).inserted }
                    .sorted(by: \.description)
            }
    }
}

extension View {
    // TODO: Generic fuction of <T>, where T: PersistentModel, Searchable (or Suggestible). Result bind to Binding<String>
    func suggestible(_ value: String, suggestions: Binding<[TransactionAssignmentSuggestion]>) -> some View {
        modifier(SuggestibleModifier(value: value, suggestions: suggestions))
    }
}

private extension TransactionRepresentation.Repetition {
    var hasEnding: Bool {
        get {
            endDate != nil
        }
        set {
            endDate = newValue ? .distantFuture : nil
        }
    }
}
