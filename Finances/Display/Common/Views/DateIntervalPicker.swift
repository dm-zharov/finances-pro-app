//
//  DateIntervalPicker.swift
//  Finances
//
//  Created by Dmitriy Zharov on 13.10.2023.
//

import SwiftUI
import AppUI

struct DateIntervalPicker: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    @Environment(\.calendar) private var calendar
    
    @Binding var isPresented: Bool
    @Binding var selection: DateInterval
    let range: ClosedRange<Date>
    
    @State private var dateInterval: DateInterval = .defaultValue
    @State private var datePeriod: DatePeriod? = nil
    @State private var isFromDateFocused: Bool = true
    @State private var isToDateFocused: Bool = false
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        Form {
            Section {
                Picker("Date Interval", selection: $datePeriod) {
                    Text("Free")
                        .tag(Optional<DatePeriod>.none)

                    ForEach(DatePeriod.allCases, id: \.self) { datePeriod in
                        Text(String(localized: datePeriod.localizedStringResource))
                            .tag(Optional<DatePeriod>.some(datePeriod))
                    }
                }
                .onChange(of: datePeriod) {
                    if let datePeriod {
                        self.dateInterval = calendar.dateInterval(of: datePeriod, for: dateInterval.start) ?? .defaultValue
                    }
                }
            }
            
            switch datePeriod {
            case .none:
                free
            case .day:
                day
            case .week:
                week
            case .month:
                month
            case .year:
                year
            }
        }
        .formStyle(.grouped)
        #if os(iOS)
        .contentMargins(.top, .compact, for: .scrollContent)
        .listSectionSpacing(.compact)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented.toggle()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Apply") {
                    selection = dateInterval; isPresented.toggle()
                }
            }
        }
        .onAppear {
            dateInterval = selection
            datePeriod = calendar.datePeriod(of: selection)
        }
    }
    
    @ViewBuilder
    private var free: some View {
        #if os(iOS)
        LabeledContent {
            Button(DateFormatter.relative.string(from: dateInterval.start)) {
                isFromDateFocused.toggle(); isToDateFocused = false
            }
            .buttonStyle(.bordered)
            .foregroundStyle(isFromDateFocused ? .accent : .primary)
        } label: {
            Text("Date.From")
        }
        .listRowSeparator(isFromDateFocused ? .hidden : .automatic)
        #endif

        if isFromDateFocused || userInterfaceIdiom == .mac {
            DatePicker(
                selection: Binding<Date>(
                    get: { dateInterval.start },
                    set: { startOfDay in
                        if startOfDay < dateInterval.end {
                            self.dateInterval = DateInterval(start: startOfDay, end: dateInterval.end)
                        } else if let dateInterval = calendar.dateInterval(of: .day, for: startOfDay) {
                            self.dateInterval = dateInterval
                        }
                    }
                ),
                in: range,
                displayedComponents: .date
            ) {
                Text("Date.From")
            }
            #if os(iOS)
            .datePickerStyle(.graphical)
            #endif
        }

        if let beforeEnd = dateInterval.beforeEnd {
            #if os(iOS)
            LabeledContent {
                Button(DateFormatter.relative.string(from: beforeEnd)) {
                    isToDateFocused.toggle(); isFromDateFocused = false
                }
                .buttonStyle(.bordered)
                .foregroundStyle(isToDateFocused ? .accent : .primary)
            } label: {
                Text("Date.To")
            }
            .listRowSeparator(isToDateFocused ? .hidden : .automatic)
            #endif
            
            if isToDateFocused || userInterfaceIdiom == .mac {
                DatePicker("Date.To",
                    selection: Binding<Date>(
                        get: { beforeEnd },
                        set: { endDate in
                            if endDate > dateInterval.start {
                                self.dateInterval = DateInterval(start: dateInterval.start, end: endDate)
                            } else if let dateInterval = calendar.dateInterval(of: .day, for: endDate) {
                                self.dateInterval = dateInterval
                            }
                        }
                    ),
                    in: dateInterval.start ... range.upperBound,
                    displayedComponents: .date
                )
                #if os(iOS)
                .datePickerStyle(.graphical)
                #endif
            }
        }
    }
    
    private var day: some View {
        DatePicker("Day",
            selection: Binding<Date>(get: { dateInterval.start }, set: { newValue in
                if let dateInterval = calendar.dateInterval(of: .day, for: newValue) {
                    self.dateInterval = dateInterval
                }
            }),
            in: range,
            displayedComponents: .date
        )
        #if os(iOS)
        .datePickerStyle(.graphical)
        #endif
    }
    
    @ViewBuilder
    private var week: some View {
        // From
        
        #if os(iOS)
        LabeledContent {
            Button(DateFormatter.relative.string(from: dateInterval.start)) {
                isFromDateFocused.toggle(); isToDateFocused = false
            }
            .buttonStyle(.bordered)
            .foregroundStyle(isFromDateFocused ? .accent : .primary)
        } label: {
            Text("Date.From")
        }
        .listRowSeparator(isFromDateFocused ? .hidden : .automatic)
        #endif
        
        if isFromDateFocused || userInterfaceIdiom == .mac {
            DatePicker(
                selection: Binding<Date>(
                    get: { dateInterval.start },
                    set: { startOfWeek in
                        if let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) {
                            self.dateInterval = DateInterval(start: startOfWeek, end: endOfWeek)
                        }
                    }
                ),
                in: range,
                displayedComponents: .date
            ) {
                Text("Date.From")
            }
            #if os(iOS)
            .datePickerStyle(.graphical)
            #endif
        }
        
        // To
        
        if let beforeEnd = dateInterval.beforeEnd {
            #if os(iOS)
            LabeledContent {
                Button(DateFormatter.relative.string(from: beforeEnd)) {
                    isToDateFocused.toggle(); isFromDateFocused = false
                }
                .buttonStyle(.bordered)
                .foregroundStyle(isToDateFocused ? .accent : .primary)
            } label: {
                Text("Date.To")
            }
            .listRowSeparator(isToDateFocused ? .hidden : .automatic)
            #endif
            
            if isToDateFocused || userInterfaceIdiom == .mac {
                DatePicker("Date.To",
                    selection: Binding<Date>(
                        get: { beforeEnd },
                        set: { endDate in
                            let startOfDay = calendar.startOfDay(for: endDate)
                            if let endOfWeek = calendar.date(byAdding: .day, value: 1, to: startOfDay),
                               let startOfWeek = calendar.date(byAdding: .day, value: -7, to: endOfWeek) {
                                self.dateInterval = DateInterval(start: startOfWeek, end: endOfWeek)
                            }
                        }
                    ),
                    in: range,
                    displayedComponents: .date
                )
                #if os(iOS)
                .datePickerStyle(.graphical)
                #endif
            }
        }
    }
    
    @ViewBuilder
    private var month: some View {
        Picker(
            selection: Binding<Int?>(
                get: {
                    if calendar.datePeriod(of: dateInterval) == .month {
                        return calendar.component(.month, from: dateInterval.start)
                    } else {
                        return nil
                    }
                },
                set: { month in
                    if let startOfMonth = calendar.date(
                        from: DateComponents(year: calendar.component(.year, from: dateInterval.start), month: month)
                    ), let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) {
                        self.dateInterval = DateInterval(start: startOfMonth, end: endOfMonth)
                    }
                }
            )
        ) {
            ForEach(0..<12, id: \.self) { month in
                Text(calendar.standaloneMonthSymbols[month].localizedCapitalized)
                    .tag(Optional<Int>.some(month + 1))
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.inline)
        
        Picker(
            "Year",
            selection: Binding<Int>(
                get: { calendar.component(.year, from: dateInterval.start) },
                set: { newValue in
                    let year = calendar.component(.year, from: dateInterval.start)
                    if let startDate = calendar.date(byAdding: .year, value: newValue - year, to: dateInterval.start),
                       let endDate = calendar.date(byAdding: .year, value: newValue - year, to: dateInterval.end) {
                        self.dateInterval = DateInterval(start: startDate, end: endDate)
                    }
                }
            )
        ) {
            ForEach(calendar.component(.year, from: range.lowerBound) ... max(
                calendar.component(.year, from: range.upperBound), calendar.component(.year, from: .now)
            ), id: \.self) { year in
                Text(String(year))
                    .tag(year)
            }
        }
        .pickerStyle(.menu)
    }
    
    private var year: some View {
        Picker(
            selection: Binding<Int?>(
                get: {
                    if calendar.datePeriod(of: dateInterval) == .year {
                        return calendar.component(.year, from: dateInterval.start)
                    } else {
                        return nil
                    }
                },
                set: { year in
                    if let startOfYear = calendar.date(from: DateComponents(year: year)),
                       let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear) {
                        self.dateInterval = DateInterval(start: startOfYear, end: endOfYear)
                    }
                }
            )
        ) {
            ForEach(calendar.component(.year, from: range.lowerBound) ... max(
                calendar.component(.year, from: range.upperBound), calendar.component(.year, from: .now)
            ), id: \.self) { year in
                Text(String(year))
                    .tag(Optional<Int>.some(year))
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.inline)
    }
    
    init(isPresented: Binding<Bool>, selection: Binding<DateInterval>, in range: ClosedRange<Date>) {
        self._isPresented = isPresented
        self._selection = selection
        self.range = range
    }
}
