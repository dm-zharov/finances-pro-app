//
//  ImportProgressView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 14.12.2023.
//

import SwiftUI

struct ImportProgressView: View {
    var body: some View {
        VStack(spacing: 16.0) {
            ProgressView()
                .progressViewStyle(.circular)
            Text("Loading data...")
        }
    }
}

#Preview {
    ImportProgressView()
}
