//
//  Holder.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import Foundation
import CoreData

final class Holder: BaseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Holder> {
        return NSFetchRequest<Holder>(entityName: "Holder")
    }

    @NSManaged public var icon: String
    @NSManaged public var name: String
    @NSManaged public var accounts: Set<Account>

    convenience init(name: String, icon: String, createdByUser: Bool = true, createDate: Date = Date(),
                     context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.name = name
        self.icon = icon
    }

    var accountsList: [Account] {
        return Array(accounts)
    }

    static func isFreePair(_ name: String, icon: String, context: NSManagedObjectContext) -> Bool {
        let fetchRequest = fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "name = %@ || icon = %@", name, icon)
        do {
            let holders = try context.fetch(fetchRequest)
            if holders.isEmpty {
                return true
            } else {
                return false
            }
        } catch let error {
            print("ERROR", error)
            return false
        }
    }

    static func createAndGet(name: String, icon: String, createdByUser: Bool = true,
                             createDate: Date = Date(), context: NSManagedObjectContext) throws -> Holder {
        guard isFreePair(name, icon: icon, context: context) == true else {
            throw HolderError.thisHolderAlreadyExists
        }
        return Holder(name: name, icon: icon, createdByUser: createdByUser, createDate: createDate, context: context)
    }

    static func create(name: String, icon: String, createdByUser: Bool = true, createDate: Date = Date(),
                       context: NSManagedObjectContext) throws {
        _ = try createAndGet(name: name, icon: icon, createdByUser: createdByUser, createDate: createDate,
                             context: context)
    }

    func delete() throws {
        guard accountsList.isEmpty else {
            throw HolderError.thisHolderUsedInAccounts
        }
        managedObjectContext?.delete(self)
    }

    func update(name: String, icon: String, modifiedByUser: Bool = true, modifyDate: Date = Date(),
                context: NSManagedObjectContext) throws {
        guard Holder.isFreePair(name, icon: icon, context: context) else {throw KeeperError.thisKeeperAlreadyExists}
        self.name = name
        self.icon = icon
        self.modifiedByUser = modifiedByUser
        self.modifyDate = modifyDate
    }

    static func get(_ name: String, context: NSManagedObjectContext) throws -> Holder? {
        let fetchRequest = Holder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        let holders = try context.fetch(fetchRequest)
        if holders.isEmpty {
            return nil
        } else {
            return holders[0]
        }
    }

    static func getMe(context: NSManagedObjectContext) throws -> Holder? {
        let fetchRequest = Holder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "createdByUser = false")
        let holders = try context.fetch(fetchRequest)
        if holders.isEmpty {
            return nil
        } else {
            return holders[0]
        }
    }
}
