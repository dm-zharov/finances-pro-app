//
//  TagsSelectorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 31.10.2023.
//

import SwiftUI
import SwiftData
import AppUI
import OrderedCollections

struct TagsSelectorView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Binding var selection: [String]
    
    private var allTags: [String] {
        Set(existingTags.map(\.name)).union(newTags).sorted()
    }
    
    @Query(sort: \Tag.name) private var existingTags: [Tag]
    @State private var selectedTags: Set<String> = []
    @State private var newTags: Set<String> = []
    @State private var newTag: String = .empty
    
    var body: some View {
        VStack {
            Form {
                if !allTags.isEmpty {
                    Section {
                        OverflowStack(spacing: 8.0) {
                            ForEach(allTags, id: \.self) { tag in
                                toggle(tag)
                            }
                        }
                        #if os(iOS)
                        .padding(16.0)
                        .listRowInsets(.zero)
                        .listRowBackground(Color.ui(.secondarySystemGroupedBackground))
                        #endif
                    }
                }

                Section {
                    TextField("Add New Tag...", text: $newTag)
                        #if os(macOS)
                        .textFieldStyle(.roundedBorder)
                        #endif
                        .focusedValue(\.fieldValue, .tags)
                        .onSubmit {
                            guard !newTag.isEmpty else { return }
                            if !allTags.contains(where: { $0.caseInsensitiveCompare(newTag) == .orderedSame }) {
                                newTags.insert(newTag)
                                selectedTags.insert(newTag)
                            }
                            newTag = .empty
                        }
                }
                #if os(iOS)
                .listSectionSpacing(.custom(16.0))
                #endif
            }
            .formStyle(.grouped)
            .contentMargins(.top, .compact, for: .scrollContent)
            .environment(\.defaultMinListRowHeight, 44.0)
        }
        .navigationTitle("Tags")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Apply") {
                    selection = selectedTags.sorted(); dismiss()
                }
                .disabled(Set(selectedTags) == Set(selection))
            }
        }
        .onAppear {
            selectedTags = Set(selection)
            newTags = selectedTags.subtracting(Set(existingTags.map(\.name)))
        }
    }
    
    func toggle(_ name: String) -> some View {
        ChipsItem(isSelected: selectedTags.contains(name), "#" + name) {
            if selectedTags.contains(name) {
                selectedTags.remove(name)
            } else {
                selectedTags.insert(name)
            }
        }
    }
}

struct TagsSelectorItem: View {
    @Binding var selection: [String]
    
    private var allTags: [String] {
        Set(existingTags.map(\.name)).union(newTags).sorted()
    }
    
    @Query private var existingTags: [Tag]
    @State private var newTags: Set<String> = []
    @State private var showTagsPicker: Bool = false
    
    var body: some View {
        Menu {
            Button(selection.isEmpty ? "Add Tag..." : "Edit Tags...") {
                showTagsPicker.toggle()
            }

            Divider()
            
            ForEach(allTags, id: \.self) { tag in
                if selection.contains(tag) {
                    Button("#" + tag, systemImage: "checkmark") {
                        var selectedTags = Set(selection)
                        selectedTags.remove(tag)
                        selection = Array(selectedTags).sorted()
                    }
                } else {
                    Button("#" + tag) {
                        var selectedTags = Set(selection)
                        selectedTags.insert(tag)
                        selection = Array(selectedTags).sorted()
                    }
                }
            }
            
            Divider()
    
            if !selection.isEmpty {
                Button("Clear Tags") {
                    selection.removeAll()
                }
            }
        } label: {
            #if os(iOS)
            Image(systemName: SymbolName.toolbar(.number).rawValue)
            #else
            Label("Tags", systemImage: SymbolName.toolbar(.number).rawValue)
            #endif
        }
        .onAppear {
            newTags = Set(selection).subtracting(Set(existingTags.map(\.name)))
        }
        .picker(isPresented: $showTagsPicker) {
            NavigationStack {
                TagsSelectorView(selection: $selection)
            }
            .tint(.accentColor)
            .frame(idealWidth: 375.0, idealHeight: 667.0)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#Preview {
    NavigationStack {
        TagsSelectorView(selection: .constant(["Dubai", "Pending"]))
    }
    .modelContainer(previewContainer)
}
