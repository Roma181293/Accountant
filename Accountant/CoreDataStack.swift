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

    public static let modelName = "Accountant"

    public static let model: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    static let shared = CoreDataStack()

    private init() {}

    public lazy var persistentContainer: PersistentContainer = {

        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
        let storeURL = defaultDirectoryURL.appendingPathComponent("Production.sqlite")

        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.configuration = "Production"
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = false

        let container = PersistentContainer(name: CoreDataStack.modelName,
                                            managedObjectModel: CoreDataStack.model,
                                            environment: .prod)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores(completionHandler: { (_, error) in

            guard let error = error as NSError? else { return }
            fatalError("###\(#function): Failed to load persistent stores:\(error)")

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

            let container = PersistentContainer(name: CoreDataStack.modelName,
                                                managedObjectModel: CoreDataStack.model,
                                                environment: environment)
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
//                throw error

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")

            }
        }
    }
}

/**
 Contextual information for handling Core Data context save errors.
 */
enum ContextSaveContextualInfo: String {
    case addKeeper = "adding Keeper"
    case renameKeeper = "renaming Keeper"
    case deleteKeeper = "deleting Keeper"
    case addHolder = "adding Holder"
    case editHolder = "editing Holder"
    case deleteHolder = "deleting Holder"
    case addCurrency = "adding Currency"
    case setAccountingCurrency = "setting accounting Currency"
    case addAccount = "adding Account"
    case renameAccount = "renaming Account"
    case changeAccountActiveStatus = "changing account active status"
    case deleteAccount = "deleting Account"
    case duplicateTransaction = "duplicating Transaction"
    case deleteTransaction = "deleting Transaction"
    case deleteUserBankProfile = "deleting User Bank Profile"
    case changeUBPActiveStatus = "changing User Bank Profile active status"
    case addMultiItemTransaction = "adding Multi Item Transaction"
    case editMultiItemTransaction = "editing Multi Item Transaction"
}

extension NSManagedObjectContext {

    /**
     Handles save error by presenting an alert.
     */
    private func handleSavingError(_ error: Error, contextualInfo: ContextSaveContextualInfo) {
        print("Context saving error: \(error)")

        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window,
                let viewController = window?.rootViewController else { return }

            let message = "Failed to save the context when \(contextualInfo.rawValue)."

            // Append message to existing alert if present
            if let currentAlert = viewController.presentedViewController as? UIAlertController {
                currentAlert.message = (currentAlert.message ?? "") + "\n\n\(message)"
                return
            }

            // Otherwise present a new alert
            let alert = UIAlertController(title: "Core Data Saving Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
        }
    }

    /**
     Save a context, or handle the save error (for example, when there data inconsistency or low memory).
     */
    func save(with contextualInfo: ContextSaveContextualInfo) {
        guard hasChanges else { return }
        do {
            try save()
            UserProfile.setDateOfLastChangesInDB(Date())
        } catch {
            handleSavingError(error, contextualInfo: contextualInfo)
        }
    }
}

class PersistentContainer: NSPersistentContainer {
    let environment: Environment

    required init(name: String, managedObjectModel: NSManagedObjectModel, environment: Environment) {
        self.environment = environment
        super.init(name: name, managedObjectModel: managedObjectModel)
    }
}
