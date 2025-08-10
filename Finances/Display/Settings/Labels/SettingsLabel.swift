//
//  SettingsLabel.swift
//  Finances
//
//  Created by Dmitriy Zharov on 17.12.2023.
//

import SwiftUI
import AppUI
import SwiftAuthn
internal import LocalAuthentication

// MARK: - Data

struct CurrencySettingsLabel: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    var body: some View {
        Label {
            Text("Currencies")
        } icon: {
            if userInterfaceIdiom == .mac {
                Image(systemName: SymbolName.Setting.currency.rawValue.rawValue)
            } else {
                SettingImage(.currency)
            }
        }
    }
}

struct AccountSettingsLabel: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    var body: some View {
        Label {
            Text("Accounts")
        } icon: {
            if userInterfaceIdiom == .mac {
                Image(systemName: SymbolName.Setting.asset.rawValue.rawValue)
            } else {
                SettingImage(.asset)
            }
        }
    }
}

struct CategorySettingsLabel: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    var body: some View {
        Label {
            Text("Categories")
        } icon: {
            if userInterfaceIdiom == .mac {
                Image(systemName: SymbolName.Setting.paperclip.rawValue.rawValue)
            } else {
                SettingImage(.paperclip)
            }
        }
    }
}

struct MerchantSettingsLabel: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    var body: some View {
        Label {
            Text("Payees")
        } icon: {
            if userInterfaceIdiom == .mac {
                Image(systemName: SymbolName.Setting.storefront.rawValue.rawValue)
            } else {
                SettingImage(.storefront)
            }
        }
    }
}

struct TagSettingsLabel: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    var body: some View {
        Label {
            Text("Tags")
        } icon: {
            if userInterfaceIdiom == .mac {
                Image(systemName: SymbolName.Setting.number.rawValue.rawValue)
            } else {
                SettingImage(.number)
            }
        }
    }
}

// MARK: - System

struct AppearanceSettingsLabel: View {
    var body: some View {
        Label {
            Text("Appearance")
        } icon: {
            SettingImage(.lightbulb)
        }
    }
}

struct NotificationSettingsLabel: View {
    var body: some View {
        Label {
            Text("Notifications")
        } icon: {
            SettingImage(.bell)
        }
    }
}
struct SyncSettingsLabel: View {
    var body: some View {
        Label {
            Text("iCloud Sync")
        } icon: {
            SettingImage(.icloud)
        }
    }
}

struct SecuritySettingsLabel: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    @Environment(BiometricAuthenticationController.self) private var authenticationController
    
    var body: some View {
        Label {
            if userInterfaceIdiom == .mac {
                Text("Security")
            } else {
                switch authenticationController.biometryType {
                case .faceID:
                    Text("Face ID & Privacy")
                case .touchID:
                    Text("Touch ID & Privacy")
                default:
                    Text("Privacy")
                }
            }
        } icon: {
            if userInterfaceIdiom == .mac {
                Image(systemName: SymbolName.Setting.lock.rawValue.rawValue)
            } else {
                SettingImage(.lock)
            }
        }
    }
}

// MARK: - Storage

struct ImportExportSettingsLabel: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    var body: some View {
        Label {
            Text("Import & Export")
        } icon: {
            if userInterfaceIdiom == .mac {
                Image(systemName: SymbolName.Setting.transfer.rawValue.rawValue)
            } else {
                SettingImage(.transfer)
            }
        }
    }
}

struct BackupSettingsLabel: View {
    var body: some View {
        Label {
            Text("Backups")
        } icon: {
            SettingImage(.externaldrive)
        }
    }
}

// MARK: - About

struct AboutAppLabel: View {
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    var body: some View {
        Label {
            Text("About App")
        } icon: {
            if userInterfaceIdiom == .mac {
                Image(systemName: SymbolName.Setting.house.rawValue.rawValue)
            } else {
                SettingImage(.house)
            }
        }
    }
}
