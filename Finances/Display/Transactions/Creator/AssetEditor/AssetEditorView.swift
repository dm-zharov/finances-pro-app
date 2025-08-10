//
//  AssetEditorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 29.09.2023.
//

import SwiftUI
import SwiftData

struct AssetEditorView: View {
    enum Field: Hashable {
        case name
        case balance
        case institutionName
    }
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.isPresented) var isPresented
    @Environment(\.isFinished) var isFinished
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Data

    let asset: Asset?
    
    // MARK: - Editing

    @State private var representation: AssetRepresentation

    @FocusState private var focusedField: Field?
    @State private var isReady: Bool = true
    
    private var editorTitle: String {
        if let _ = asset {
            return String(localized: "Edit Asset")
        } else {
            return [
                String(localized: "Add"),
                String(localized: representation.type.localizedStringResource)
            ].joined(separator: " ")
        }
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack {
            Form {
                if asset != nil {
                    Picker(selection: $representation.type) {
                        ForEach(AssetType.allCases, id: \.self) { assetType in
                            Label(String(localized: assetType.localizedStringResource), systemImage: assetType.symbolName)
                        }
                    } label: {
                        Text("Kind")
                    }
                }
                
                Section {
                    if representation.type != .cash {
                        TextField("Display Name", text: $representation.name, prompt: Text("Name"))
                            .labeled("Display Name")
                            .focused($focusedField, equals: .name)
                            .onSubmit {
                                focusedField = .balance
                            }
                    }
                    
                    AmountField(
                        representation.type == .cash ? "Amount" : "Balance",
                        value: $representation.balance,
                        currency: representation.currency,
                        onReady: { isReady in
                            self.isReady = isReady
                        },
                        onSubmit: {
                            focusedField = nil
                        }
                    )
                    .labeled(representation.type == .cash ? "Amount" : "Balance")
                    .focused($focusedField, equals: .balance)
                    
                    #if os(iOS)
                    NavigationLink {
                        CurrencySelectorView(selection: $representation.currency, suggestions: [])
                    } label: {
                        LabeledContent {
                            Text(representation.currency.localizedDescription)
                        } label: {
                            Text("Currency")
                        }
                    }
                    #else
                    LabeledContent {
                        CurrencySelectorItem(selection: $representation.currency)
                    } label: {
                        Text("Currency")
                    }
                    #endif
                }
                
                if representation.type == .cash {
                    Section {
                        TextField("Display Name", text: $representation.name, prompt: Text(representation.currency.localizedDescription))
                            .labeled("Display Name")
                            .focused($focusedField, equals: .name)
                    } header: {
                        Text("Optional")
                    }
                }
            }
            .formStyle(.grouped)
            .scrollDismissesKeyboard(.immediately)
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            #endif
            .headerProminence(.standard)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationTitle(editorTitle)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if let _ = asset {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                DoneButton {
                    withAnimation {
                        save()
                        if let isFinished {
                            isFinished.wrappedValue = true
                        } else {
                            dismiss()
                        }
                    }
                }
                .disabled(!isReady || !representation.validate())
            }
            ToolbarItem(placement: .status) {
                Spacer()
            }
        }
        .interactiveDismissDisabled(focusedField != nil)
        .preferredContentSize(minWidth: 500.0, minHeight: 420.0)
    }
    
    init(_ asset: Asset? = nil) {
        self.asset = asset
        self.representation = asset?.objectRepresentation ?? AssetRepresentation()
    }
    
    /* convenience */ init(assetType: AssetType) {
        self.asset = nil
        self.representation = AssetRepresentation(type: assetType)
    }
}

// MARK: - Operation

extension AssetEditorView {
    @MainActor
    private func save() {
        let asset = asset ?? {
            let asset = Asset()
            modelContext.insert(asset)
            return asset
        }()
        
        if representation.type == .cash, representation.name.isEmpty {
            representation.name = representation.currency.localizedDescription
        }
        
        asset.objectRepresentation = representation
        
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
    }
}

#Preview {
    NavigationStack {
        AssetEditorView()
    }
    .modelContainer(previewContainer)
}
