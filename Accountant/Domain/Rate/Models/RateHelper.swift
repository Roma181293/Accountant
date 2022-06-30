//
//  RateHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation
import CoreData

class RateHelper {
    
    class func createAndGet(_ rateAmount: Double, forExchange exchange: Exchange, withCurrency currency: Currency,
                            createdByUser: Bool = false, createDate: Date = Date(),
                            context: NSManagedObjectContext) throws -> Rate {

        //        guard isRateExist(for: exchange, and: currency) else {throw RateError.alreadyExist}

        return Rate(rateAmount, forExchange: exchange, withCurrency: currency, createdByUser: createdByUser,
                    createDate: createDate, context: context)
    }

    class func create(_ rateAmount: Double, forExchange exchange: Exchange, withCurrency currency: Currency,
                      createdByUser: Bool = false, createDate: Date = Date(), context: NSManagedObjectContext) throws {
        _ = try createAndGet(rateAmount, forExchange: exchange, withCurrency: currency, createdByUser: createdByUser,
                             createDate: createDate, context: context)
    }

    class func isRateExist(for exchange: Exchange, and currency: Currency) -> Bool {
        for rate in exchange.ratesList where rate.currency == currency {
            return true
        }
        return false
    }
}
