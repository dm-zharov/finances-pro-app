//
//  CategorySettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2022.
//

import SwiftUI
import SwiftData
import FoundationExtension

struct CategorySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(SettingKey.categoryGroupsOrder, store: .shared) private var categoryGroupsOrder: Data?

    @Query private var categoryGroups: [CategoryGroup]
    @Query(filter: #Predicate<Category> { $0.group == nil }) private var categories: [Category]
    
    @State private var selectedCategoryID: Category.ID?
    @State private var selectedCategoryGroupID: CategoryGroup.ID?

    @State private var showCategoryEditor: Bool = false
    @State private var showCategoryGroupEditor: Bool = false
    @State private var showCategoryGroupSettings: Bool = false
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        StackBox {
            Section {
                if !categories.isEmpty {
                    list
                } else {
                    CategoriesUnavailableView()
                }
            } footer: {
                #if os(macOS)
                HStack {
                    Spacer()
                    
                    if !categories.isEmpty {
                        Button("Add Group") {
                            showCategoryGroupEditor.toggle()
                        }
                    }
                    
                    Button("New Category") {
                        showCategoryEditor.toggle()
                    }
                }
                .padding(.top, 8.0)
                #endif
            }
        }
        .navigationTitle("Categories")
        #if os(iOS)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if !categoryGroups.isEmpty {
                    Button("Groups", systemImage: "square.on.square") {
                        showCategoryGroupSettings.toggle()
                    }
                }
            }
            
            ToolbarItemGroup(placement: .toolbar) {
                if !categories.isEmpty {
                    Button("Add Group") {
                        showCategoryGroupEditor.toggle()
                    }
                }
                Button("New Category") {
                    showCategoryEditor.toggle()
                }
            }
        }
        #endif
        .sheet(item: $selectedCategoryID) { selectedCategoryID in
            if let category: Category = modelContext.registeredModel(for: selectedCategoryID) {
                NavigationStack {
                    CategoryEditorView(category)
                }
            }
        }
        .sheet(item: $selectedCategoryGroupID) { selectedCategoryGroupID in
            if let categoryGroup: CategoryGroup = modelContext.registeredModel(for: selectedCategoryGroupID) {
                NavigationStack {
                    CategoryGroupEditorView(categoryGroup)
                }
            }
        }
        .sheet(isPresented: $showCategoryEditor) {
            NavigationStack {
                CategoryEditorView()
            }
        }
        .sheet(isPresented: $showCategoryGroupEditor) {
            NavigationStack {
                CategoryGroupEditorView()
            }
        }
        .sheet(isPresented: $showCategoryGroupSettings) {
            NavigationStack {
                CategoryGroupSettings()
            }
        }
    }
    
    @MainActor
    var list: some View {
        List(selection: $selectedCategoryID) {
            ForEach(categoryGroups.ordered(by: SettingKey.categoryGroupsOrder)) { categoryGroup in
                Section {
                    if let categories = categoryGroup.categories, !categories.isEmpty {
                        ForEach(categories.sorted(by: { $0.name < $1.name })) { category in
                            CategoryItemRow(category)
                        }
                        #if os(iOS)
                        .inlineMenuVisibility(true)
                        #endif
                    } else {
                        Text("No Categories")
                            .foregroundStyle(.secondary)
                            .selectionDisabled()
                    }
                } header: {
                    Text(categoryGroup.name)
                } footer: {
                    #if os(macOS)
                    HStack {
                        Spacer()
                        Button("Edit Group") {
                            withAnimation {
                                selectedCategoryGroupID = categoryGroup.id
                            }
                        }
                        Button("Delete Group", role: .destructive) {
                            withAnimation {
                                modelContext.delete(categoryGroup)
                            }
                        }
                    }
                    .padding(.vertical, 8.0)
                    .padding(.horizontal, 4.0)
                    #endif
                }
            }
            .id(categoryGroupsOrder ?? Data())
            
            Section {
                ForEach(categories.ordered(by: SettingKey.categoriesOrder)) { category in
                    HStack {
                        CategoryItemRow(category)
                        Spacer(minLength: 8.0)
                            .overlay(alignment: .trailing) {
                                Divider()
                                    .frame(height: 44.0)
                            }
                    }
                }
                .onMove { source, destination in
                    categories.reorder(SettingKey.categoriesOrder, fromOffsets: source, toOffset: destination)
                }
                #if os(iOS)
                .inlineMenuVisibility(true)
                #endif
            } header: {
                if !categoryGroups.isEmpty {
                    Text("Other")
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 44.0)
        .environment(\.editMode, .constant(.active))
        #if os(iOS)
        .listStyle(.insetGrouped)
        .contentMargins(.top, .compact, for: .scrollContent)
        #endif
    }
}

#Preview {
    NavigationStack {
        CategorySettingsView()
    }
    .modelContainer(previewContainer)
}
