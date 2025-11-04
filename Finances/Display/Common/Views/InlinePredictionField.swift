//
//  InlinePredictionField.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.12.2023.
//

import SwiftUI
import OSLog
import AppUI

struct InlinePredictionField<Label> where Label: View {
    @Environment(\.customKeyboardSubmit) private var customKeyboardSubmit
    @Environment(\.clearButtonMode) private var clearButtonMode
    
    @Binding var text: String
    let prompt: String?
    let completions: [String]
    let label: () -> Label
    
    init(_ titleKey: LocalizedStringKey, text: Binding<String>, prompt: String? = nil, completions: [String]) where Label == Text {
        self._text = text
        self.prompt = prompt
        self.completions = completions
        self.label = { Text(titleKey) }
    }
    
    init(text: Binding<String>, prompt: String? = nil, completions: [String], @ViewBuilder label: @escaping () -> Label) {
        self._text = text
        self.prompt = prompt
        self.completions = completions
        self.label = label
    }
    
    #if os(iOS)
    @FocusedValue(\.fieldValue) private var focusedField
    #endif
}

#if os(iOS)
import SwiftUIIntrospect

extension InlinePredictionField: View {
    var body: some View {
        ZStack(alignment: .leadingFirstTextBaseline) {
            if focusedField == .payee {
                Text(completions.first ?? .empty)
                    .foregroundStyle(.secondary)
                    .disabled(true)
            }
            
            TextField(text: $text, prompt: prompt.map { Text($0) }) {
                label()
                    .labelStyle(.titleOnly)
            }
            .focusedValue(\.fieldValue, .payee)
            .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18, .v26)) { textField in
                textField.clearButtonMode = UITextField.ViewMode(rawValue: clearButtonMode.rawValue) ?? .never
                textField.inlinePredictionType = .no
                textField.spellCheckingType = .no
             }
            .onSubmit {
                customKeyboardSubmit?()
            }
        }
    }
}
#endif

#if os(macOS)
extension InlinePredictionField: View {
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        LabeledContent {
            ComboBox(text: $text, placeholder: prompt, completions: completions)
        } label: {
            label()
        }
    }
}

private struct ComboBox: NSViewRepresentable {
    @Environment(\.customKeyboardSubmit) private var customKeyboardSubmit
    
    let text: Binding<String>
    let placeholder: String?
    let completions: [String]
    
    func makeNSView(context: Context) -> NSComboBox {
        let nsView = NSComboBox()
        nsView.isButtonBordered = false

        nsView.usesDataSource = true
        nsView.completes = true
        nsView.dataSource = context.coordinator
        nsView.delegate = context.coordinator
        nsView.numberOfVisibleItems = 15

        return nsView
    }
    
    func updateNSView(_ nsView: NSComboBox, context: Context) {
        nsView.stringValue = text.wrappedValue
        nsView.placeholderString = placeholder
        
        let environment = context.environment
        nsView.alignment = NSTextAlignment(environment.multilineTextAlignment, environment.layoutDirection)
        nsView.font = NSFont.preferredFont(for: environment.font)
        nsView.lineBreakMode = NSLineBreakMode(environment.truncationMode)
        
        // Coordinator
        let coordinator = context.coordinator
        context.coordinator.onSubmit = context.environment.customKeyboardSubmit
        if coordinator.items != completions {
            coordinator.items = completions; nsView.reloadData()
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, NSComboBoxDataSource, NSComboBoxDelegate {
        let text: Binding<String>
        var items: [String] = []
        var onSubmit: (() -> Void)?
        
        // MARK: - NSComboBoxDataSource
        
        
        func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
            items.firstIndex(of: string) ?? NSNotFound
        }
        
        func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
            items[index]
        }
        
        func numberOfItems(in comboBox: NSComboBox) -> Int {
            items.count
        }
        
        // MARK: - NSComboBoxDelegate
        
        func comboBoxSelectionDidChange(_ notification: Notification) {
            if let control = notification.object as? NSComboBox, control.indexOfSelectedItem != -1 {
                if let editor = control.currentEditor() {
                    text.wrappedValue = items[control.indexOfSelectedItem]; control.endEditing(editor)
                }
            }
        }
        
        // MARK: - NSControlTextEditingDelegate
        
        func controlTextDidChange(_ notification: Notification) {
            if let control = notification.object as? NSControl {
                text.wrappedValue = control.stringValue
            }
        }
        
        func controlTextDidEndEditing(_ notification: Notification) {
            onSubmit?()
        }
        
        init(text: Binding<String>) {
            self.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: text)
    }
}
#endif

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return String(self.dropFirst(prefix.count))
        } else {
            return self
        }
    }
}
