//
//  Holder.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import Foundation
import CoreData

final class Holder: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Holder> {
        return NSFetchRequest<Holder>(entityName: "Holder")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var icon: String?
    @NSManaged public var name: String?
    @NSManaged public var accounts: NSSet?
    @NSManaged public var createDate: Date?
    @NSManaged public var createdByUser: Bool
    @NSManaged public var modifyDate: Date?
    @NSManaged public var modifiedByUser: Bool
    
    convenience init(name: String, icon : String, createdByUser : Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdByUser = createdByUser
        self.createDate = createDate
        self.modifiedByUser = createdByUser
        self.modifyDate = createDate
    }
    
    var accountsList: [Account] {
        return accounts!.allObjects as! [Account]
    }
    
    static func isFreePair(_ name : String, icon: String, context: NSManagedObjectContext) -> Bool {
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
    
    static func createAndGet(name: String, icon : String, createdByUser : Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) throws -> Holder{
        guard isFreePair(name, icon: icon, context: context) == true else {
            throw HolderError.thisHolderAlreadyExists
        }
        return Holder(name: name, icon: icon, createdByUser: createdByUser, createDate: createDate, context: context)
    }
    
    
    static func create(name: String, icon : String, createdByUser : Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) throws {
        let _ = try createAndGet(name: name, icon : icon, createdByUser : createdByUser, createDate: createDate, context: context)
    }
    
    func delete() throws {
        guard accountsList.isEmpty else {
            throw HolderError.thisHolderUsedInAccounts
        }
        managedObjectContext?.delete(self)
    }
    
    func update(name: String, icon: String, modifiedByUser: Bool = true, modifyDate: Date = Date(), context: NSManagedObjectContext) throws {
        guard Holder.isFreePair(name, icon: icon, context: context) else {throw KeeperError.thisKeeperAlreadyExists}
        self.name = name
        self.icon = icon
        self.modifiedByUser = modifiedByUser
        self.modifyDate = modifyDate
    }
    
    static func get(_ name : String, context: NSManagedObjectContext) throws -> Holder? {
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
        holderFetchRequest.predicate = NSPredicate(format: "createdByUser = false")
        let holders = try context.fetch(holderFetchRequest)
        if holders.isEmpty {
            return nil
        }
        else {
            return holders[0]
        }
    }
}
