//
//  CategoryGroupsUnavailable.swift
//  Finances
//
//  Created by Dmitriy Zharov on 11.04.2024.
//

import SwiftUI
import AppUI
import SwiftData

struct CategoryGroupsUnavailableView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ContentUnavailableView {
            Label(LocalizedStringKey("No Category Groups"), systemImage: "square.on.square")
        } description: {
            EmptyView()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CategoryGroupsUnavailableView()
        .modelContainer(previewContainer)
}
