//
//  ReportIssueView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 15.04.2024.
//

import SwiftUI

struct ReportIssueView: View {
    @State var message: String = .empty
    
    var body: some View {
        VStack {
            List {
                Section {
                    VStack(spacing: 8.0) {
                        Text("Help improve the Finances app by sharing your feedback.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("This information is not associated with your Apple ID.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.leading)
                }
                .listRowInsets(.zero)
                .listRowBackground(Color.clear)
                
                Section("Message") {
                    TextField("Report", text: $message, prompt: Text("Freeform Text"))
                }
            }
            .headerProminence(.increased)
        }
        .navigationTitle("Report an Issue")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Submit") {
                    
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ReportIssueView()
    }
}
