//
//  DateSelectorView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 07.10.2023.
//

import SwiftUI
import AppUI
import FoundationExtension
import SwiftData

private struct DateSelectorView: View {
    @Environment(\.calendar) var calendar
    @Environment(\.dismiss) var dismiss
    
    @Binding var selection: Date
    
    @State private var selectedDate: Date
    
    var body: some View {
        VStack {
            Form {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            .formStyle(.grouped)
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            #endif
        }
        .navigationTitle("Date")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Apply") {
                    save(); dismiss()
                }
            }
        }
    }
    
    @MainActor
    private func save() {
        self.selection = calendar.startOfDay(for: selectedDate)
    }
    
    init(selection: Binding<Date>) {
        self._selection = selection
        self._selectedDate = State(wrappedValue: selection.wrappedValue)
    }
}

struct DateSelectorItem: View {
    @Environment(\.dateInterval) private var dateInterval
    @Environment(\.calendar) private var calendar
    
    @Binding var selection: Date

    @State private var showDatePicker: Bool = false
    
    var today: Date {
        calendar.startOfDay(for: .now)
    }
    
    var yesterday: Date {
        calendar.date(byAdding: .day, value: -1, to: today)!
    }
    
    var body: some View {
        Menu {
            Picker(selection: $selection) {
                Label("Yesterday", systemImage: "calendar")
                    .tag(yesterday)
                
                Label("Today", systemImage: "calendar")
                    .tag(today)

                switch calendar.granularity(for: dateInterval) {
                case .day:
                    Label("Tomorrow", systemImage: "calendar")
                        .tag(calendar.dateInterval(of: .day, for: today)!.end)
                case .weekOfYear:
                    Label("Next Week", systemImage: "calendar")
                        .tag(calendar.dateInterval(of: .weekOfYear, for: today)!.end)
                case .month:
                    Label("Next Month", systemImage: "calendar")
                        .tag(calendar.dateInterval(of: .month, for: today)!.end)
                default:
                    EmptyView()
                }
            } label: {
                EmptyView()
            }

            Button("Custom", systemImage: "ellipsis.circle") {
                showDatePicker.toggle()
            }
        } label: {
            Image(systemName: SymbolName.toolbar(.calendar).rawValue)
        }
        .picker(isPresented: $showDatePicker) {
            NavigationStack {
                DateSelectorView(selection: $selection)
            }
            .tint(.accentColor)
            .frame(idealWidth: 375.0, idealHeight: 667.0)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#Preview {
    NavigationStack {
        DateSelectorView(selection: .constant(.now))
    }
    .modelContainer(previewContainer)
}

struct PickerPresentationModifier<Picker>: ViewModifier where Picker: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    let isPresented: Binding<Bool>
    let picker: () -> Picker
     
    func body(content: Content) -> some View {
        if horizontalSizeClass == .compact || userInterfaceIdiom == .mac {
            content.sheet(isPresented: isPresented, content: picker)
        } else {
            // In compact presentation environment popover shows as a sheet, but doesn't dismiss keyboard like a sheet.
            content.popover(isPresented: isPresented, content: picker)
        }
    }
}

extension View {
    func picker<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        modifier(PickerPresentationModifier<Content>(isPresented: isPresented, picker: content))
    }
}
