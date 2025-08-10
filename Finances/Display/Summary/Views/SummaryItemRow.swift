//
//  SummaryItemRow.swift
//  Finances
//
//  Created by Dmitriy Zharov on 23.02.2024.
//

import SwiftUI
import AppUI
import CurrencyKit
import OSLog
import FoundationExtension

struct SummaryItemRow<TotalValueLabel>: View where TotalValueLabel: View {
    @Environment(\.currency) private var currency
    
    let element: CategoryAmount
    let total: Decimal

    let symbolName: SymbolName
    let color: Color
    
    let totalValueLabel: TotalValueLabel
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        HStack(spacing: 12.0) {
            Image(systemName: symbolName.rawValue)
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.palette)
                .font(.title2)
                .imageScale(.large)
                .foregroundStyle(.white, color)
            
            VStack(spacing: 4.0) {
                HStack {
                    Text(element.category)
                    
                    Spacer()
                    
                    AmountText(element.amount, currencyCode: currency.identifier)
                        .font(.callout)
                }
                
                HStack(alignment: .center) {
                    ProgressView(
                        value: Double(truncating: element.amount.magnitude),
                        total: Double(truncating: total.magnitude)
                    )
                    .progressViewStyle(.linear)
                    .tint(color)
                    
                    totalValueLabel
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 54.0)
    }
    
    init(
        _ element: CategoryAmount,
        total: Decimal,
        symbolName: SymbolName,
        color: Color,
        @ViewBuilder totalValueLabel: @escaping () -> TotalValueLabel
    ) {
        self.element = element
        self.total = total
        self.symbolName = symbolName
        self.color = color
        self.totalValueLabel = totalValueLabel()
    }
    
    init(
        _ element: CategoryAmount,
        total: Decimal,
        symbolName: SymbolName,
        color: Color
    ) where TotalValueLabel == Text {
        self.element = element
        self.total = total
        self.symbolName = symbolName
        self.color = color
        self.totalValueLabel = Text((element.amount.magnitude / total.magnitude).formatted(.percent.precision(.fractionLength(0))))
    }
}

