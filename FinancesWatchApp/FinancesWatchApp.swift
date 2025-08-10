//
//  FinancesWatchApp.swift
//  FinancesWatchApp Watch App
//
//  Created by Dmitriy Zharov on 10.03.2024.
//

import SwiftUI
import CurrencyKit

@main
struct FinancesWatchApp: App {
    var body: some Scene {
        MainScene()
    }
}

extension UserDefaults {
    static let shared = UserDefaults(suiteName: Constants.AppGroup.id)!
}

extension Currency {
    func rate(
        relativeTo counter: Currency,
        on date: Date = Calendar.autoupdatingCurrent.startOfDay(for: .now, in: .gmt)
    ) -> Decimal {
        return .zero
    }
}
