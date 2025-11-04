//
//  TextFieldReturnModifier.swift
//  Finances
//
//  Created by Dmitriy Zharov on 31.10.2023.
//

#if os(iOS)
import SwiftUI
import SwiftUIIntrospect
#endif

#if os(iOS)
class TextFieldDelegateProxy: NSObject, UITextFieldDelegate {
    weak var source: UITextFieldDelegate?
    var target: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        for delegate in [target, source] {
            if let delegate, let textFieldDidBeginEditing = delegate.textFieldShouldBeginEditing?(textField) {
                return textFieldDidBeginEditing
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        for delegate in [target, source] {
            if let delegate, let textFieldDidBeginEditing = delegate.textFieldDidBeginEditing?(textField) {
                return textFieldDidBeginEditing
            }
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        for delegate in [target, source] {
            if let delegate, let textFieldShouldEndEditing = delegate.textFieldShouldEndEditing?(textField) {
                return textFieldShouldEndEditing
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        for delegate in [target, source] {
            if let delegate, let textFieldDidEndEditing = delegate.textFieldDidEndEditing?(textField) {
                return textFieldDidEndEditing
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        for delegate in [target, source] {
            if let delegate, let textFieldDidEndEditing = delegate.textFieldDidEndEditing?(textField) {
                return textFieldDidEndEditing
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        for delegate in [target, source] {
            if let delegate, let shouldChangeCharacters = delegate.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) {
                return shouldChangeCharacters
            }
        }
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        for delegate in [target, source] {
            if let delegate, let textFieldDidChangeSelection = delegate.textFieldDidChangeSelection?(textField) {
                return textFieldDidChangeSelection
            }
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        for delegate in [target, source] {
            if let delegate, let textFieldShouldClear = delegate.textFieldShouldClear?(textField) {
                return textFieldShouldClear
            }
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        for delegate in [target, source] {
            if let delegate, let textFieldShouldReturn = delegate.textFieldShouldReturn?(textField) {
                return textFieldShouldReturn
            }
        }
        return true
    }

    func textField(_ textField: UITextField, editMenuForCharactersIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        for delegate in [target, source] {
            if let delegate, let editMenuForCharacters = delegate.textField?(textField, editMenuForCharactersIn: range, suggestedActions: suggestedActions) {
                return editMenuForCharacters
            }
        }
        return nil
    }

    func textField(_ textField: UITextField, willPresentEditMenuWith animator: UIEditMenuInteractionAnimating) {
        for delegate in [target, source] {
            if let delegate, let willPresentEditMenu = delegate.textField?(textField, willPresentEditMenuWith: animator) {
                return willPresentEditMenu
            }
        }
    }

    func textField(_ textField: UITextField, willDismissEditMenuWith animator: UIEditMenuInteractionAnimating) {
        for delegate in [target, source] {
            if let delegate, let willDismissEditMenu = delegate.textField?(textField, willDismissEditMenuWith: animator) {
                return willDismissEditMenu
            }
        }
    }
    
    init(target: UITextFieldDelegate) {
        self.target = target
    }
}

private struct TextFieldReturnModifier: ViewModifier {
    @Environment(\.customKeyboardSubmit) var customKeyboardSubmit
    
    @State private var proxy = TextFieldDelegateProxy(
        target: CustomReturnActionTextFieldDelegate()
    )
    
    public func body(content: Content) -> some View {
        content
            .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18, .v26)) { textField in
                if let _ = proxy.source {
                    textField.delegate = proxy
                } else {
                    proxy.source = textField.delegate
                }
                if let target = proxy.target as? CustomReturnActionTextFieldDelegate {
                    target.onReturn = customKeyboardSubmit ?? { }
                }
            }
    }
}

class CustomReturnActionTextFieldDelegate: NSObject, UITextFieldDelegate {
    var onReturn: () -> Void = { }
    
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        onReturn(); return true
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn(); return false
    }
}

extension View {
    func customReturn() -> some View {
        modifier(TextFieldReturnModifier())
    }
}
#endif
