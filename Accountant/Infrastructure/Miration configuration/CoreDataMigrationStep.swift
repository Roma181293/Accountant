//
//  CoreDataMigrationStep.swift
//  Accountant
//
//  Created by Roman Topchii on 05.11.2023.
//

import Foundation
import CoreData

struct CoreDataMigrationStep {
    let source: NSManagedObjectModel
    let destination: NSManagedObjectModel
    let mapping: NSMappingModel
}
