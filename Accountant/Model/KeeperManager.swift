//
//  KeeperManager.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import Foundation
import CoreData

class KeeperManager {
    
    static func isFreeKeeperName(_ name : String, context: NSManagedObjectContext) -> Bool {
        let keeperFetchRequest : NSFetchRequest<Keeper> = NSFetchRequest<Keeper>(entityName: Keeper.entity().name!)
        keeperFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        keeperFetchRequest.predicate = NSPredicate(format: "name = %@", name)
        do {
            let keeper = try context.fetch(keeperFetchRequest)
            if keeper.isEmpty {
                return true
            }
            else {
                return false
            }
        }
        catch let error {
            print("ERROR", error)
            return false
        }
    }
    
    static func createAndGetKeeper(name: String, type: KeeperType, createdByUser : Bool = true, context: NSManagedObjectContext) throws -> Keeper{
        guard isFreeKeeperName(name, context: context) == true else {
            throw KeeperError.thisKeeperAlreadyExists
        }
        let date = Date()
        let keeper = Keeper(context: context)
        keeper.createdByUser = createdByUser
        keeper.createDate = date
        keeper.modifiedByUser = createdByUser
        keeper.modifyDate = date
        keeper.name = name
        keeper.type = type.rawValue
        return keeper
    }
    
    
    static func createKeeper(name: String, type: KeeperType, createdByUser : Bool = true, context: NSManagedObjectContext) throws {
        try createAndGetKeeper(name: name, type:type, createdByUser : createdByUser, context: context)
    }
    
    static func removeKeeper(_ keeper: Keeper, context: NSManagedObjectContext) throws {
        guard keeper.accounts?.allObjects.count == 0 else {
            throw KeeperError.thisKeeperUsedInAccounts
        }
        context.delete(keeper)
    }
    
    static func renameKeeper(_ keeper: Keeper, name: String, modifiedByUser: Bool = true, modifyDate: Date = Date(), context: NSManagedObjectContext) throws {
        guard isFreeKeeperName(name, context: context) else { throw KeeperError.thisKeeperAlreadyExists }
        keeper.name = name
        keeper.modifiedByUser = modifiedByUser
        keeper.modifyDate = modifyDate
    }
    
    static func getKeeperForName(_ name : String, context: NSManagedObjectContext) throws -> Keeper? {
        let keeperFetchRequest : NSFetchRequest<Keeper> = NSFetchRequest<Keeper>(entityName: Keeper.entity().name!)
        keeperFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        keeperFetchRequest.predicate = NSPredicate(format: "name = %@", name)
        let keepers = try context.fetch(keeperFetchRequest)
        if keepers.isEmpty {
            return nil
        }
        else {
            return keepers[0]
        }
    }
    
    static func getFirstNonCashKeeper(context: NSManagedObjectContext) throws -> Keeper? {
        let keeperFetchRequest : NSFetchRequest<Keeper> = NSFetchRequest<Keeper>(entityName: Keeper.entity().name!)
        keeperFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        keeperFetchRequest.predicate = NSPredicate(format: "type != %i", KeeperType.cash.rawValue)
        let keepers = try context.fetch(keeperFetchRequest)
        if keepers.isEmpty {
            return nil
        }
        else {
            return keepers.first
        }
    }
    
    static func getCashKeeper(context: NSManagedObjectContext) throws -> Keeper? {
        let keeperFetchRequest : NSFetchRequest<Keeper> = NSFetchRequest<Keeper>(entityName: Keeper.entity().name!)
        keeperFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        keeperFetchRequest.predicate = NSPredicate(format: "type == %i", KeeperType.cash.rawValue)
        let keepers = try context.fetch(keeperFetchRequest)
        if keepers.isEmpty {
            return nil
        }
        else {
            return keepers.first
        }
    }
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllKeepers(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let keeperFetchRequest : NSFetchRequest<Keeper> = NSFetchRequest<Keeper>(entityName: Keeper.entity().name!)
        keeperFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let keepers = try context.fetch(keeperFetchRequest)
        keepers.forEach({
            context.delete($0)
        })
    }
    
    static func createDefaultKeepers(context: NSManagedObjectContext) {
        try? createKeeper(name: NSLocalizedString("Cash", comment: ""), type: .cash, createdByUser: false, context: context)
        try? createKeeper(name: NSLocalizedString("Monobank",comment: ""), type: .bank, createdByUser: false, context: context)
    }
    
    static func createTestKeepers(context: NSManagedObjectContext) throws {
        try createKeeper(name: NSLocalizedString("Cash", comment: ""), type: .cash, createdByUser: false, context: context)
        try createKeeper(name: NSLocalizedString("Bank1", comment: ""), type: .bank, context: context)
        try createKeeper(name: NSLocalizedString("Bank2", comment: ""), type: .bank, context: context)
        try createKeeper(name: NSLocalizedString("Hanna", comment: ""), type: .person, context: context)
        try createKeeper(name: NSLocalizedString("Monobank",comment: ""), type: .bank, createdByUser: false, context: context)
    }
}
