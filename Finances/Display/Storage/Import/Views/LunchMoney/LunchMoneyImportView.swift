//
//  LunchMoneyImportView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 14.12.2023.
//

import SwiftUI
import AppUI

extension Text {
    enum TextStyle {
        case footer
    }
    
    func textStyle(_ style: TextStyle) -> Text {
        switch style {
        case .footer:
            self
                #if os(macOS)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                #endif
        }
    }
}

struct LunchMoneyImportView: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    let onCompletion: () -> Void
    
    var body: some View {
        Form {
            VStack(spacing: 16.0) {
                HStack {
                    Image(.lunchMoney)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80.0, height: 80.0)
                }
                .frame(maxWidth: .infinity)

                NavigationTitle(
                    "Lunch Money",
                    description: "Choose the method of import."
                )
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section {
                NavigationLink {
                    LunchMoneyAccessTokenView(onCompletion: onCompletion)
                } label: {
                    option(
                        "Use Access Token",
                        description: "Provide an access token to import your transactions, categories and assets (including balances) automatically. The token will be used for a one-time purpose and not be stored.",
                        systemName: "person.badge.key.fill"
                    )
                }
            }
            
            Section {
                NavigationLink {
                    CSVImportView(onCompletion: onCompletion)
                } label: {
                    option(
                        "Import Manually from a CSV ",
                        description: "Import all transactions manually from a CSV file. Categories and assets will be created automatically (not including balances).",
                        systemName: "square.and.arrow.down.on.square"
                    )
                }
            }
            #if os(iOS)
            .listSectionSpacing(.custom(16.0))
            #endif
        }
        .formStyle(.grouped)
    }
    
    func option(_ titleKey: LocalizedStringKey, description: LocalizedStringKey, systemName: String) -> some View {
        HStack(alignment: .center, spacing: userInterfaceIdiom != .mac ? 16.0 : 8.0) {
            Image(systemName: systemName)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44.0)
                .foregroundStyle(.accent)

            VStack(alignment: .leading) {
                Text(titleKey)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12.0)
        }
    }
}

#Preview {
    LunchMoneyImportView {
        
    }
}
