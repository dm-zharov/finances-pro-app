//
//  NavigationTitle.swift
//  Finances
//
//  Created by Dmitriy Zharov on 29.09.2023.
//

import SwiftUI
import AppUI

enum NavigationTitleStyle {
    case `default`
    case large
}

struct NavigationTitle: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    let title: LocalizedStringKey
    let description: LocalizedStringKey?
    let systemImage: String?
    
    var body: some View {
        #if os(iOS)
        VStack(alignment: .center,  spacing: 16.0) {
            if let systemImage {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80.0, height: 80.0)
            }
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
            
            if let description {
                Text(description)
                    .font(.body)
                    .fontWeight(.regular)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
        }
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        #else
        Label {
            VStack(alignment: .leading, spacing: 2.0) {
                Text(title)
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundStyle(.primary)
                
                if let description {
                    Text(description)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.ui(.secondaryLabel))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } icon: {
            if let systemImage {
                Image(systemName: systemImage)
                    .imageSize(30.0)
                    .symbolVariant(.fill)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.accent)
            }
        }
        #endif
    }
    
    init(_ title: LocalizedStringKey, description: LocalizedStringKey? = nil, systemImage: String? = nil) {
        self.title = title
        self.description = description
        self.systemImage = systemImage
    }
}

extension NavigationTitle {
    func navigationTitleStyle(_ style: NavigationTitleStyle) -> some View {
        modifier(NavigationTitleStyleModifier(style: style))
    }
}

struct NavigationTitleStyleModifier: ViewModifier {
    let style: NavigationTitleStyle
    
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .padding(.top, style == .large ? 44.0 : .zero)
            .padding(.bottom, style == .large ? 24.0 : .zero)
        #else
        content
        #endif
    }
}

#Preview {
    NavigationTitle("Title", description: "Description")
}
