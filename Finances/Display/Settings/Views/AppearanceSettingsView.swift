//
//  AppearanceSettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.11.2023.
//

import SwiftUI
import AppUI
import FoundationExtension
import FinancesCore

extension ColorScheme: RawRepresentable {
    public var rawValue: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        @unknown default:
            return "unspecified"
        }
    }
    
    public init?(rawValue: String) {
        switch rawValue {
        case "light":
            self = .light
        case "dark":
            self = .dark
        default:
            return nil
        }
    }
}

struct AppearanceSettingsView: View {
    @AppStorage(SettingKey.preferredColorScheme, store: .shared) private var preferredColorScheme: ColorScheme?
    
    var body: some View {
        VStack {
            List {
                Picker(selection: $preferredColorScheme) {
                    Text("System", comment: "Appearance")
                        .tag(Optional<ColorScheme>.none)
                    Text("Light", comment: "Appearance")
                        .tag(Optional<ColorScheme>.some(.light))
                    Text("Dark", comment: "Appearance")
                        .tag(Optional<ColorScheme>.some(.dark))
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            }
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            #endif
        }
        .navigationTitle("Appearance")
        #if os(iOS)
        .onChange(of: preferredColorScheme) {
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.updateTraitOverrides()
                }
            }
        }
        #endif
    }
}

#Preview {
    AppearanceSettingsView()
}
