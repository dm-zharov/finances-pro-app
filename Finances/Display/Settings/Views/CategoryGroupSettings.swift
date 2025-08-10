//
//  CategoryGroupSettings.swift
//  Finances
//
//  Created by Dmitriy Zharov on 11.04.2024.
//

import SwiftUI
import SwiftData
import FoundationExtension
import AppUI
import FinancesCore

struct CategoryGroupItemRow: View {
    @Environment(\.isInlineMenuVisible) private var isInlineMenuVisible
    @Environment(\.modelContext) private var modelContext
    
    let categoryGroup: CategoryGroup
    
    @State private var showCategoryGroupEditor: Bool = false
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        LabeledContent {
            if isInlineMenuVisible {
                Menu {
                    menuItems
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.accent)
                        .imageScale(.large)
                }
            }
        } label: {
            Label {
                Text(categoryGroup.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } icon: {
                Image(systemName: "rectangle.on.rectangle")
                    .imageSize(24.0)
                    .symbolVariant(.circle.fill)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .accent)
            }
        }
        .imageScale(.large)
        .lineLimit(1)
        .contextMenu {
            menuItems
        }
        .sheet(isPresented: $showCategoryGroupEditor) {
            NavigationStack {
                CategoryGroupEditorView(categoryGroup)
            }
        }
    }
    
    @ViewBuilder
    private var menuItems: some View {
        Button("Edit Group", systemImage: "pencil") {
            showCategoryGroupEditor.toggle()
        }
        Divider()
        Button("Delete", systemImage: "trash", role: .destructive) {
            withAnimation {
                modelContext.delete(categoryGroup)
            }
        }
    }
    
    init(_ categoryGroup: CategoryGroup) {
        self.categoryGroup = categoryGroup
    }
}

struct CategoryGroupSettings: View {
    @Environment(\.editMode) private var editMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var categoryGroups: [CategoryGroup]

    @State private var selectedCategoryGroupID: CategoryGroup.ID?
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        StackBox {
            if !categoryGroups.isEmpty {
                list
            } else {
                CategoryGroupsUnavailableView()
            }
        }
        .navigationTitle("Edit Groups")
        .toolbarTitleDisplayMode(.inline)
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !editMode.isEditing {
                    DoneButton {
                        dismiss()
                    }
                }
            }
        }
        #endif
        .sheet(item: $selectedCategoryGroupID) { selectedCategoryGroupID in
            if let categoryGroup: CategoryGroup = modelContext.registeredModel(for: selectedCategoryGroupID) {
                NavigationStack {
                    CategoryGroupEditorView(categoryGroup)
                }
            }
        }
    }
    
    @MainActor
    var list: some View {
        List(selection: $selectedCategoryGroupID) {
            Section {
                ForEach(categoryGroups.ordered(by: SettingKey.categoryGroupsOrder)) { categoryGroup in
                    HStack {
                        CategoryGroupItemRow(categoryGroup)
                        Spacer(minLength: 8.0)
                            .overlay(alignment: .trailing) {
                                Divider()
                                    .frame(height: 44.0)
                            }
                    }
                }
                .onMove { source, destination in
                    categoryGroups.reorder(SettingKey.categoryGroupsOrder, fromOffsets: source, toOffset: destination)
                }
                .onDelete { offsets in
                    withAnimation {
                        for categoryGroup in categoryGroups.ordered(by: SettingKey.categoryGroupsOrder).elements(atOffsets: offsets) {
                            modelContext.delete(categoryGroup)
                        }
                    }
                }
                #if os(iOS)
                .inlineMenuVisibility(true)
                #endif
            }
        }
        .environment(\.defaultMinListRowHeight, 44.0)
        .environment(\.editMode, .constant(.active))
        #if os(iOS)
        .listStyle(.insetGrouped)
        .contentMargins(.top, .compact, for: .scrollContent)
        #endif
    }
    
    func delete(at offsets: IndexSet) {
        withAnimation {
            for (index, categoryGroup) in categoryGroups.ordered(by: SettingKey.categoryGroupsOrder).enumerated() {
                if offsets.contains(index) {
                    modelContext.delete(categoryGroup)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CategoryGroupSettings()
    }
    .modelContainer(previewContainer)
}
