//
//  CoreDataStack.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2021.
//

import Foundation
import CoreData

class CoreDataStack {

    public static let modelName = "Accountant"

    public static let model: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    static let shared = CoreDataStack()

    private init() {}

    public lazy var persistentContainer: NSPersistentContainer = {

        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
        let storeURL = defaultDirectoryURL.appendingPathComponent("Production.sqlite")

        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.configuration = "Production"
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = false

        let container = NSPersistentContainer(name: CoreDataStack.modelName, managedObjectModel: CoreDataStack.model)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores(completionHandler: { (_, error) in
            /*
            guard let error = error as NSError? else { return }
            fatalError("###\(#function): Failed to load persistent stores:\(error)")
            */
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    func switchToDB(_ environment: Environment) {
        persistentContainer = {
            let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
            let storeURL = defaultDirectoryURL.appendingPathComponent("\(environment.rawValue).sqlite")

            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            storeDescription.configuration = environment.rawValue
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = false

            let container = NSPersistentContainer(name: CoreDataStack.modelName,
                                                  managedObjectModel: CoreDataStack.model)
            container.persistentStoreDescriptions = [storeDescription]
            container.loadPersistentStores(completionHandler: { (_, error) in
                /*
                guard let error = error as NSError? else { return }
                fatalError("###\(#function): Failed to load persistent stores:\(error)")
                */
            })
            container.viewContext.automaticallyMergesChangesFromParent = true
            return container
        }()
        UserProfile.setDateOfLastChangesInDB(Date())
    }

    func activeEnviroment() -> Environment? {
        if persistentContainer.persistentStoreDescriptions.count == 0 {
            return nil
        }
        if persistentContainer.persistentStoreDescriptions[0].configuration == Environment.test.rawValue {
            return Environment.test
        } else {
            return Environment.prod
        }
    }

    public func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
                UserProfile.setDateOfLastChangesInDB(Date())
            } catch let error {
                context.rollback()
                throw error
                /*
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                */
            }
        }
    }
}
