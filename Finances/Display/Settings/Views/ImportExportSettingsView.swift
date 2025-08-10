//
//  ImportExportSettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.11.2023.
//

import SwiftUI
import SwiftData

struct ImportExportSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    
    @State private var showCSVImport: Bool = false
    @State private var showCSVExport: Bool = false
    
    @State private var showWipeConfirmation: Bool = false
    // To import a file, open it in any other iOS app, tap the sate button and select "Finances" in the sharing options.
    // On iPad and Mac you can imoport new files with drag and drop.
    // The following file formart are support: CSV, QIF, OFX, QFX
    
    // If you have any question, please don't hesitate to contact support.

    var body: some View {
        VStack {
            Form {
                Section("Import") {
                    Button("Import from a CSV File") {
                        showCSVImport.toggle()
                    }
                    .sheet(isPresented: $showCSVImport) {
                        NavigationStack {
                            CSVImportView {
                                showCSVImport.toggle()
                            }
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") {
                                        showCSVImport.toggle()
                                    }
                                }
                            }
                        }
                    }
                    
                    // QIF, OFX, QFX, MT940
                }

                Section("Export") {
                    Button("Export to a CSV File") {
                        showCSVExport.toggle()
                    }
                    .sheet(isPresented: $showCSVExport) {
                        NavigationStack {
                            CSVExportView {
                                showCSVExport.toggle()
                            }
                        }
                    }
                    
                    // PDF
                }
                
                Section("Storage") {
                    Button("Delete All Data", role: .destructive) {
                        showWipeConfirmation.toggle()
                    }
                    .confirmationDialog(
                        "Are you sure you want to delete all data?",
                        isPresented: $showWipeConfirmation,
                        titleVisibility: .visible,
                        actions: {
                            Button("Delete", role: .destructive) {
                                do {
                                    try VersionedSchema.Latest.models.forEach { type in
                                        try modelContext.delete(model: type)
                                    }
                                    try modelContext.save()
                                } catch {
                                    assertionFailure(error.localizedDescription)
                                }
                            }
                            Button("Cancel", role: .cancel) {
                                showWipeConfirmation.toggle()
                            }
                        }, message: {
                            Text("You cannot undo this action.")
                        }
                    )
                }
            }
            .formStyle(.grouped)
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            #endif
        }
        .navigationTitle("Import & Export")
    }
}

#Preview {
    ImportExportSettingsView()
}
