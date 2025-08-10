//
//  DoneButton.swift
//  Finances
//
//  Created by Dmitriy Zharov on 19.12.2023.
//

import SwiftUI

struct DoneButton: View {
    let action: () -> Void
    
    var body: some View {
        #if os(iOS)
        Button("Done", action: action)
        #else
        Button("OK", action: action)
        #endif
    }
}

#Preview {
    DoneButton { }
}
