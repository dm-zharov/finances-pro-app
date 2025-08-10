//
//  SecuritySettingsView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.11.2023.
//

import SwiftUI
import SwiftAuthn
internal import LocalAuthentication
import AppUI
import FinancesCore

enum LockRate {
    case immediately
    case afterOneMinute
    case afterFiveMinutes
    case afterFifteenMinutes
}

struct SecuritySettingsView: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    @Environment(BiometricAuthenticationController.self) private var authenticationController

    @State private var isAuthenticationEnabled: Bool = BiometricAuthenticationController.shared.isEnabled
    @AppStorage(SettingKey.obscureSensitiveContent, store: .shared) private var shouldObscureSensitiveContent: Bool = true
    
    var title: String {
        switch authenticationController.biometryType {
        case .faceID:
            String(localized: "Face ID & Privacy")
        case .touchID:
            String(localized: "Touch ID & Privacy")
        default:
            String(localized: "Privacy")
        }
    }
    
    var body: some View {
        VStack {
            Form {
                if let canAuthenticate = try? authenticationController.checkCanAuthenticate(), canAuthenticate {
                    Section {
                        Toggle(isOn: $isAuthenticationEnabled) {
                            Text("Lock Finances")
                        }
                        .disabled(authenticationController.state == .authenticating)
                        .onChange(of: isAuthenticationEnabled) {
                            if isAuthenticationEnabled {
                                authenticationController.authenticate(
                                    localizedReason: {
                                        switch userInterfaceIdiom {
                                        case .mac:
                                            String(localized: "Enable authentication").lowercased()
                                        default:
                                            String(localized: "Enable authentication")
                                        }
                                    }(),
                                    completion: { error in
                                        isAuthenticationEnabled = error == nil
                                    }
                                )
                            } else {
                                authenticationController.deauthenticate {
                                    isAuthenticationEnabled = false
                                }
                            }
                        }
                    } header: {
                        Text(authenticationController.biometryType.description)
                    } footer: {
                        Text(userInterfaceIdiom == .mac ? "Lock your finances using the Touch ID." : "Lock your finances using the Face ID or Touch ID.")
                            .textStyle(.footer)
                    }
                }
                
                #if os(iOS)
                Section {
                    Toggle("Obscure Sensitive Content", isOn: $shouldObscureSensitiveContent)
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("Protect finances when the app is being recorded, mirrored, or streamed via AirPlay. Screenshots are not affected.")
                }
                #endif
                
                Section {
                    Link(destination: URL(string: "https://finances.zharov.dev/privacy")!) {
                        Text("View Privacy Policy")
                    }
                } header: {
                    #if os(iOS)
                    EmptyView()
                    #else
                    Text("Privacy")
                    #endif
                }
            }
            .formStyle(.grouped)
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            #endif
        }
        .navigationTitle(title)
    }
}

#Preview {
    SecuritySettingsView()
}
