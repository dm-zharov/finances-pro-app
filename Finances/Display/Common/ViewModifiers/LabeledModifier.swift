//
//  LabeledModifier.swift
//  Finances
//
//  Created by Dmitriy Zharov on 05.01.2024.
//

import SwiftUI

#if os(iOS)
struct LabeledModifier<Item>: ViewModifier where Item: View {
    let titleKey: LocalizedStringKey

    func body(content: Content) -> some View {
        LabeledContent(titleKey) {
            content
                .multilineTextAlignment(.trailing)
        }
    }
    
    init(_ titleKey: LocalizedStringKey) {
        self.titleKey = titleKey
    }
}
#endif

extension TextField {
    func labeled(_ titleKey: LocalizedStringKey) -> some View {
        #if os(iOS)
        modifier(LabeledModifier<Self>(titleKey))
        #else
        self
        #endif
    }
}
