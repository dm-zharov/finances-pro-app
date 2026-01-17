//
//  PersistentController.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10.11.2023.
//

import CoreData
import CloudKit
import SwiftData
import OSLog
import FoundationExtension

class PersistentController {
    static var directoryURL: URL {
        NSPersistentCloudKitContainer.defaultDirectoryURL()
    }
    
    static let `public`: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Public")

        let storeURL = directoryURL.appendingPathComponent("public.store")
        
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: Constants.CloudKit.id
        )
        storeDescription.cloudKitContainerOptions?.databaseScope = CKDatabase.Scope.public
        
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.persistentStoreDescriptions = [storeDescription]

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // try! container.initializeCloudKitSchema()

        observeObjectChangesInContext(container.viewContext)
       
        return container
    }()
}

// MARK: - Notifications

extension PersistentController {
    static let objectsDidChange = NSNotification.Name("PersistentControllerEntriesDidChange")
    
    private static func observeObjectChangesInContext(_ context: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleObjectChangesInContext(_:)),
            name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: context
        )
    }
    
    @objc
    private static func handleObjectChangesInContext(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let insertedObjects = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>
        else {
            return
        }
        
        guard insertedObjects.contains(where: { $0 is CurrencyRates }) else {
            Logger.database.debug("Ignoring context change notification because it didn't change any tracked entities")
            return
        }

        Logger.database.debug("Received context change notification with inserted tracked entities")
        NotificationCenter.default.post(name: PersistentController.objectsDidChange, object: PersistentController.public)
    }
}

extension Logger {
    static let maths: Logger = .main(category: "Maths")
    static let database: Logger = .main(category: "Database")
}
