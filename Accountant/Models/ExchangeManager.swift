//
//  ExchangeManager.swift
//  Accountant
//
//  Created by Roman Topchii on 12.01.2022.
//

import Foundation
import UIKit
import CoreData

enum ExchangeError:Error{
    case alreadyExist(date: Date)
    case baseCurrencyCodeNotFound
}

class ExchangeManager {
    
    private static func fillExchange(date: Date, modifiedByUser: Bool = false, context: NSManagedObjectContext) -> Exchange {
        let beginOfDay = Calendar.current.startOfDay(for: date)
        
        let exchange = Exchange(context: context)
        let nowDate = Date()
        exchange.createDate = nowDate
        exchange.modifyDate = nowDate
        exchange.modifiedByUser = modifiedByUser
        exchange.createdByUser = modifiedByUser
        exchange.id = UUID()
        exchange.date = beginOfDay
        return exchange
    }
    
    
    /// This function returns  Exchange for a start of a given `date`.
    ///
    /// - Parameter date: exchange date
    static func getOrCreateExchange(date: Date, modifiedByUser: Bool = false, context: NSManagedObjectContext) -> Exchange {
        
        let beginOfDay = Calendar.current.startOfDay(for: date)
        
        let exchangeFetchRequest : NSFetchRequest<Exchange> = NSFetchRequest<Exchange>(entityName: "Exchange")
        exchangeFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        exchangeFetchRequest.predicate = NSPredicate(format: "date = %@", beginOfDay as CVarArg)
        do{
            let exchanges = try context.fetch(exchangeFetchRequest)
            if !exchanges.isEmpty {
                return exchanges.first!
            }
            else {
                return fillExchange(date: beginOfDay, modifiedByUser: modifiedByUser, context: context)
            }
        }
        catch let error {
            print("ERROR", error)
            return fillExchange(date: beginOfDay, modifiedByUser: modifiedByUser, context: context)
        }
    }
    
    
    private static func isExistExchange(date: Date, context: NSManagedObjectContext) -> Bool {
        let exchangeFetchRequest : NSFetchRequest<Exchange> = NSFetchRequest<Exchange>(entityName: "Exchange")
        exchangeFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        exchangeFetchRequest.predicate = NSPredicate(format: "date = %@", Calendar.current.startOfDay(for: date) as CVarArg)
        do{
            let exchanges = try context.fetch(exchangeFetchRequest)
            if exchanges.isEmpty {
                return true
            }
            else {
                return false
            }
        }
        catch let error {
            print("ERROR", error)
            return false
        }
    }
    
    
    static func lastExchangeDate(context: NSManagedObjectContext) -> Date? {
        let exchangeFetchRequest : NSFetchRequest<Exchange> = NSFetchRequest<Exchange>(entityName: Exchange.entity().name!)
        exchangeFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        exchangeFetchRequest.fetchLimit = 1
        do{
            let exchanges = try context.fetch(exchangeFetchRequest)
            if !exchanges.isEmpty {
                return exchanges.first?.date
            }
            else {
                return nil
            }
        }
        catch {
            return nil
        }
    }
    
    
    static func deleteExchange(_ exchange: Exchange, context: NSManagedObjectContext) {
        (exchange.rates?.allObjects as [Rate]).forEach({ rate in
            RateManager.deleteRate(rate, context: context)
        })
        context.delete(exchange)
    }
    
    static func deleteAllExchanges(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let exchangesFetchRequest : NSFetchRequest<Rate> = NSFetchRequest<Rate>(entityName: Rate.entity().name!)
        exchangesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        
        let exchanges = try context.fetch(exchangesFetchRequest)
        exchanges.forEach({
            context.delete($0)
        })
    }
    
    static func createExchangeRatesFrom(currencyHistoricalData: CurrencyHistoricalDataProtocol, context: NSManagedObjectContext) {
        print(#function,currencyHistoricalData.ecxhangeDate(),currencyHistoricalData.listOfCurrencies())
        guard let ecxhangeDate = currencyHistoricalData.ecxhangeDate() else {return}
        guard let accCurrency = CurrencyManager.getAccountingCurrency(context: context) else {return}
        let exchange = getOrCreateExchange(date: ecxhangeDate, context: context)
        
        try? currencyHistoricalData.listOfCurrencies().forEach{ code in
            guard let rate = currencyHistoricalData.exchangeRate(pay: accCurrency.code!, forOne: code) else {return}
            guard let currency = try CurrencyManager.getCurrencyForCode(code, context: context) else {return}
            do {
                try RateManager.createRate(rate, forExchange: exchange, withCurrency: currency, context: context)
            }
            catch let error {
                print(#function, error.localizedDescription)
            }
        }
    }
}


