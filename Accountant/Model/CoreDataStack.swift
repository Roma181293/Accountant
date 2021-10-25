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
    private init(){}
    
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataStack.modelName, managedObjectModel: CoreDataStack.model)
        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()

//        let testStoreURL = defaultDirectoryURL.appendingPathComponent("Test.sqlite")
//        let testStoreDescription = NSPersistentStoreDescription(url: testStoreURL)
//        testStoreDescription.configuration = "Test"

        let productionStoreURL = defaultDirectoryURL.appendingPathComponent("Production.sqlite")
        let productionStoreDescription = NSPersistentStoreDescription(url: productionStoreURL)
        productionStoreDescription.configuration = "Production"

        container.persistentStoreDescriptions = [productionStoreDescription]
        container.loadPersistentStores(completionHandler: { (_, error) in
//            guard let error = error as NSError? else { return }
//            fatalError("###\(#function): Failed to load persistent stores:\(error)")
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
       
        return container
    }()
    
   
    func switchToDB(_ db: Environment) {
        
        persistentContainer = {
            let container = NSPersistentContainer(name: CoreDataStack.modelName, managedObjectModel: CoreDataStack.model)
            let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()

            let storeURL = defaultDirectoryURL.appendingPathComponent("\(db.rawValue).sqlite")
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            storeDescription.configuration = db.rawValue

            container.persistentStoreDescriptions = [storeDescription]
            container.loadPersistentStores(completionHandler: { (_, error) in
//                guard let error = error as NSError? else { return }
//                fatalError("###\(#function): Failed to load persistent stores:\(error)")
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
        }
        else {
            return Environment.prod
        }
    }
    
    
//    public lazy var viewContext: NSManagedObjectContext = {
//        return persistentContainer.viewContext
//    }()
//
//    public func newDerivedContext() -> NSManagedObjectContext {
//        let context = persistentContainer.newBackgroundContext()
//        return context
//    }
//
//    public func saveContext() {
//        saveContext(viewContext)
//    }
//
//    public func saveContext(_ context: NSManagedObjectContext) {
//        if context != viewContext {
//            saveDerivedContext(context)
//            return
//        }
//
//        context.perform {
//            do {
//                try context.save()
//            } catch let error as NSError {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//    }
//    public func saveDerivedContext(_ context: NSManagedObjectContext) {
//        context.perform {
//            do {
//                try context.save()
//            } catch let error as NSError {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//
//            self.saveContext(self.viewContext)
//        }
//    }
//
    
    public func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
                UserProfile.setDateOfLastChangesInDB(Date())
            } catch {
                context.rollback()
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

