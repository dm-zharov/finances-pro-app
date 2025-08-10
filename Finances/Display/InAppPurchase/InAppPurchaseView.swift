//
//  InAppPurchaseView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.11.2023.
//

import SwiftUI
import StoreKit

struct InAppPurchaseView: View {
    // Unlimited number of accounts
    // Shared accounts and budgets with other users, e.g. family members
    // Transaction file (great for receipts)
    // This subscription will cover iOS and macOS devices running under your iCloud account.
    // Family sharing is possible if the iOS app is used by family membrs
    
    // Restore Purchases
    
    var body: some View {
        SubscriptionStoreView(groupID: "0C6A33A6") {
            Text("Hello")
        }
        .subscriptionStorePolicyDestination(
            url: URL(string: "https://finances.zharov.dev/privacy")!,
            for: .privacyPolicy
        )
        .navigationTitle("Finances Pro")
    }
}

#Preview {
    NavigationStack {
        InAppPurchaseView()
    }
}
