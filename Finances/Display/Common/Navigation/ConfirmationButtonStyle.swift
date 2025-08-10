//
//  NavigationButton.swift
//  Finances
//
//  Created by Dmitriy Zharov on 11.12.2023.
//

import SwiftUI

private struct ConfirmationButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    private var hightlightColor: Color {
        Color.white.opacity(0.2)
    }
    
    @ViewBuilder
    private func makeLabel(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.headline)
            .fontWeight(.semibold)
    }
    
    private func makeForegroundStyle(configuration: Configuration) -> Color {
        if isEnabled {
            return configuration.role == nil ? Color.white : Color.accent
        } else {
            return Color.ui(.placeholderText)
        }
    }
    
    @ViewBuilder
    private func makeBackgroundView(configuration: Configuration) -> some View {
        if configuration.role == nil {
            Rectangle()
                .fill(isEnabled ? .accent : Color.ui(.tertiarySystemFill))
                .overlay {
                    if configuration.isPressed {
                        hightlightColor
                    }
                }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        makeLabel(configuration: configuration)
            .foregroundStyle(makeForegroundStyle(configuration: configuration))
            .overlay {
                if configuration.isPressed {
                    makeLabel(configuration: configuration)
                        .foregroundStyle(hightlightColor)
                }
            }
            .padding(.all, 16.0)
            .background {
                makeBackgroundView(configuration: configuration)
            }
            .contentShape(Rectangle())
            .clipShape(RoundedRectangle(cornerRadius: 12.0))
            .animation(.none, value: configuration.isPressed)
    }
}

extension View {
    func confirmationContainer<A>(@ViewBuilder actions: () -> A) -> some View where A : View {
        #if os(iOS)
        safeAreaInset(edge: .bottom, spacing: .zero) {
            VStack(spacing: 4.0) {
                actions()
                    .buttonStyle(ConfirmationButtonStyle())
            }
            .padding(.top, 24.0)
            .padding(.horizontal, 24.0)
            .background(.bar)
        }
        #else
        toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                actions()
            }
        }
        #endif
    }
}

#Preview {
    NavigationStack {
        List {
            Text("Hello, World!")
        }
        .confirmationContainer {
            Button(String("Turn on App & Website Activity")) {
                
            }

            Button(String("Not Now"), role: .cancel) {
                
            }
        }
    }
}
