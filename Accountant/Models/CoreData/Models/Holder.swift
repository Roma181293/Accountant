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

    static func get(_ name: String, context: NSManagedObjectContext) throws -> Holder? {
        let fetchRequest = Holder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Holder.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Holder.name.rawValue) = %@", name)
        let holders = try context.fetch(fetchRequest)
        if holders.isEmpty {
            return nil
        } else {
            return holders[0]
        }
    }

    static func getMe(context: NSManagedObjectContext) -> Holder? {
        let fetchRequest = Holder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Holder.createDate.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Holder.createdByUser.rawValue) = false")
        return try? context.fetch(fetchRequest).first
    }
}
