//
//  EnvironmentValues+EditMode.swift
//  Finances
//
//  Created by Dmitriy Zharov on 11.10.2023.
//

#if os(macOS)
import SwiftUI

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
enum EditMode {
    case active
    case inactive
    case transient
    
    public var isEditing: Bool {
        self != .inactive
    }
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
struct EditModeKey: EnvironmentKey {
    static let defaultValue: Binding<EditMode>? = .constant(.inactive)
}

extension EnvironmentValues {
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    var editMode: Binding<EditMode>? {
        get { self[EditModeKey.self] }
        set { self[EditModeKey.self] = newValue }
        
    }
}
#endif
