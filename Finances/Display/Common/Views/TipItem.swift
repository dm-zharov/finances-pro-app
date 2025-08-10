//
//  TipItem.swift
//  Finances
//
//  Created by Dmitriy Zharov on 23.11.2023.
//

import SwiftUI
import TipKit

struct TipItem<Content>: View where Content : Tip {
    let tip: Content
    let arrowEdge: Edge?
    let action: (Tips.Action) -> Void
    
    var body: some View {
        TipView(tip, arrowEdge: arrowEdge, action: action)
            #if os(iOS)
            .tipCornerRadius(.zero)
            .tipBackground(.clear)
            .listRowInsets(.init(top: .zero, leading: 8.0, bottom: .zero, trailing: 8.0))
            #endif
    }
    
    init(
        _ tip: Content,
        arrowEdge: Edge? = nil,
        action: @escaping (Tips.Action) -> Void = { _ in }
    ) {
        self.tip = tip
        self.arrowEdge = arrowEdge
        self.action = action
    }
}
