//
//  BudgetListView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 18.10.2023.
//

import SwiftUI

struct BudgetListView: View {
    var body: some View {
        List {
            Section("Month") {
                VStack {
                    HStack {
                        Text(verbatim: "Budget name")
                            .font(.headline)
                        Spacer()
                        Text(verbatim: "Budget amount 80&")
                    }
                    ProgressView(value: 20, total: 100)
                    HStack {
                        Text(verbatim: "Spent 20$")
                        Spacer()
                        Text(verbatim: "Left 80")
                    }
                }
            }
        }
    }
}

#Preview {
    BudgetListView()
}
