//
//  GreetingView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 27.11.2023.
//

import SwiftUI

struct GreetingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32.0) {
                Text("Welcome\u{00A0}to\nFinances")
                    .font(.default)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 44.0)
                    .padding(.bottom, 24.0)
                
                entry(
                    "Evaluate Wealth",
                    description: "Record assets to evaluate your wealth. Your data is securely protected.",
                    systemName: "text.book.closed"
                )
                
                entry(
                    "Quick Transaction Entry",
                    description: "Autocompletion and quick toolbar make transaction entry faster.",
                    systemName: "pencil.line"
                )
                
                entry(
                    "Advanced Currency Conversion",
                    description: "Review data converted to the chosen currency. Transaction date's rate applied.",
                    systemName: "dollarsign.arrow.circlepath"
                )
                
                entry(
                    "Flexible Organization",
                    description: "Set up categories to your preferences. Use tags to track transactions across categories. ",
                    systemName: "paperclip"
                )
                
                Spacer(minLength: 0)
            }
            .padding(.top, 32.0)
            .padding(.horizontal, 32.0)
        }
        .confirmationContainer {
            Button("Continue") {
                dismiss()
            }
            
            Button(String.empty) { }
                .hidden()
        }
        .preferredContentSize(width: 480, height: 540)
    }
    
    func entry(_ titleKey: LocalizedStringKey, description: LocalizedStringKey, systemName: String) -> some View {
        HStack(alignment: .center, spacing: 16.0) {
            Image(systemName: systemName)
                .resizable()
                .symbolRenderingMode(.hierarchical)
                .aspectRatio(contentMode: .fit)
                .frame(width: 36.0, height: 36.0)
                .foregroundStyle(.accent)

            VStack(alignment: .leading) {
                Text(titleKey)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    GreetingView()
}
