//
//  AssetsUnavailableView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 20.12.2023.
//

import SwiftUI
import AppUI

struct AssetsUnavailableView: View {
    @State private var showAccountConfigurator: Bool = false
    
    var body: some View {
        ContentUnavailableView {
            Label(LocalizedStringKey("No Assets"), systemImage: SymbolName.Setting.asset.rawValue.rawValue)
        } description: {
            Text("Add your first assets to get started.")
        } actions: {
            Button("Add Asset") {
                showAccountConfigurator.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showAccountConfigurator) {
            NavigationStack {
                AccountConfiguratorView(isPresented: $showAccountConfigurator)
            }
        }
    }
}

#Preview {
    AssetsUnavailableView()
}
