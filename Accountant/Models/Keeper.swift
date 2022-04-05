//
//  KeeperManager.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import Foundation
import CoreData

extension Keeper {
    
    convenience init(name: String, type: KeeperType, createdByUser : Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.type = type.rawValue
        self.createdByUser = createdByUser
        self.createDate = createDate
        self.modifiedByUser = createdByUser
        self.modifyDate = createDate
    }
    
    var accountsList: [Account] {
        return self.accounts!.allObjects as! [Account]
    }
    
    var userBankProfilesList: [UserBankProfile] {
        return self.userBankProfiles!.allObjects as! [UserBankProfile]
    }
    
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
    
    static func createAndGetKeeper(name: String, type: KeeperType, createdByUser : Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) throws -> Keeper{
        guard isFreeKeeperName(name, context: context) == true else {
            throw KeeperError.thisKeeperAlreadyExists
        }
        return Keeper(name: name, type: type, createdByUser: createdByUser, createDate: createDate, context: context)
    }
    
    
    static func createKeeper(name: String, type: KeeperType, createdByUser : Bool = true, context: NSManagedObjectContext) throws {
        let _ = try createAndGetKeeper(name: name, type:type, createdByUser : createdByUser, context: context)
    }
    
    func removeKeeper() throws {
        guard accountsList.isEmpty else {
            throw KeeperError.thisKeeperUsedInAccounts
        }
        managedObjectContext?.delete(self)
    }
    
    func renameKeeper(newname: String, modifiedByUser: Bool = true, modifyDate: Date = Date(), context: NSManagedObjectContext) throws {
        guard Keeper.isFreeKeeperName(newname, context: context) else { throw KeeperError.thisKeeperAlreadyExists }
        self.name = newname
        self.modifiedByUser = modifiedByUser
        self.modifyDate = modifyDate
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
}
