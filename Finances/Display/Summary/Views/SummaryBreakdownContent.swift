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
    
    private let plain: [AmountEntry<String>]
    private var grouped: [AmountEntry<String>] {
        plain.grouped(by: { element -> String in
            if let category = categories.first(where: { category in category.name == element.id }) {
                return category.group?.name ?? category.name
            } else {
                return String(localized: "Uncategorized")
            }
        }).map { group, elements in
            AmountEntry<String>(id: group, amount: elements.sum())
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
            ForEach(showGroups ? grouped.prefix(showLimit) : plain.prefix(showLimit)) { element in
                if let category = categories.first(where: { category in category.name == element.id }) {
                    #if os(iOS)
                    NavigationLink(route: .category(id: category.externalIdentifier)) {
                        SummaryItemRow(
                            element,
                            total: plain.sum(),
                            symbolName: category.symbolName ?? SymbolName.defaultValue.rawValue,
                            color: Color(colorName: ColorName(rawValue: category.colorName))
                        )
                    }
                    #else
                    SummaryItemRow(
                        element,
                        total: plain.sum(),
                        symbolName: category.symbolName ?? SymbolName.defaultValue.rawValue,
                        color: Color(colorName: ColorName(rawValue: category.colorName))
                    )
                    #endif
                } else if let categoryGroup = categoryGroups.first(where: { categoryGroup in categoryGroup.name == element.id }) {
                    #if os(iOS)
                    NavigationLink(route: .categoryGroup(id: categoryGroup.externalIdentifier)) {
                        SummaryItemRow(
                            element,
                            total: plain.sum(),
                            symbolName: "rectangle.on.rectangle.circle.fill",
                            color: Color.accentColor
                        )
                    }
                    #else
                    SummaryItemRow(
                        element,
                        total: plain.sum(),
                        symbolName: "rectangle.on.rectangle.circle.fill",
                        color: Color.accentColor
                    )
                    #endif
                } else  {
                    SummaryItemRow(
                        element,
                        total: plain.sum(),
                        symbolName: SymbolName.defaultValue.rawValue,
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
                category.group != nil && plain.contains(where: { $0.id == category.name })
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
    
    init(data: [AmountEntry<String>]) {
        self.plain = data
    }
}
