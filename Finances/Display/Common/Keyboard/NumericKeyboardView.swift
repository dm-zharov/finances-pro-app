//
//  NumericKeyboardView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 05.10.2023.
//

#if os(iOS)
import SwiftUI
import KeyboardKit
import FoundationExtension
import AppUI

enum KeyType: Hashable {
    case number(String)
    case separator(String)
    case delete
    case `return`
    case `operator`(Operator)
}

enum KeyStyle: Hashable {
    case key
    case modifier
    case toolbar
}

struct ReturnKey: View {
    @Environment(\.customKeyboardState) private var state
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack(spacing: .zero) {
            VStack(spacing: .zero) {
                Color.clear
            }
            VStack(spacing: .zero) {
                Spacer()
                switch state.submitLabel {
                case .return:
                    Image(systemName: "return")
                case .equal:
                    Image(systemName: "equal")
                }
                Spacer()
            }
        }
    }
}

struct KeyboardKey: View {
    @Environment(\.customKeyboardState) var state
    @Environment(\.customKeyboardSubmit) var customKeyboardSubmit
    @Environment(\.keyboardInput) var keyboardInput
    @Environment(\.colorScheme) var colorScheme
    
    let type: KeyType
    let style: KeyStyle
    
    @GestureState private var isHighlighted = false
    
    var body: some View {
        VStack {
            switch type {
            case let .operator(value):
                switch value {
                case .add:
                    Image(systemName: "plus")
                case .subtract:
                    Image(systemName: "minus")
                case .multiply:
                    Image(systemName: "multiply")
                case .divide:
                    Image(systemName: "divide")
                case .inverse:
                    Image(systemName: "plus.forwardslash.minus")
                }
            case let .number(character):
                switch character {
                case "0":
                    HStack(spacing: .zero) {
                        HStack(spacing: .zero) {
                            Spacer()
                            Text(character)
                            Spacer()
                        }
                        HStack(spacing: .zero) {
                            Color.clear
                        }
                    }
                default:
                    Text(character)
                }
            case let .separator(character):
                Text(character)
            case .delete:
                Image(systemName: "delete.backward")
            case .return:
                ReturnKey()
            }
        }
        .font(style == .key ? .system(size: 25.0) : .system(size: 17.0))
        .symbolVariant(isHighlighted ? .fill : .none)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background {
            RoundedRectangle(cornerRadius: 6.0, style: .continuous)
                .fill(Color.keyboard(style: style, isHighlighted: isHighlighted, isSelected: isSelected))
                .highPriorityGesture(longPress)
                .background {
                    RoundedRectangle(cornerRadius: 6.0, style: .continuous)
                        .fill(Color.ui(.systemKeyboardKeyShadow))
                }
        }
    }
    
    var longPress: some Gesture {
        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
            .updating($isHighlighted) { currentState, gestureState, transaction in
                if gestureState == false {
                    select(); keyboardInput.click()
                }
                gestureState = true
            }
            .onEnded { finished in
                handleTap()
            }
        
    }
    
    func handleTap() {
        switch type {
        case let .number(character), let .separator(character):
            keyboardInput(character)
        case let .operator(value):
            keyboardInput(value.rawValue)
        case .delete:
            keyboardInput.delete()
        case .return:
            if let customKeyboardSubmit {
                customKeyboardSubmit()
            } else {
                keyboardInput.return(); keyboardInput.dismiss()
            }
        }
    }
    
    init(_ type: KeyType, style: KeyStyle = .key) {
        self.type = type
        self.style = style
    }
}

extension KeyboardKey {
    var isSelected: Bool {
        get {
            switch type {
            case .operator(.inverse):
                return !state.isInverse
            default:
                return false
            }
        }
    }
    
    func select() {
        switch type {
        case .operator(.inverse):
            return state.isInverse.toggle()
        default:
            break
        }
    }
}

struct NumericKeyboardView: View {
    @Environment(\.keyboardInput) var keyboardInput
    @Environment(\.locale) var locale
    @Environment(\.colorScheme) var colorScheme
    
    let spacing: CGFloat = 6.0
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        HStack(spacing: spacing) {
            VStack(spacing: spacing) {
                KeyboardKey(.operator(.divide), style: .toolbar)
                KeyboardKey(.operator(.multiply), style: .toolbar)
                KeyboardKey(.operator(.subtract), style: .toolbar)
                KeyboardKey(.operator(.add), style: .toolbar)
            }
            .frame(width: 60.0)
            
            GeometryReader { proxy in
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        KeyboardKey(.number("7"))
                        KeyboardKey(.number("8"))
                        KeyboardKey(.number("9"))
                    }
                    HStack(spacing: spacing) {
                        KeyboardKey(.number("4"))
                        KeyboardKey(.number("5"))
                        KeyboardKey(.number("6"))
                    }
                    HStack(spacing: spacing) {
                        KeyboardKey(.number("1"))
                        KeyboardKey(.number("2"))
                        KeyboardKey(.number("3"))
                    }
                    HStack(spacing: spacing) {
                        KeyboardKey(.number("0"))
                            .frame(width: proxy.size.width / 3 * 2 - 2.0)
                        KeyboardKey(.separator(locale.decimalSeparator ?? "."))
                    }
                }
            }
            
            VStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    KeyboardKey(.delete, style: .modifier)
                    KeyboardKey(.operator(.inverse), style: .modifier)
                }
                VStack(spacing: spacing) {
                    KeyboardKey(.return, style: .modifier)
                }
            }
            .frame(width: 60.0)
        }
        .padding(.top, 8.0)
        .padding(.horizontal, 4.0)
        .padding(.bottom, 45.0)
    }
}

#Preview {
    VStack {
        NumericKeyboardView()
            .background(Color.ui(UIColor(red: 208 / 255, green: 211 / 255, blue: 217 / 255, alpha: 1.0)))
    }
    .frame(height: 375.0)
}

extension UITextDocumentProxy {
    var documentContext: String? {
        if let documentContextBeforeInput {
            if let documentContextAfterInput {
                return documentContextBeforeInput + documentContextAfterInput
            } else {
                return documentContextBeforeInput
            }
        } else {
            if let documentContextAfterInput {
                return documentContextAfterInput
            } else {
                return nil
            }
        }
    }
}
#endif
