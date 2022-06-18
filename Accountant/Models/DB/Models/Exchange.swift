//
//  Exchange.swift
//  Accountant
//
//  Created by Roman Topchii on 12.01.2022.
//

import Foundation
import CoreData

final class Exchange: BaseEntity {

    @NSManaged public var date: Date?
    @NSManaged public var rates: Set<Rate>

    convenience init(date: Date, createsByUser: Bool = false, createdByUser: Bool = false,
                     createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.date = Calendar.current.startOfDay(for: date)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exchange> {
        return NSFetchRequest<Exchange>(entityName: "Exchange")
    }
}
