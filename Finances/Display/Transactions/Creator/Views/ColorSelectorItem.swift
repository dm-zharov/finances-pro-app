//
//  ColorSelectorItem.swift
//  Finances
//
//  Created by Dmitriy Zharov on 22.11.2023.
//

import SwiftUI
import AppUI

struct ColorSelectorItem: View {
    @Environment(\.self) private var environment
    
    @Binding var selection: ColorName
    
    @State private var color: CGColor = .init(gray: 0.0, alpha: 0.0)
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack(spacing: 0.0) {
            ColorPicker(String.empty, selection: $color, supportsOpacity: false)
                .labelsHidden()
        }
        .onChange(of: color) { oldValue, newValue in
            if oldValue != newValue {
                selection = ColorName.hex(newValue.hexString) ?? .defaultValue
            }
        }
    }
}

#Preview {
    ColorSelectorItem(selection: .constant(.defaultValue))
}
