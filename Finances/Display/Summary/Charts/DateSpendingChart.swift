//
//  DateSpendingChart.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10.10.2023.
//

import SwiftUI
import Charts
import CurrencyKit
import FoundationExtension
import AppUI
import AppUI

struct DateSpendingChart<Header>: View where Header: View {
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.accentStyle) private var accentStyle
    @Environment(\.dateInterval) private var dateInterval
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    @Environment(\.editMode) private var editMode
    @Environment(\.currency) private var currency
    @Environment(\.calendar) private var calendar
    
    let data: [DateAmount]
    let header: Header
    
    @State private var selection: Date?
    @State private var annotationSize: CGSize = .zero
    private let annotationSpacing: CGFloat = 16.0
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        VStack(spacing: annotationSpacing) {
            title
            chart
        }
        #if os(iOS)
        .padding(.vertical, 12.0)
        #else
        .padding(.bottom, 8.0)
        #endif
    }
    
    var title: some View {
        HStack {
            header
                .overlay {
                    GeometryReader { proxy in
                        Color.clear
                            .onChange(of: proxy.size, initial: true) {
                                annotationSize = proxy.size
                            }
                    }
                }
            Spacer()
        }
        .animation(.none, value: editMode.isEditing)
        .opacity(selection == nil ? 1.0 : 0.0)
    }
    
    private var granularity: Calendar.Component {
        if let granularity = calendar.granularity(for: dateInterval) {
            return granularity == .year ? .month : .day
        } else {
            return .year
        }
    }
    
    func bar(for element: DateAmount) -> some ChartContent {
        BarMark(
            // Create one bar for every 24 hours.
            x: .value("Date", element.date, unit: granularity),
            y: .value("Amount", element.amount.magnitude)
        )
    }
    
    func text(for amount: Decimal) -> some View {
        Text(amount.magnitude.formatted(.currency(currency).precision(.fractionLength(0...))))
    }
    
    var chart: some View {
        Chart {
            ForEach(data, id: \.date) { element in
                if let selection {
                    bar(for: element)
                        .foregroundStyle(
                            selection == element.date ? accentStyle : AnyShapeStyle(Color.ui(.placeholderText))
                        )
                } else {
                    bar(for: element)
                }
            }
            .alignsMarkStylesWithPlotArea()

            if data.count > 1, let average = .some(data.map(\.amount).average()), !redactionReasons.contains(.privacy) {
                RuleMark(
                    y: .value("Average", average.magnitude)
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [3, 5]))
                .annotation(position: .trailing, alignment: .leading, overflowResolution: .init(x: .fit(to: .chart), y: .padScale)) {
                    Text(average.magnitude.formatted(.currency(currency).rounded(rule: .up)))
                        .font(.caption2)
                        .foregroundStyle(.green)
                        .privacySensitive()
                }
            }
        }
        .chartPlotStyle { plotContent in
            plotContent
                .foregroundStyle(accentStyle)
        }
        .chartBackground { proxy in
            GeometryReader { reader in
                ZStack(alignment: .topLeading) {
                    if let selection, let element = data.first(where: { $0.date == selection }) {
                        let dateInterval = calendar.dateInterval(of: granularity, for: element.date)!
                        let centerOfDateInterval = dateInterval.start.addingTimeInterval(dateInterval.duration / 2)

                        let positionForX = proxy.position(forX: centerOfDateInterval) ?? 0
                        let linePositionForX = positionForX + reader[proxy.plotContainerFrame!].origin.x
                        let lineHeight = reader[proxy.plotContainerFrame!].size.height + annotationSize.height /* More than enought */
                        let annotationPositionForX = max(annotationSize.width / 2, min(reader.size.width - annotationSize.width / 2, linePositionForX))
                        
                        Rectangle()
                            .fill(accentStyle)
                            .frame(width: 1, height: lineHeight)
                            .position(x: linePositionForX, y: lineHeight / 2 - annotationSize.height)

                        Rectangle()
                            .fill(.clear)
                            .frame(width: annotationSize.width, height: annotationSize.height)
                            .overlay(alignment: .leading) {
                                VStack(alignment: .leading, spacing: 0.0) {
                                    Text(dateInterval.localizedDescription)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.white.opacity(0.8))
                                    AmountText(element.amount.magnitude, currencyCode: currency.identifier)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 4.0)
                                .padding(.horizontal, 8.0)
                                .background {
                                    RoundedRectangle(cornerRadius: 6.0)
                                        .fill(accentStyle)
                                }
                            }
                            .position(x: annotationPositionForX, y: reader[proxy.plotContainerFrame!].origin.y - (annotationSize.height / 2.0) - annotationSpacing)
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .delayedGesture(
                        DragGesture(minimumDistance: 0.0)
                            .onChanged { value in
                                guard let plotFrame = proxy.plotFrame else { return }

                                // Convert the gesture location to the coordinate space of the plot area.
                                let origin = geometry[plotFrame].origin
                                let location = CGPoint(
                                    x: value.location.x - origin.x,
                                    y: value.location.y - origin.y
                                )

                                // Get the value from location.
                                if !data.isEmpty, let date: Date = proxy.value(atX: location.x) {
                                    let roundedDate = calendar.startOf(granularity, for: date)!
                                    selection = data.map(\.date).nearest(for: roundedDate)
                                }
                            }
                            .onEnded { value in
                                selection = nil
                            },
                        delay: 0.1
                    )
                    .sensoryFeedback(userInterfaceIdiom == .mac ? .alignment : .selection, trigger: selection) { previous, current in
                        if userInterfaceIdiom == .mac, previous == nil {
                            return false
                        }
                        if previous != current {
                            return current != nil
                        }
                        return false
                    }
            }
        }
        .chartXScale(
            domain: {
                let granularity = calendar.granularity(for: dateInterval) ?? .year
                
                let startDate = calendar.dateInterval(of: granularity, for: dateInterval.start)!.start
                let endDate = calendar.dateInterval(of: granularity, for: dateInterval.beforeEnd!)!.beforeEnd!
                
                return startDate ... endDate
            }()
        )
        .chartXAxis {
            switch calendar.granularity(for: dateInterval) {
            case .day:
                AxisMarks(values: .stride(by: .hour, count: 4, roundUpperBound: true)) { value in
                    AxisValueLabel(format: .dateTime.hour(), centered: true, verticalSpacing: 8.0)
                }
            case .weekOfYear:
                AxisMarks(values: .stride(by: .day, count: 1, roundUpperBound: true)) { value in
                    AxisValueLabel(format: .dateTime.weekday(), centered: true, verticalSpacing: 8.0)
                }
            case .month:
                AxisMarks(values: .stride(by: .day, count: 1, roundUpperBound: true)) { value in
                    if let date = value.as(Date.self) {
                        if calendar.component(.weekday, from: date) == calendar.firstWeekday {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.day().month(), collisionResolution: .greedy, verticalSpacing: 8.0)
                        }
                    }
                }
            case .year:
                AxisMarks(values: .stride(by: .month, count: 1, roundUpperBound: true)) { value in
                    if value.index.isMultiple(of: 2) {
                        AxisValueLabel(format: .dateTime.month(), centered: true, verticalSpacing: 8.0)
                    }
                }
            default:
                AxisMarks(values: .stride(by: .year, count: 1, roundUpperBound: true)) { value in
                    AxisValueLabel(format: .dateTime.year(), centered: true, verticalSpacing: 8.0)
                }
            }
        }
        .chartYScale(
            type: .linear
        )
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                if let decimal = value.as(Decimal.self) {
                    AxisValueLabel {
                        Text(decimal.formatted(.currency(currency).rounded(rule: .up)))
                            .privacySensitive()
                    }
                    AxisGridLine()
                }
            }
        }
        .chartLegend(.hidden)
    }
    
    init(data: [DateAmount], @ViewBuilder header: @escaping () -> Header) {
        self.data = data
        self.header = header()
    }
    
    init(data: [DateAmount]) where Header == EmptyView {
        self.data = data
        self.header = EmptyView()
    }
}

#Preview {
    List {
        Section {
            DateSpendingChart(data: [])
        }
    }
}
