//
//  HolderManager.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import Foundation
import CoreData

class HolderManager {
    
    static func isFreeHolderName(_ name : String, icon: String, context: NSManagedObjectContext) -> Bool {
        let holderFetchRequest : NSFetchRequest<Holder> = NSFetchRequest<Holder>(entityName: Holder.entity().name!)
        holderFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        holderFetchRequest.predicate = NSPredicate(format: "name = %@ || icon = %@", name, icon)
        do {
            let holders = try context.fetch(holderFetchRequest)
            if holders.isEmpty {
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
    
    static func createAndGetHolder(name: String, icon : String, createdByUser : Bool = true, context: NSManagedObjectContext) throws -> Holder{
        guard isFreeHolderName(name, icon: icon, context: context) == true else {
            throw HolderError.thisHolderAlreadyExists
        }
        let date = Date()
        let holder = Holder(context: context)
        holder.id = UUID()
        holder.createdByUser = createdByUser
        holder.createDate = date
        holder.modifiedByUser = createdByUser
        holder.modifyDate = date
        holder.name = name
        holder.icon = icon
        return holder
    }
    
    
    static func createHolder(name: String, icon : String, createdByUser : Bool = true, context: NSManagedObjectContext) throws {
        try createAndGetHolder(name: name, icon : icon, createdByUser : createdByUser, context: context)
    }
    
    static func removeHolder(_ Holder: Holder, context: NSManagedObjectContext) throws {
        guard Holder.accounts?.allObjects.count == 0 else {
            throw HolderError.thisHolderUsedInAccounts
        }
        context.delete(Holder)
    }
    
    static func updateHolder(_ holder: Holder, name: String, icon: String, modifiedByUser: Bool = true, modifyDate: Date = Date(), context: NSManagedObjectContext) throws {
        guard isFreeHolderName(name, icon: icon, context: context) else { throw KeeperError.thisKeeperAlreadyExists }
        holder.name = name
        holder.icon = icon
        holder.modifiedByUser = modifiedByUser
        holder.modifyDate = modifyDate
    }
    
    static func getHolderForName(_ name : String, context: NSManagedObjectContext) throws -> Holder? {
        let holderFetchRequest : NSFetchRequest<Holder> = NSFetchRequest<Holder>(entityName: Holder.entity().name!)
        holderFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        holderFetchRequest.predicate = NSPredicate(format: "name = %@", name)
        let holders = try context.fetch(holderFetchRequest)
        if holders.isEmpty {
            return nil
        }
        else {
            return holders[0]
        }
    }
    
    static func getMe(context: NSManagedObjectContext) throws -> Holder? {
        let holderFetchRequest : NSFetchRequest<Holder> = NSFetchRequest<Holder>(entityName: Holder.entity().name!)
        holderFetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        let holders = try context.fetch(holderFetchRequest)
        if holders.isEmpty {
            return nil
        }
        else {
            return holders[0]
        }
    }
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllHolders(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let holderFetchRequest : NSFetchRequest<Holder> = NSFetchRequest<Holder>(entityName: Holder.entity().name!)
        holderFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let holders = try context.fetch(holderFetchRequest)
        holders.forEach({
            context.delete($0)
        })
        
    }
    
    
    static func createDefaultHolders(context: NSManagedObjectContext) {
        try? createHolder(name: NSLocalizedString("Me", comment: ""),icon: "😎", createdByUser: false, context: context)
    }
    
    static func createTestHolders(context: NSManagedObjectContext) throws {
        try createHolder(name: NSLocalizedString("Me", comment: ""),icon: "😎", createdByUser: false, context: context)
        try createHolder(name: NSLocalizedString("Kate", comment: ""),icon: "👩🏻‍🦰", context: context)
    }
}

