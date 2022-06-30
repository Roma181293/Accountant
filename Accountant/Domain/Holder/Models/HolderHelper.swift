//
//  HolderHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation
import CoreData

class HolderHelper {
    class func get(_ name: String, context: NSManagedObjectContext) -> Holder? {
        let fetchRequest = Holder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Holder.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Holder.name.rawValue) = %@", name)
        return try? context.fetch(fetchRequest).first
    }

    class func getById(_ id: UUID, context: NSManagedObjectContext) -> Holder? {
        let fetchRequest = Holder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Holder.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Holder.id.rawValue) = %@", id as CVarArg)
        print(NSPredicate(format: "\(Schema.Holder.id.rawValue) = %@", id.uuidString))
        return try? context.fetch(fetchRequest).first
    }

    class func getMe(context: NSManagedObjectContext) -> Holder? {
        let fetchRequest = Holder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Holder.createDate.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Holder.createdByUser.rawValue) = false")
        return try? context.fetch(fetchRequest).first
    }
}
