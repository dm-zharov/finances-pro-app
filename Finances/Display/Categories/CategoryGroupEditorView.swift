//
//  CategoryGroupEditorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 12.02.2024.
//

import SwiftUI
import AppUI
import HapticFeedback
import SwiftData

struct CategoryGroupEditorView: View {
    enum Field: Identifiable, Hashable {
        case name
        
        var id: Self { self}
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Data
    
    let categoryGroup: CategoryGroup?
    let showsCancel: Bool
    
    // MARK: - State
    
    @State private var representation = CategoryGroupRepresentation()
    
    @FocusState private var focusedField: Field?
    
    private var editorTitle: String {
        categoryGroup == nil ? String(localized: "New Group") : String(localized: "Edit Group")
    }

    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            #if os(iOS)
            list
            #else
            form
            #endif
        }
        .navigationTitle(editorTitle)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if showsCancel {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                DoneButton {
                    withAnimation {
                        save(); dismiss()
                    }
                }
                .disabled(!representation.validate())
            }
        }
        .onAppear {
            if let categoryGroup, categoryGroup.externalIdentifier != representation.id {
                representation = categoryGroup.objectRepresentation
            }
        }
        .interactiveDismissDisabled(focusedField != nil)
        .preferredContentSize(minWidth: 200)
    }
    
    @MainActor
    var list: some View {
        List {
            Section {
                TextField("Name", text: $representation.name)
                    .focused($focusedField, equals: .name)
                    .clearButtonMode(.whileEditing)
                    .onDidAppear {
                        focusedField = .name
                    }
            }
            
            if let categoryGroup {
                Section {
                    Button("Delete Group", role: .destructive) {
                        modelContext.delete(categoryGroup)
                        dismiss()
                    }
                }
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        .contentMargins(.top, .compact, for: .scrollContent)
        #endif
    }
    
    var form: some View {
        Form {
            TextField("Name:", text: $representation.name)
        }
        .padding()
    }
    
    init(_ categoryGroup: CategoryGroup? = nil, showsCancel: Bool = true) {
        self.categoryGroup = categoryGroup
        self.showsCancel = showsCancel
    }
}

// MARK: - Operations

extension CategoryGroupEditorView {
    @MainActor
    private func save() {
        let categoryGroup = categoryGroup ?? {
            let categoryGroup = CategoryGroup()
            modelContext.insert(categoryGroup)
            return categoryGroup
        }()
        
        categoryGroup.objectRepresentation = representation
        
        HapticFeedback.impact(flexibility: .soft).play()
    }
}

#Preview {
    NavigationStack {
        CategoryGroupEditorView()
    }
    .modelContainer(previewContainer)
}
