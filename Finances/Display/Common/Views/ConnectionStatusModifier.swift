//
//  StatusView.swift
//  Finances
//
//  Created by Dmitriy Zharov on 15.11.2023.
//

import SwiftUI
import CoreData
import CloudKit
import Combine

struct ConnectionStatusModifier: ViewModifier {
    @State private var title: LocalizedStringKey = ""
    @State private var description: String? = nil
    
    func body(content: Content) -> some View {
        content
            .navigationSubtitle(Text(title))
            .onReceive(
                NotificationCenter.default.publisher(
                    for: NSPersistentCloudKitContainer.eventChangedNotification, object: PersistentController.public
                )
                .compactMap { notification -> NSPersistentCloudKitContainer.Event? in
                    guard
                        let userInfo = notification.userInfo,
                        let cloudEvent = userInfo[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event
                    else {
                        return nil
                    }
                    return cloudEvent
                }
                .throttle(for: 3.0, scheduler: DispatchQueue.global(), latest: true)
                .receive(on: RunLoop.main)
            ) { cloudEvent in
                switch cloudEvent.endDate {
                case .some(_):
                    if cloudEvent.succeeded {
                        self.title = "Updated Just Now"
                        self.description = nil
                    } else if let error = cloudEvent.error as? NSError, error.code == 134400 {
                        self.title = "Couldn't Update Rates"
                        self.description = String(localized: "Missing iCloud Account")
                    } else if let error = cloudEvent.error as? CKError {
                        switch error.code {
                        case .accountTemporarilyUnavailable:
                            self.title = "Couldn't Update Rates"
                            self.description = String(localized: "iCloud Account is Unavailable")
                        case .internalError:
                            self.title = "Couldn't Update Rates"
                            self.description = String(localized: "CloudKit Internal Error")
                        case .limitExceeded:
                            self.title = "Couldn't Update Rates"
                            self.description = String(localized: "CloudKit Request's Size exceeds the limit")
                        default:
                            self.title = "Couldn't Update Rates"
                            self.description = error.localizedDescription
                        }
                    } else {
                        self.title = "Couldn't Update Rates"
                        self.description = cloudEvent.error?.localizedDescription
                    }
                default:
                    self.title = "Checking Currency Rates..."
                    self.description = nil
                }
            }
    }
}

extension View {
    func connectionStatus() -> some View {
        modifier(ConnectionStatusModifier())
    }
}
