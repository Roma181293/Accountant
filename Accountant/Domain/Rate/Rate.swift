//
//  Rate.swift
//  Accountant
//
//  Created by Roman Topchii on 12.01.2022.
//

import Foundation
import CoreData

final class Rate: BaseEntity {

    @NSManaged public var amount: Double
    @NSManaged public var currency: Currency?
    @NSManaged public var exchange: Exchange?

    convenience init(_ rateAmount: Double, forExchange exchange: Exchange, withCurrency currency: Currency,
                     createdByUser: Bool = false, createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.exchange = exchange
        self.currency = currency
        self.amount = rateAmount
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rate> {
        return NSFetchRequest<Rate>(entityName: "Rate")
    }
}
