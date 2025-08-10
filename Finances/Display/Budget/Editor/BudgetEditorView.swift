//
//  BudgetEditorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 18.10.2023.
//

import SwiftUI
import SwiftData
import TipKit
import HapticFeedback
import FinancesCore

struct BudgetEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Data
    
    let budget: Budget?
    
    // MARK: - Editing
    
    @State private var representation = BudgetRepresentation()
    @State private var isFinished: Bool = false
    
    @Query(sort: [SortDescriptor(\CategoryGroup.name)]) private var categoryGroups: [CategoryGroup]
    @Query(filter: #Predicate<Category> { $0.group == nil }) private var categories: [Category]
    
    @State private var selection: Set<Category.ExternalID> = []
    @State private var hideCategories: Bool = false
    @State private var showOptions: Bool = false
    
    var body: some View {
        VStack {
            List(selection: $selection) {
                Section {
                    Toggle("All Categories", isOn: $hideCategories.animation(.default))
                        .onChange(of: hideCategories) {
                            if hideCategories {
                                selection.removeAll()
                            }
                        }
                } footer: {
                    Text("By selecting this option, all future categories will be included in the budget.")
                }
                
                if !hideCategories {
                    ForEach(categoryGroups) { categoryGroup in
                        if let categories = categoryGroup.categories, !categories.isEmpty {
                            Section {
                                ForEach(categories.sorted(by: { $0.name < $1.name }), id: \.externalIdentifier) { category in
                                    CategoryItemRow(category)
                                }
                            } header: {
                                Text(categoryGroup.name)
                            }
                        }
                    }
                    Section {
                        ForEach(categories.ordered(by: SettingKey.categoriesOrder), id: \.externalIdentifier) { category in
                            CategoryItemRow(category)
                        }
                    } header: {
                        if !categoryGroups.isEmpty {
                            Text("Other")
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .environment(\.defaultMinListRowHeight, 44.0)
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            #endif
        }
        .navigationTitle("Choose Categories")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    representation.categories = Array(selection); showOptions.toggle()
                }
                .disabled(selection.isEmpty && !hideCategories)
            }
        }
        .navigationDestination(isPresented: $showOptions) {
            BudgetOptionsView(representation: $representation)
                .environment(\.isFinished, $isFinished)
        }
        .onChange(of: isFinished) {
            if isFinished {
                withAnimation {
                    save(); dismiss()
                }
            }
        }
        .preferredContentSize(minWidth: 500.0, minHeight: 420.0)
    }
    
    init(_ budget: Budget? = nil) {
        self.budget = budget
        self.representation = budget?.objectRepresentation ?? BudgetRepresentation()
    }
}

// MARK: - Operation

extension BudgetEditorView {
    @MainActor
    private func save() {
        let budget = budget ?? {
            let budget = Budget()
            modelContext.insert(budget)
            return budget
        }()

        budget.objectRepresentation = representation
        
        HapticFeedback.impact(flexibility: .soft).play()
        HapticFeedback.selection.play()
    }
}

#Preview {
    NavigationStack {
        BudgetEditorView()
    }
    .modelContainer(previewContainer)
}
