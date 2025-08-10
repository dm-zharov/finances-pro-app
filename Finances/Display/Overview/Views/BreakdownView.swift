//
//  BreakdownView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 25.09.2023.
//

import SwiftUI
import SwiftData

struct BreakdownView: View {
    @Environment(\.currency) private var currency
    
    var body: some View {
        Grid(alignment: .center, horizontalSpacing: 12.0) {
            GridRow {
                container {
                    VStack {
//                        Text("Net Worth")
//                            .font(.subheadline)
//                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(Decimal(0.0).formatted(.currency(currency)))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                container {
                    VStack {
//                         Text("Est. Net Worth")
//                             .frame(maxWidth: .infinity, alignment: .leading)
                        Text(Decimal(0.0).formatted(.currency(currency)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .gridCellColumns(2)
    }
    
    private func container(_ content: () -> some View) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8.0)
                .fill(.background)
            content()
                .padding([.top, .bottom], 10.0)
                .padding([.leading, .trailing], 20.0)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
