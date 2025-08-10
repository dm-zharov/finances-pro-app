//
//  OnDidAppearModifier.swift
//  Finances
//
//  Created by Dmitriy Zharov on 31.10.2023.
//

import SwiftUI

extension Animation {
    static var imperceptible: Animation {
        Animation(ImperceptibleAnimation())
    }
}

struct ImperceptibleAnimation: CustomAnimation {
    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
        if time <= .leastNonzeroMagnitude {
            return value
        } else {
            return nil
        }
    }
}

private struct OnDidAppear: ViewModifier  {
    @State private var didAppear: Bool = false
    
    public let action: (() -> Void)?
    
    public func body(content: Content) -> some View {
        ZStack {
            if !didAppear {
                Spacer()
                    .onAppear {
                        withAnimation(.imperceptible) {
                            didAppear = true
                        }
                    }
            }
            
            content
        }
        .transaction { transaction in
            if let customAnimation = transaction.animation?.base, customAnimation is ImperceptibleAnimation {
                transaction.addAnimationCompletion(criteria: .removed) {
                    action?()
                }
            }
        }
    }
}

extension View {
    /// Adds an action to perform after this view appears.
    func onDidAppear(perform action: (() -> Void)? = nil) -> some View {
        modifier(OnDidAppear(action: action))
    }
}
