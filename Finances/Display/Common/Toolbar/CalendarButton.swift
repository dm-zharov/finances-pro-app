//
//  CalendarButton.swift
//  Finances
//
//  Created by Dmitriy Zharov on 04.10.2023.
//

import SwiftUI
import AppUI
import FoundationExtension
import SwiftData

extension DatePeriod {
    static let `default`: DatePeriod = .month
}

extension DateInterval: @retroactive DefaultValueProvidable {
    public static var defaultValue: DateInterval {
        let calendar = Calendar.current
        return calendar.dateInterval(
            of: .month, for: calendar.startOfDay(for: .now)
        ) ?? DateInterval(start: .distantPast, end: .distantFuture)
    }
}

struct CalendarButton: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.dateInterval) private var dateInterval
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selection: DateInterval
    
    @State private var startOfDay: Date = Calendar.autoupdatingCurrent.startOfDay(for: .now)
    @State private var showDateIntervalPicker: Bool = false
    
    var body: some View {
        Menu {
            Picker(selection: $selection) {
                if let dayInterval = calendar.dateInterval(of: .day, for: startOfDay) {
                    Text("Today")
                        .tag(dayInterval)
                }
                if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: startOfDay) {
                    Text("This Week")
                        .tag(weekInterval)
                }
                if let monthInterval = calendar.dateInterval(of: .month, for: startOfDay) {
                    Text("This Month")
                        .tag(monthInterval)
                }
                if let yearInterval = calendar.dateInterval(of: .year, for: startOfDay) {
                    Text("This Year")
                        .tag(yearInterval)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.inline)
            Divider()
            Button("Custom", systemImage: "ellipsis") {
                showDateIntervalPicker.toggle()
            }
        } label: {
            HStack {
                Image(systemName: "calendar.circle")
                Text(dateInterval.localizedDescription)
            }
        }
        .picker(isPresented: $showDateIntervalPicker) {
            NavigationStack {
                DateIntervalPicker(isPresented: $showDateIntervalPicker, selection: $selection, in: Transaction.dateRange(modelContext: modelContext))
                    .tint(.accentColor)
            }
            #if os(iOS)
            .frame(idealWidth: 375.0, idealHeight: 667.0)
            #else
            .preferredContentSize(minWidth: 500.0, minHeight: 420.0)
            #endif
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.significantTimeChangeNotification)) { _ in
            self.startOfDay = Calendar.current.startOfDay(for: .now); self.selection = .defaultValue
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#Preview {
    NavigationStack {
        VStack {
            
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                CalendarButton(selection: .constant(DateInterval(start: Calendar.autoupdatingCurrent.startOfDay(for: .now), duration: 0)))
            }
        }
    }
    .modelContainer(previewContainer)
}

@MainActor
extension Notification.Name {
    public static let significantTimeChangeNotification: Notification.Name = {
        #if os(iOS)
        UIApplication.significantTimeChangeNotification
        #else
        // TODO:
        // NSCalendarDayChangedNotification
        // NSSystemClockDidChangeNotification
        // NSCurrentLocaleDidChangeNotification
        return Notification.Name.NSSystemTimeZoneDidChange
        #endif
    }()
}

