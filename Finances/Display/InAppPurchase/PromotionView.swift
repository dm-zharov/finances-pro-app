//
//  PromotionView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 16.04.2024.
//

import SwiftUI
import SwiftData

struct PromotionView: View {
    var body: some View {
        VStack {
            Text("Finances Pro")
                .foregroundStyle(.accent)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(isPresented: .constant(true))
    }
    .modelContainer(previewContainer)
}
