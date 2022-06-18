//
//  Holder.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import Foundation
import CoreData

final class Holder: BaseEntity {

    @NSManaged public var icon: String
    @NSManaged public var name: String
    @NSManaged public var accounts: Set<Account>

    convenience init(name: String, icon: String, createdByUser: Bool = true, createDate: Date = Date(),
                     context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.name = name
        self.icon = icon
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Holder> {
        return NSFetchRequest<Holder>(entityName: "Holder")
    }
}
