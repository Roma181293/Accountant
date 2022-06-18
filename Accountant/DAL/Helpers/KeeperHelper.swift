//
//  KeeperHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation
import CoreData

class KeeperHelper {
    class func getKeeperForName(_ name: String, context: NSManagedObjectContext) throws -> Keeper? {
        let fetchRequest = Keeper.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Keeper.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.name.rawValue) = %@", name)
        let keepers = try context.fetch(fetchRequest)
        if keepers.isEmpty {
            return nil
        } else {
            return keepers[0]
        }
    }

    class func getFirstNonCashKeeper(context: NSManagedObjectContext) throws -> Keeper? {
        let fetchRequest = Keeper.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Keeper.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.type.rawValue) != %i",
                                             Keeper.TypeEnum.cash.rawValue)
        let keepers = try context.fetch(fetchRequest)
        return keepers.first
    }

    class func getCashKeeper(context: NSManagedObjectContext) throws -> Keeper? {
        let fetchRequest = Keeper.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Keeper.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.type.rawValue) == %i",
                                             Keeper.TypeEnum.cash.rawValue)
        let keepers = try context.fetch(fetchRequest)
        if keepers.isEmpty {
            return nil
        } else {
            return keepers.first
        }
    }

    class func getById(_ id: UUID, context: NSManagedObjectContext) -> Keeper? {
        let fetchRequest = Keeper.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Keeper.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.id.rawValue) = %@", id.uuidString)
        return try? context.fetch(fetchRequest).first
    }
}
