//
//  DoneButton.swift
//  Finances
//
//  Created by Dmitriy Zharov on 19.12.2023.
//

import SwiftUI

struct CancelButton: View {
    let action: () -> Void
    
    var body: some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            Button("Cancel", systemImage: "xmark", action: action)
        } else {
            Button("Cancel", action: action)
        }
    }
}

struct DoneButton: View {
    let action: () -> Void
    
    var body: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            Button("Done", systemImage: "checkmark", action: action)
        } else {
            Button("Done", action: action)
        }
        #else
        Button("OK", action: action)
        #endif
    }
}

#Preview {
    DoneButton { }
}
