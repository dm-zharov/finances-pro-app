//
//  TagSettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.11.2023.
//

import SwiftUI
import SwiftData

struct TagEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var tag: Tag
    
    @State private var name: String = .empty
    
    var body: some View {
        VStack {
            List {
                TextField("Name", text: $name)
                    .onSubmit {
                        if !name.isEmpty {
                            tag.name = name
                        }
                        dismiss()
                    }
            }
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            #endif
        }
        .navigationTitle("Rename")
        .onChange(of: tag.name, initial: true) {
            self.name = tag.name
        }
    }
}

struct TagSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Tag.name) private var tagList: [Tag]
    @State private var newTag: String = .empty
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(tagList, id: \.name) { tag in
                        NavigationLink {
                            TagEditorView(tag: tag)
                        } label: {
                            Text("#" + tag.name)
                                .contextMenu {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        modelContext.delete(tag)
                                    }
                                }
                        }
                    }
                }
                
                TextField("Add New Tag...", text: $newTag)
                    .onSubmit {
                        if !newTag.isEmpty {
                            let tag = Tag(name: newTag)
                            modelContext.insert(tag)
                            newTag = .empty
                        }
                    }
            }
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            #endif
        }
        .navigationTitle("Tags")
    }
}

#Preview {
    NavigationStack {
        TagSettingsView()
    }
    .modelContainer(previewContainer)
}
