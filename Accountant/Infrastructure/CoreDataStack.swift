//
//  CoreDataStack.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2021.
//

import Foundation
import CoreData
import UIKit

class CoreDataStack {
    static let shared = CoreDataStack()

    static let modelName = "Accountant"

    public var currentEnvironment: Environment {
        return persistentContainer.environment
    }

    private let migrator: CoreDataMigrator

    private(set) var persistentContainer: PersistentContainer

    private init(migrator: CoreDataMigrator = CoreDataMigrator()) {
        persistentContainer = CoreDataStack.getConfiguredContainer(.prod)
        self.migrator = migrator
    }

//    private func setup(completion: @escaping () -> Void) {
//        loadPersistentStore {
//            completion()
//        }
//    }
//
    public func switchPersistentStore(_ environment: Environment) {
        persistentContainer = CoreDataStack.getConfiguredContainer(environment)
        loadPersistentStore(completion: {})
    }

    public func restorePersistentStore(_ environment: Environment) throws {
        let storeContainer = persistentContainer.persistentStoreCoordinator

        for store in storeContainer.persistentStores {
            guard let url = store.url, String(describing: url).contains(environment.rawValue) == true else {return}

            try storeContainer.destroyPersistentStore(
                at: store.url!,
                ofType: store.type,
                options: nil
            )

            persistentContainer = CoreDataStack.getConfiguredContainer(environment)
            loadPersistentStore(completion: {})
        }
    }

    public func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
                UserProfileService.setDateOfLastChangesInDB(Date())
            } catch let error {
                context.rollback()
                throw error
            }
        }
    }

    private func loadPersistentStore(completion: @escaping () -> Void) {
        NotificationCenter.default.post(name: Notification.Name.persistentStoreWillLoad, object: nil)
        migrateStoreIfNeeded {
            self.persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
                if let error = error {
                    fatalError("###\(#function): Failed to load persistent stores:\(error)")
                } else {
                    NotificationCenter.default.post(name: .persistentStoreDidLoad, object: nil)
                    UserProfileService.setDateOfLastChangesInDB(Date())

                    completion()
                }
            })
        }
    }

    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            fatalError("persistentContainer was not set up properly")
        }

        if migrator.requiresMigration(at: storeURL) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.migrator.migrateStore(at: storeURL)

                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            completion()
        }
    }

    private class func getConfiguredContainer(_ environment: Environment) -> PersistentContainer {
        let model: NSManagedObjectModel = {
            let modelURL = Bundle.main.url(forResource: CoreDataStack.modelName, withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        }()

        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
        let storeURL = defaultDirectoryURL.appendingPathComponent("\(environment.rawValue).sqlite")

        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.configuration = environment.rawValue
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = false

        let container = PersistentContainer(name: modelName,
                                                  managedObjectModel: model,
                                                  environment: environment)
        container.persistentStoreDescriptions = [storeDescription]
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
}
