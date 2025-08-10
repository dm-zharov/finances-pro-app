//
//  SummarySection.swift
//  Finances
//
//  Created by Dmitriy Zharov on 23.11.2023.
//

import SwiftUI
import SwiftData

struct SummarySection: View {
    @Environment(\.editMode) private var editMode
    
    var header: some View {
        Text("Overview")
            .listHeaderStyle(.large)
            .headerProminence(.increased)
            .listRowInsets(.init(top: 10.0, leading: 0, bottom: 8.0, trailing: 0))
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        Section {
            SummaryPreview()

            NavigationLink(route: editMode.isEditing ? nil : .summary) {
                #if os(iOS)
                Text("View Spending Summary")
                #else
                Label("View Spending Summary", systemImage: "chart.bar.xaxis")
                #endif
            }
            .selectionDisabled(editMode.isEditing)
        } header: {
            #if os(iOS)
            header
            #endif
        }
        .disabled(editMode.isEditing)
    }
}

#Preview {
    List {
        SummarySection()
    }
    .modelContainer(previewContainer)
}
