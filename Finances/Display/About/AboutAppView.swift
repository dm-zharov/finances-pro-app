//
//  AboutAppView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 06.11.2023.
//

import SwiftUI
import FoundationExtension

struct AboutAppView: View {
    var body: some View {
        VStack {
            List {
                
            }
            .environment(\.defaultMinListRowHeight, 48.0)
            #if os(iOS)
            .contentMargins(.top, .compact, for: .scrollContent)
            .listStyle(.insetGrouped)
            .listRowInsets(.init(top: 10.0, leading: 16.0, bottom: 10.0, trailing: 16.0))
            #endif
            .hidden()
        }
        .navigationTitle("Appearance")
    }
    
    @ViewBuilder
    var documents: some View {
        Button {
            
        } label: {
            Label {
                Text("Privacy Policy")
            } icon: {
                Image(systemName: "info")
                    .resizable()
                    .symbolVariant(.square.fill)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 30.0, height: 30.0)
                    .foregroundStyle(.gray)
            }
        }
        
        Button {
            
        } label: {
            Label {
                Text("Terms of Use")
            } icon: {
                Image(systemName: "lock")
                    .resizable()
                    .symbolVariant(.square.fill)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 30.0, height: 30.0)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    AboutAppView()
}

extension Bundle {
    var bundleName: String? {
        infoDictionary?["CFBundleName"] as? String
    }
    
    var bundleDisplayName: String? {
        infoDictionary?["CFBundleDisplayName"] as? String
    }
    
    var bundleVersion: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
    
    var bundleShortVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

extension Bundle {
    var localizedBundleName: String? {
        object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    var localizedBundleDisplayName: String? {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
