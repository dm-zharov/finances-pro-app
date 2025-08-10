//
//  MerchantsUnavailableView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2023.
//

import SwiftUI
import AppUI

struct MerchantsUnavailableView: View {
    var body: some View {
        ContentUnavailableView {
            Label(LocalizedStringKey("No Payees"), systemImage: SymbolName.Setting.storefront.rawValue.rawValue)
        } description: {
            Text("Add transactions to manage payees.")
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MerchantsUnavailableView()
}
