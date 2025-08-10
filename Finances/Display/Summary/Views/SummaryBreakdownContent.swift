//
//  SummaryBreakdownContent.swift
//  Finances
//
//  Created by Dmitriy Zharov on 23.02.2024.
//

import SwiftUI
import AppUI
import FoundationExtension
import SwiftData
import CurrencyKit

struct SummaryBreakdownContent: View {
    @Query private var categoryGroups: [CategoryGroup]
    @Query private var categories: [Category]
    
    private let plain: [CategoryAmount]
    private var grouped: [CategoryAmount] {
        plain.grouped(by: { element -> String in
            if let category = categories.first(where: { category in category.name == element.category }) {
                return category.group?.name ?? category.name
            } else {
                return String(localized: "Uncategorized")
            }
        }).map { group, elements in
            CategoryAmount(category: group, amount: elements.map(\.amount).sum())
        }.sorted(by: \.amount)
    }
    
    @State private var showGroups: Bool = false
    
    #if os(iOS)
    @State private var showLimit: Int = 7
    #else
    @State private var showLimit: Int = .max
    #endif
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        Section {
            ForEach(
                showGroups ? grouped.prefix(showLimit) : plain.prefix(showLimit), id: \.category
            ) { element in
                if let category = categories.first(where: { category in category.name == element.category }) {
                    #if os(iOS)
                    NavigationLink(route: .category(id: category.externalIdentifier)) {
                        SummaryItemRow(
                            element,
                            total: plain.map(\.amount).sum(),
                            symbolName: SymbolName(rawValue: category.symbolName),
                            color: Color(colorName: ColorName(rawValue: category.colorName))
                        )
                    }
                    #else
                    SummaryItemRow(
                        element,
                        total: plain.map(\.amount).sum(),
                        symbolName: SymbolName(rawValue: category.symbolName),
                        color: Color(colorName: ColorName(rawValue: category.colorName))
                    )
                    #endif
                } else if let categoryGroup = categoryGroups.first(where: { categoryGroup in categoryGroup.name == element.category }) {
                    #if os(iOS)
                    NavigationLink(route: .categoryGroup(id: categoryGroup.externalIdentifier)) {
                        SummaryItemRow(
                            element,
                            total: plain.map(\.amount).sum(),
                            symbolName: SymbolName(rawValue: "rectangle.on.rectangle.circle.fill"),
                            color: Color.accentColor
                        )
                    }
                    #else
                    SummaryItemRow(
                        element,
                        total: plain.map(\.amount).sum(),
                        symbolName: SymbolName(rawValue: "rectangle.on.rectangle.circle.fill"),
                        color: Color.accentColor
                    )
                    #endif
                } else  {
                    SummaryItemRow(
                        element,
                        total: plain.map(\.amount).sum(),
                        symbolName: .defaultValue,
                        color: Color(colorName: ColorName.defaultValue)
                    )
                }
            }
            if (showGroups ? grouped.count : plain.count) > showLimit {
                Button("Show More") {
                    withAnimation {
                        showLimit += 7
                    }
                }
                .frame(height: 44.0)
            }
        } header: {
            if categories.contains(where: { category in
                category.group != nil && plain.contains(where: { $0.category == category.name })
            }) {
                #if os(iOS)
                HStack {
                    Text("Breakdown")
                    Spacer()
                    Button(showGroups ? "Hide Groups" : "Show Groups") {
                        showGroups.toggle()
                    }
                    .font(.footnote)
                }
                #else
                Picker(selection: $showGroups) {
                    Text("Show Groups")
                        .tag(true)
                    
                    Text("Hide Groups")
                        .tag(false)
                } label: {
                    EmptyView()
                }
                .scaledToFit()
                .pickerStyle(.menu)
                .padding()
                #endif
            } else {
                Text("Breakdown")
            }
        }
    }
    
    init(data: [CategoryAmount]) {
        self.plain = data
    }
}
