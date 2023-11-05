//
//  CoreDataMigratorProtocol.swift
//  Accountant
//
//  Created by Roman Topchii on 05.11.2023.
//

import Foundation

protocol CoreDataMigratorProtocol {
    func requiresMigration(at storeURL: URL, toVersion version: CoreDataMigrationVersion) -> Bool
    func migrateStore(at storeURL: URL, toVersion version: CoreDataMigrationVersion)
}
