//
//  TestCoreDataStack.swift
//  AccountingTests
//
//  Created by Roman Topchii on 07.01.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import Foundation
import Accountant
import CoreData

class TestCoreDataStack {

    public static let modelName = "Accountant"

    public static let model: NSManagedObjectModel = {
        // swiftlint:disable force_unwrapping
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        // swiftlint:enable force_unwrapping
    }()

    static let shared = TestCoreDataStack()
    private init() {}

    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: TestCoreDataStack.modelName,
                                              managedObjectModel: TestCoreDataStack.model)
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    public func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
