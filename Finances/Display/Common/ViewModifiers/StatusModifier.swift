//
//  StatusModifier.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.12.2023.
//

import SwiftUI

enum StatusPlacement {
    case automatic
    case bottomBar
}

struct StatusModifier: ViewModifier {
    let title: Text
    let placement: StatusPlacement
    let description: Text?
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 15.0, *) {
            switch placement {
            case .automatic:
                content
                    .navigationSubtitle(title)
            case .bottomBar:
                #if os(iOS)
                content
                    .toolbar {
                        ToolbarItemGroup(placement: .status) {
                            title
                                .font(.caption)
                        }
                    }
                #else
                content
                    .safeAreaInset(edge: .bottom) {
                        title
                            .font(.subheadline)
                            .padding(.vertical, 12.0)
                    }
                #endif
            }
        } else {
            content
                .toolbar {
                    ToolbarItemGroup(placement: .status) {
                        title
                            .font(.caption)
                    }
                }
        }
    }
    
    init(_ title: Text, placement: StatusPlacement, description: Text? = nil) {
        self.title = title
        self.placement = placement
        self.description = description
    }
}

extension View {
    func status(_ title: Text, placement: StatusPlacement = .automatic, description: Text? = nil) -> some View {
        modifier(
            StatusModifier(title, placement: placement, description: description)
        )
    }
}
