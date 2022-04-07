//
//  Exchange.swift
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

final class Exchange: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exchange> {
        return NSFetchRequest<Exchange>(entityName: "Exchange")
    }

    @NSManaged public var createDate: Date?
    @NSManaged public var createdByUser: Bool
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var modifiedByUser: Bool
    @NSManaged public var modifyDate: Date?
    @NSManaged public var rates: NSSet?
    
    convenience init(date: Date, createsByUser: Bool = false, createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(context: context)
        self.createDate = createDate
        self.createdByUser = createsByUser
        self.modifyDate = createDate
        self.modifiedByUser = createsByUser
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
    }
    
    var ratesList: [Rate] {
        return rates!.allObjects as! [Rate]
    }
    
    /// This function returns  Exchange for a start of a given `date`.
    ///
    /// - Parameter date: exchange date
    static func getOrCreate(date: Date, createsByUser: Bool = false, createDate: Date = Date(), context: NSManagedObjectContext) -> Exchange {
        
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
                return Exchange(date: beginOfDay, createsByUser: createsByUser, createDate: createDate, context: context)
            }
        }
        catch let error {
            print("ERROR", error)
            return Exchange(date: beginOfDay, createsByUser: createsByUser, createDate: createDate, context: context)
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
    
    func delete() {
        self.ratesList.forEach({ rate in
            rate.delete()
        })
        managedObjectContext?.delete(self)
    }
    
    static func createExchangeRatesFrom(currencyHistoricalData: CurrencyHistoricalDataProtocol, context: NSManagedObjectContext) {
        print(#function,currencyHistoricalData.ecxhangeDate(),currencyHistoricalData.listOfCurrencies())
        guard let ecxhangeDate = currencyHistoricalData.ecxhangeDate() else {return}
        guard let accCurrency = Currency.getAccountingCurrency(context: context) else {return}
        let exchange = getOrCreate(date: ecxhangeDate, context: context)
        
        try? currencyHistoricalData.listOfCurrencies().forEach{ code in
            guard let rate = currencyHistoricalData.exchangeRate(pay: accCurrency.code, forOne: code) else {return}
            guard let currency = try Currency.getCurrencyForCode(code, context: context) else {return}
            do {
                try Rate.create(rate, forExchange: exchange, withCurrency: currency, context: context)
            }
            catch let error {
                print(#function, error.localizedDescription)
            }
        }
    }
}
