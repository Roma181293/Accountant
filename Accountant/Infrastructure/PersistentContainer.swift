//
//  PersistentContainer.swift
//  Accountant
//
//  Created by Roman Topchii on 05.11.2023.
//

import CoreData

class PersistentContainer: NSPersistentContainer {
    let environment: Environment

    required init(name: String, managedObjectModel: NSManagedObjectModel, environment: Environment) {
        self.environment = environment
        super.init(name: name, managedObjectModel: managedObjectModel)
    }
}
