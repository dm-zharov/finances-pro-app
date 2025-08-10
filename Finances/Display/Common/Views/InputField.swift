//
//  InputField.swift
//  Finances
//
//  Created by Dmitriy Zharov on 30.10.2023.
//

#if os(iOS)
import AppUI
import SwiftUI

struct InputField: UIViewRepresentable {
    let title: String
    let text: Binding<String>
    
    // MARK: - View
    
    func makeUIView(context: Context) -> UITextField {
        let uiView = UITextField()
        uiView.delegate = context.coordinator
        uiView.placeholder = title
        uiView.text = text.wrappedValue
        uiView.backgroundColor = nil
        return uiView
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.autocorrectionType = context.environment.autocorrectionDisabled ? .no : .yes
        uiView.font = UIFont.preferredFont(for: context.environment.font, compatibleWith: context.environment.dynamicTypeSize)
        if let paragraphStyle = (uiView.defaultTextAttributes[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle {
            paragraphStyle.alignment = NSTextAlignment(context.environment.multilineTextAlignment, context.environment.layoutDirection)
            paragraphStyle.lineBreakMode = NSLineBreakMode(context.environment.truncationMode)
            paragraphStyle.lineSpacing = context.environment.lineSpacing
            uiView.defaultTextAttributes[.paragraphStyle] = paragraphStyle
        }
        context.coordinator.onReturn = context.environment.customKeyboardSubmit
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextField, context: Context) -> CGSize? {
        if let width = proposal.width, let height = proposal.height {
            return CGSize(
                width: width,
                height: uiView.sizeThatFits(.init(width: width, height: height)).height
            )
        } else {
            return uiView.intrinsicContentSize
        }
    }
    
    // MARK: - Coordinator
    
    func makeCoordinator() -> InputFieldCoordinator {
        InputFieldCoordinator(text: text)
    }
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self.text = text
    }
}

class InputFieldCoordinator: NSObject, UITextFieldDelegate {
    @Binding var text: String
    var onReturn: (() -> Void)?
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard
            let text = textField.text,
            let range = Range(range, in: text)
        else {
            return true
        }
        
        self.text = text.replacingCharacters(in: range, with: string)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let onReturn {
            onReturn(); return false
        } else {
            return true
        }
    }
    
    init(text: Binding<String>) {
        _text = text
    }
}

#Preview {
    List {
        HStack {
            TextField(String("Hello"), text: .constant("HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello"))
                .border(.red)
                .multilineTextAlignment(.trailing)
                .truncationMode(.middle)
        }
        HStack {
            InputField(String("Hello"), text: .constant("HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello"))
                .border(.blue)
                .multilineTextAlignment(.trailing)
                .truncationMode(.middle)
        }
    }
}
#endif
