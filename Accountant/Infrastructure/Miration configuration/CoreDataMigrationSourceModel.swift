//
//  CoreDataMigrationSourceModel.swift
//  Accountant
//
//  Created by Roman Topchii on 05.11.2023.
//

import CoreData

class CoreDataMigrationSourceModel: CoreDataMigrationModel {

    // MARK: - Init

    init?(storeURL: URL) {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else {
            return nil
        }

        let migrationVersionModel = CoreDataMigrationModel.all.first {
            $0.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }

        guard migrationVersionModel != nil else {
            return nil
        }

        super.init(version: migrationVersionModel!.version)
    }
}
