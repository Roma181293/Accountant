//
//  ArchivingHistory.swift
//  Accountant
//
//  Created by Roman Topchii on 17.06.2022.
//

import Foundation
import CoreData

class ArchivingHistory: BaseEntity {

    @objc enum Status: Int16 {
        case failure = 0
        case success = 1
    }

    @NSManaged public var date: Date
    @NSManaged public var status: Status
    @NSManaged public var comment: String?

    convenience init(date: Date, status: Status, comment: String? = nil, createdByUser: Bool = true,
                     context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: Date(), context: context)
        self.date = date
        self.status = status
        self.comment = comment
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArchivingHistory> {
        return NSFetchRequest<ArchivingHistory>(entityName: "ArchivingHistory")
    }
}
