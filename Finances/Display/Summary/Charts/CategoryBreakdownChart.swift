//
//  CategoryBreakdownChart.swift
//  Finances
//
//  Created by Dmitriy Zharov on 02.10.2023.
//

import SwiftUI
import Charts
import FoundationExtension
import CurrencyKit
import AppUI

struct CategoryBreakdownChart: View {
    @Environment(\.currency) private var currency
    @Environment(\.dateInterval) private var dateInterval
    @Environment(\.calendar) private var calendar
    
    let data: [AmountEntry<String>]
    let colors: [String: Color]

    var body: some View {
        VStack {
            HStack {
                if let beforeEnd = dateInterval.beforeEnd {
                    if calendar.isDate(dateInterval.start, equalTo: beforeEnd, toGranularity: .day) {
                        // 30 Oct 2023
                        Text(verbatim: "\(dateInterval.start.formatted(.dateTime.day().month().year()))")
                    } else if calendar.isDate(dateInterval.start, equalTo: beforeEnd, toGranularity: .year) {
                        // 30 Oct - 15 Nov 2023
                        Text(verbatim: "\(dateInterval.start.formatted(.dateTime.day().month())) - \(beforeEnd.formatted(.dateTime.day().month(.abbreviated).year()))")
                    } else {
                        // 25 Dec 2023 - 5 Jan 2024
                        Text(verbatim: "\(dateInterval.start.formatted(.dateTime.day().month().year())) - \(beforeEnd.formatted(.dateTime.day().month().year()))")
                    }
                }
                Spacer()
                AmountText(data.map(\.amount).sum().magnitude, currencyCode: currency.identifier)
                    .foregroundColor(.secondary)
            }
            chart
        }
        .padding([.top, .bottom], 4.0)
    }

    private var chart: some View {
        Chart(data, id: \.name) { element in
            Plot {
                BarMark(
                    x: .value("Category Amount", element.amount.magnitude)
                )
                .foregroundStyle(by: .value("Category Name", element.name))
            }
        }
        .chartForegroundStyleScale(mapping: color(for:))
        .chartPlotStyle { plotArea in
            plotArea
#if os(macOS)
                .background(Color.gray.opacity(0.2))
#else
                .background(Color(.systemFill))
#endif
                .cornerRadius(8)
                .frame(height: 32.0)
        }
        .chartXAxis(.hidden)
        .chartLegend(spacing: 8.0) {
            OverflowStack(spacing: 8.0) {
                ForEach(data.prefix(5)) { element in
                    legend(for: element.name)
                }
                if data.count > 5 {
                    legend(for: String(localized: "Others"))
                }
            }
        }
        .chartLegend(.visible)
    }
    
    func legend(for category: String) -> some View {
        HStack(alignment: .center, spacing: 4.0) {
            Circle()
                .fill(color(for: category))
                .frame(width: 8.0, height: 8.0)
            
            Text(category)
                .font(.caption)
                .foregroundStyle(Color.ui(.label))
        }
    }
    
    func color(for category: String) -> Color {
        return colors[category] ?? .gray
    }
    
    init(data: [AmountEntry<String>], colors: [String : Color]) {
        self.data = data.isEmpty ? [.unavailable] : data
        self.colors = colors
    }
}

#Preview {
    List {
        Section {
            CategoryBreakdownChart(data: [], colors: [:])
        }
    }
}
