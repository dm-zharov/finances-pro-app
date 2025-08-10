//
//  CategoryItemRow.swift
//  Finances
//
//  Created by Dmitriy Zharov on 11.10.2023.
//

import SwiftUI
import AppUI
import FoundationExtension
import SwiftData

struct CategoryItemRow: View {
    @Environment(\.isInlineMenuVisible) private var isInlineMenuVisible
    @Environment(\.modelContext) private var modelContext
    
    let category: Category
    
    @State private var showCategoryEditor: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        LabeledContent {
            HStack {
                Text(category.type.localizedDescription)
                    .foregroundStyle(.secondary)
                if isInlineMenuVisible {
                    Menu {
                        menuItems
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.accent)
                            .imageScale(.large)
                    }
                }
            }
        } label: {
            Label {
                Text(category.name)
                    .layoutPriority(1)
            } icon: {
                Image(systemName: category.symbolName ?? SymbolName.defaultValue.rawValue)
                    .imageSize(24.0)
                    .symbolVariant(.circle.fill)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color(colorName: ColorName(rawValue: category.colorName)))
            }
            .imageScale(.large)
        }
        .lineLimit(1)
        .contextMenu {
            menuItems
        }
        .sheet(isPresented: $showCategoryEditor) {
            NavigationStack {
                CategoryEditorView(category)
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete category \(category.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible,
            actions: {
                Button("Delete the category only", role: .destructive) {
                    modelContext.delete(category)
                }
                Button("Delete the category with transactions", role: .destructive) {
                    for transaction in (category.transactions ?? []) {
                        transaction.performWithRelationshipUpdates([.payee, .tags]) {
                            modelContext.delete(transaction)
                        }
                    }
                    modelContext.delete(category)
                }
                Button("Cancel", role: .cancel) {
                    showDeleteConfirmation.toggle()
                }
            }, message: {
                Text("Deleting the category could affect financial reports.\nChoose wisely. You cannot undo this action.")
            }
        )
    }
    
    @ViewBuilder
    private var menuItems: some View {
        Button("Edit Category", systemImage: "pencil") {
            showCategoryEditor.toggle()
        }
        Divider()
        Button("Delete", systemImage: "trash", role: .destructive) {
            showDeleteConfirmation.toggle()
        }
    }
    
    init(_ category: Category) {
        self.category = category
    }
}
