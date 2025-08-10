//
//  ToolbarSpacer.swift
//  Finances
//
//  Created by Dmitriy Zharov on 03.04.2024.
//

import SwiftUI

struct ToolbarSpacer: View {
    var body: some View {
        #if os(iOS)
        Button(String.empty) { }
            .hidden()
        #else
        Spacer()
        #endif
    }
}
