//
//  Rate.swift
//  Accountant
//
//  Created by Roman Topchii on 12.01.2022.
//

import Foundation
import CoreData

enum RateError: Error {
    case alreadyExist
}

final class Rate: BaseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rate> {
        return NSFetchRequest<Rate>(entityName: "Rate")
    }

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

    static func createAndGet(_ rateAmount: Double, forExchange exchange: Exchange, withCurrency currency: Currency,
                             createdByUser: Bool = false, createDate: Date = Date(),
                             context: NSManagedObjectContext) throws -> Rate {

        //        guard isRateExist(for: exchange, and: currency) else {throw RateError.alreadyExist}

        return Rate(rateAmount, forExchange: exchange, withCurrency: currency, createdByUser: createdByUser,
                    createDate: createDate, context: context)
    }

    static func create(_ rateAmount: Double, forExchange exchange: Exchange, withCurrency currency: Currency,
                       createdByUser: Bool = false, createDate: Date = Date(), context: NSManagedObjectContext) throws {
        _ = try createAndGet(rateAmount, forExchange: exchange, withCurrency: currency, createdByUser: createdByUser,
                             createDate: createDate, context: context)
    }

    static func isRateExist(for exchange: Exchange, and currency: Currency) -> Bool {
        for rate in exchange.ratesList where rate.currency == currency {
            return true
        }
        return false
    }

    func delete() {
        managedObjectContext?.delete(self)
    }
}
