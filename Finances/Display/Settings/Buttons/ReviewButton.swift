//
//  ReviewButton.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.11.2023.
//

import SwiftUI
import StoreKit

struct ReviewButton: View {
    @Environment(\.requestReview) private var requestReview
    
    var body: some View {
        Button {
            Task {
                requestReview()
            }
        } label: {
            Label {
                Text("Rate App")
            } icon: {
                SettingImage(.heart)
            }
        }
    }
}

#Preview {
    ReviewButton()
}
