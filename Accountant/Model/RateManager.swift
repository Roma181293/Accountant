//
//  ExchangeRateManager.swift
//  Accountant
//
//  Created by Roman Topchii on 12.01.2022.
//

import Foundation
import CoreData

enum RateError : Error {
    case alreadyExist
}

class RateManager {
    
    static func createAndGetRate(_ rateAmount: Double, forExchange exchange: Exchange, withCurrency currency: Currency, modifiedByUser: Bool = false, context: NSManagedObjectContext) throws -> Rate {

//        guard isRateExist(for: exchange, and: currency) else {throw RateError.alreadyExist}
        
        let rate = Rate(context: context)
        
        let date = Date()
        rate.createDate = date
        rate.modifyDate = date
        rate.modifiedByUser = modifiedByUser
        rate.createdByUser = modifiedByUser
        
        rate.id = UUID()
        rate.exchange = exchange
        rate.currency = currency
        rate.amount = rateAmount
        
        return rate
    }
    
    static func createRate(_ rateAmount: Double, forExchange exchange: Exchange, withCurrency currency: Currency, modifiedByUser: Bool = false, context: NSManagedObjectContext) throws {
        try createAndGetRate(rateAmount, forExchange: exchange, withCurrency: currency, modifiedByUser: modifiedByUser, context: context)
    }

    static func isRateExist(for exchange: Exchange, and currency: Currency) -> Bool {
        for rate in (exchange.rates?.allObjects as! [Rate]) {
            if rate.currency == currency {
                return true
            }
        }
        return false
    }
    
    static func deleteRate(_ rate: Rate, context: NSManagedObjectContext) {
        context.delete(rate)
    }
    
    static func deleteAllRates(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let ratesFetchRequest : NSFetchRequest<Rate> = NSFetchRequest<Rate>(entityName: Rate.entity().name!)
        ratesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        
        let rates = try context.fetch(ratesFetchRequest)
        rates.forEach({
            context.delete($0)
        })
    }
    
}
