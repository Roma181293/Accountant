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

    public var activeEnvironment: Environment {
        return persistentContainer.environment
    }

    private static let modelName = "Accountant"

    private static let model: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    private(set) var persistentContainer: PersistentContainer

    private init() {
        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
        let storeURL = defaultDirectoryURL.appendingPathComponent("\(Environment.prod.rawValue).sqlite")

        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.configuration = Environment.prod.rawValue
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = false

        persistentContainer = PersistentContainer(name: CoreDataStack.modelName,
                                                  managedObjectModel: CoreDataStack.model,
                                                  environment: .prod)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    public func configureContainerFor(_ environment: Environment) {
        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
        let storeURL = defaultDirectoryURL.appendingPathComponent("\(environment.rawValue).sqlite")

        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.configuration = environment.rawValue
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = false

        persistentContainer = PersistentContainer(name: CoreDataStack.modelName,
                                                  managedObjectModel: CoreDataStack.model,
                                                  environment: environment)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    public func loadPersistentStores() {
        NotificationCenter.default.post(name: Notification.Name.persistentStoreWillLoad, object: nil)
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("###\(#function): Failed to load persistent stores:\(error)")
            } else {
                NotificationCenter.default.post(name: .persistentStoreDidLoad, object: nil)
                UserProfileService.setDateOfLastChangesInDB(Date())
            }
        })
    }

    public func switchPersistentStore(_ environment: Environment) {
        configureContainerFor(environment)
        loadPersistentStores()
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

            configureContainerFor(environment)
            loadPersistentStores()
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
    case applyApprovedTransactions = "applying an approved Transactions"
    case archivingTransactions = "archiving Transactions"
    case unarchivingTransactions = "unarchiving Transactions"
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
            UserProfileService.setDateOfLastChangesInDB(Date())
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
