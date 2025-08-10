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
        #if os(iOS)
        content
            .toolbar {
                ToolbarItemGroup(placement: .status) {
                    status
                        .font(.caption)
                }
            }
        #else
        switch placement {
        case .automatic:
            content
                .navigationSubtitle(description ?? title)
        case .bottomBar:
            content
                .safeAreaInset(edge: .bottom) {
                    status
                        .font(.subheadline)
                        .padding(.vertical, 12.0)
                }
        }
        #endif
    }
    
    var status: some View {
        VStack {
            title
            if let description = description {
                description
                    .foregroundStyle(.secondary)
            }
        }
        .imageScale(.small)
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
