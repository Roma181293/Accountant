//
//  CoreDataVersion.swift
//  Accountant
//
//  Created by Roman Topchii on 05.11.2023.
//

import Foundation
import CoreData

enum CoreDataMigrationVersion: Int {
    case version1 = 1
    case version2 = 2
    case version3 = 3

    // MARK: - Accessors

    var name: String {
        if rawValue == 1 {
            return "Accountant"
        } else {
            return "Accountant \(rawValue)"
        }
    }

    static var all: [CoreDataMigrationVersion] {
        var versions = [CoreDataMigrationVersion]()

        for rawVersionValue in 1...1000 { // A bit of a hack here to avoid manual mapping
            if let version = CoreDataMigrationVersion(rawValue: rawVersionValue) {
                versions.append(version)
                continue
            }

            break
        }

        return versions.reversed()
    }

    static var latest: CoreDataMigrationVersion {
        return all.first!
    }
}
