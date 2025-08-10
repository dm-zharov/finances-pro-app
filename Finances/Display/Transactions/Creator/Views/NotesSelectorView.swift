//
//  NotesSelectorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 31.10.2023.
//

import SwiftUI
import AppUI
import SwiftData

struct NotesSelectorView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Binding var selection: String

    @State private var text: String = .empty
    
    var body: some View {
        VStack {
            List {
                TextField("Freeform Text", text: $text)
                    .focusedValue(\.fieldValue, .notes)
                    .onSubmit {
                        save(); dismiss()
                    }
            }
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            #endif
        }
        .navigationTitle("Note")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                DoneButton {
                    save(); dismiss()
                }
                .disabled(text.isEmpty)
            }
        }
    }
    
    @MainActor
    private func save() {
        self.selection = text
    }
}

struct NotesSelectorItem: View {
    @Binding var selection: String
    
    @State private var showNotesView: Bool = false
    
    var body: some View {
        Menu {
            EmptyView()
        } label: {
            Image(systemName: SymbolName.toolbar(.note).rawValue)
        } primaryAction: {
            showNotesView.toggle()
        }
        .picker(isPresented: $showNotesView) {
            NavigationStack {
                NotesSelectorView(selection: $selection)
            }
            .tint(.accentColor)
            .frame(idealWidth: 375.0, idealHeight: 667.0)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#Preview {
    NavigationStack {
        NotesSelectorView(selection: .constant("Some Notes"))
    }
    .modelContainer(previewContainer)
}
