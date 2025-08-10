//
//  CategorySelectorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 07.10.2023.
//

import SwiftUI
import SwiftData
import AppUI
import FoundationExtension
import FinancesCore

struct CategorySelectorView: View {
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selection: Category.ExternalID?
    
    @Query(sort: [SortDescriptor(\CategoryGroup.name)]) private var categoryGroups: [CategoryGroup]
    @Query(filter: #Predicate<Category> { $0.group == nil }) private var categories: [Category]
    
    @State private var selectedCategoryGroupID: UUID?
    @State private var showCategoryGroupEditor: Bool = false

    @State private var selectedCategoryID: Category.ExternalID?
    @State private var showCategoryEditor: Container<Category.ID>?
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            if !categories.isEmpty {
                list
            } else {
                CategoriesUnavailableView()
            }
        }
        .navigationTitle("Category")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                #if os(iOS)
                EditButton()
                #endif
            }
            
            ToolbarItemGroup(placement: .toolbar) {
                if editMode.isEditing || categories.isEmpty {
                    Spacer()
                    Button("New Category") {
                        showCategoryEditor = Container<Category.ID>()
                    }
                }
            }
        }
        .sheet(item: $showCategoryEditor, onDismiss: { selectedCategoryID = nil }) { container in
            NavigationStack {
                if let categoryID = container.id, let category: Category = modelContext.registeredModel(for: categoryID) {
                    CategoryEditorView(category)
                } else {
                    CategoryEditorView()
                }
            }
        }
        .onChange(of: selectedCategoryID) {
            if let selectedCategoryID {
                if editMode.isEditing {
                    if let category: Category = modelContext.existingModel(with: selectedCategoryID) {
                        showCategoryEditor = Container(id: category.id)
                    } else {
                        return assertionFailure()
                    }
                } else {
                    selection = selectedCategoryID; dismiss()
                }
            }
        }
    }
    
    @MainActor
    var list: some View {
        List(selection: $selectedCategoryID) {
            ForEach(categoryGroups.ordered(by: SettingKey.categoryGroupsOrder)) { categoryGroup in
                if let categories = categoryGroup.categories, !categories.isEmpty {
                    Section {
                        ForEach(categories.sorted(by: { $0.name < $1.name }), id: \.externalIdentifier) { category in
                            CategoryItemRow(category)
                        }
                        #if os(iOS)
                        .inlineMenuVisibility(editMode.isEditing)
                        #endif
                    } header: {
                        Text(categoryGroup.name)
                    }
                }
            }
            Section {
                ForEach(categories.ordered(by: SettingKey.categoriesOrder), id: \.externalIdentifier) { category in
                    HStack {
                        CategoryItemRow(category)
                        if editMode.isEditing {
                            Spacer()
                                .overlay(alignment: .trailing) {
                                    Divider()
                                        .frame(height: 44.0)
                                }
                        }
                    }
                }
                .onMove { source, destination in
                    categories.reorder(SettingKey.categoriesOrder, fromOffsets: source, toOffset: destination)
                }
                #if os(iOS)
                .inlineMenuVisibility(editMode.isEditing)
                #endif
            } header: {
                if !categoryGroups.isEmpty {
                    Text("Other")
                }
            }
            if let _ = selection, !editMode.isEditing {
                Button("Uncategorized") {
                    selection = .none; dismiss()
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 44.0)
        #if os(iOS)
        .listStyle(.insetGrouped)
        .contentMargins(.top, .compact, for: .scrollContent)
        #endif
        .headerProminence(.standard)
    }
}

struct CategorySelectorItem: View {
    @Binding var selection: UUID?
    
    @Query(sort: \Category.lastUpdatedDate, order: .reverse) private var categories: [Category]
    
    @State private var showCategoryPicker: Bool = false
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        Menu {
            Picker("Suggestions", selection: $selection) {
                ForEach(categories.prefix(3)) { category in
                    Label(category.name, systemImage: SymbolName(rawValue: category.symbolName).rawValue)
                        .tag(Optional<UUID>.some(category.externalIdentifier))
                }
            }
            .pickerStyle(.inline)
            
            Button(!categories.isEmpty ? "Show More" : "Add Categories...", systemImage: "ellipsis.circle") {
                showCategoryPicker.toggle()
            }
        } label: {
            #if os(iOS)
            Image(systemName: SymbolName.toolbar(.paperclip).rawValue)
            #else
            Label("Category", systemImage: SymbolName.toolbar(.paperclip).rawValue)
            #endif
        }
        .picker(isPresented: $showCategoryPicker) {
            NavigationStack {
                CategorySelectorView(selection: $selection)
                    .environment(\.editMode, $editMode)
                    .onDisappear { if editMode.isEditing { editMode = .inactive } }
            }
            .tint(.accentColor)
            .frame(idealWidth: 375.0, idealHeight: 667.0)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#Preview {
    NavigationStack {
        CategorySelectorView(selection: .constant(nil))
    }
    .modelContainer(previewContainer)
}
