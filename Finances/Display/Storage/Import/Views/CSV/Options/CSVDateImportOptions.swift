//
//  CSVDateImportOptions.swift
//  Finances
//
//  Created by Dmitriy Zharov on 29.11.2023.
//

import SwiftUI
import OrderedCollections

struct CSVDateImportOptions: View {
    let data: OrderedSet<String>
    @Binding var strategy: CSVParseStrategy
    
    @State private var dateOrder: DateFormatter.DateOrder?
    @State private var dateError: DateFormatter.DateFormat.GuessError?
    
    @ViewBuilder
    var body: some View {
        Section {
            if let dateError {
                LabeledContent {
                    switch dateError {
                    case .multipleChoices:
                        Text("Choose Unit Order")
                            .foregroundStyle(.red)
                    default:
                        Text("Unknown")
                            .foregroundStyle(.red)
                    }
                } label: {
                    Text("Date Format")
                }
            } else {
                LabeledContent {
                    if let transform = strategy.transform[.date], case let .date(format) = transform {
                        Text(format)
                            .foregroundStyle(.placeholder)
                    } else {
                        Text("Unknown")
                    }
                } label: {
                    Text("Date Format")
                }
            }
            
            Picker(selection: $dateOrder) {
                if dateOrder == nil {
                    Text("Unknown")
                        .tag(Optional<DateFormatter.DateOrder>.none)
                }
                ForEach(DateFormatter.DateOrder.allCases, id: \.self) { dateOrder in
                    Text(String(localized: dateOrder.localizedStringResource))
                        .tag(Optional<DateFormatter.DateOrder>.some(dateOrder))
                }
            } label: {
                Text("Unit Order")
            }
            .tint(.accent)
        } header: {
            Text("Options")
        } footer: {
            Text("Date entries are automatically converted to ISO8601 format.\nIf the conversion result is inaccurate, you can manually adjust the options.")
                .textStyle(.footer)
        }
        .onChange(of: data, initial: true) {
            guessDateOrder()
        }
        .onChange(of: dateOrder) {
            Task(priority: .high) {
                guessDateFormat()
            }
        }
    }
}

private extension CSVDateImportOptions {
    func guessDateOrder() {
        do {
            for (index, row) in data.enumerated() {
                do {
                    self.dateOrder = try DateFormatter.DateOrder.guessed(from: row)
                    return
                } catch {
                    if index < data.count - 1 {
                        continue
                    } else {
                        throw error
                    }
                }
            }
        } catch let error as DateFormatter.DateFormat.GuessError {
            self.dateError = error
        } catch {
            return
        }
    }
    
    func guessDateFormat() {
        do {
            for (index, row) in data.enumerated() {
                do {
                    let format = try DateFormatter.DateFormat.guessed(from: row, dateOrder: dateOrder)
                    self.strategy.transform[.date] = .date(format)
                    self.dateError = nil
                    return
                } catch let error as DateFormatter.DateFormat.GuessError where error == .multipleChoices {
                    if index < data.count - 1 {
                        continue
                    } else {
                        throw error
                    }
                }
            }
        } catch let error as DateFormatter.DateFormat.GuessError {
            self.strategy.transform[.date] = .date(.empty)
            self.dateError = error as DateFormatter.DateFormat.GuessError
        } catch {
            self.strategy.transform[.date] = .date(.empty)
            self.dateError = .unknownFormat
        }
    }
}

#Preview {
    CSVDateImportOptions(data: ["11-11-1996"], strategy: .constant(.init()))
}
