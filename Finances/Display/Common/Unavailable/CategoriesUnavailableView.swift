//
//  CategoriesUnavailableView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.11.2023.
//

import SwiftUI
import AppUI
import SwiftData

struct CategoriesUnavailableView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        ContentUnavailableView {
            Label(LocalizedStringKey("No Categories"), systemImage: SymbolName.Setting.paperclip.rawValue.rawValue)
        } description: {
            Text("Set up your first categories to get started.")
        } actions: {
            Button("Generate categories") {
                generate()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func generate() {
        for category in [
            Category(name: String(localized: "Salary"), symbolName: .category(.arrowDown), colorName: .green, isIncome: true),
            Category(name: String(localized: "Transfer"), symbolName: .category(.arrowLeftRight), colorName: .brown, isTransient: true),
            Category(name: String(localized: "Transport"), symbolName: .category(.car), colorName: .gray),
            Category(name: String(localized: "House"), symbolName: .category(.house), colorName: .mint),
            Category(name: String(localized: "Cafe, Restaurants"), symbolName: .category(.forkKnife), colorName: .cyan),
            Category(name: String(localized: "Groceries"), symbolName: .category(.bag), colorName: .blue),
            Category(name: String(localized: "Health"), symbolName: .category(.cross), colorName: .red),
            Category(name: String(localized: "Clothes"), symbolName: .category(.tshirt), colorName: .yellow),
            Category(name: String(localized: "Entertainment"), symbolName: .category(.play), colorName: .purple),
            Category(name: String(localized: "Journey"), symbolName: .category(.airplane), colorName: .teal),
            Category(name: String(localized: "Cellular"), symbolName: .category(.antenna), colorName: .orange),
            Category(name: String(localized: "Gifts"), symbolName: .category(.gift), colorName: .pink)
        ] {
            modelContext.insert(category)
        }
    }
}

#Preview {
    CategoriesUnavailableView()
        .modelContainer(previewContainer)
}
