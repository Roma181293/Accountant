//
//  Exchange.swift
//  Accountant
//
//  Created by Roman Topchii on 12.01.2022.
//

import Foundation
import UIKit
import CoreData

enum ExchangeError: Error {
    case alreadyExist(date: Date)
    case baseCurrencyCodeNotFound
}

final class Exchange: BaseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exchange> {
        return NSFetchRequest<Exchange>(entityName: "Exchange")
    }

    @NSManaged public var date: Date?
    @NSManaged public var rates: Set<Rate>

    convenience init(date: Date, createsByUser: Bool = false, createdByUser: Bool = false,
                     createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.date = Calendar.current.startOfDay(for: date)
    }

    var ratesList: [Rate] {
        return Array(rates)
    }

    /// This function returns  Exchange for a start of a given `date`.
    ///
    /// - Parameter date: exchange date
    static func getOrCreate(date: Date, createsByUser: Bool = false, createDate: Date = Date(),
                            context: NSManagedObjectContext) -> Exchange {
        let beginOfDay = Calendar.current.startOfDay(for: date)
        let fetchRequest = Exchange.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "date = %@", beginOfDay as CVarArg)
        do {
            let exchanges = try context.fetch(fetchRequest)
            if !exchanges.isEmpty {
                return exchanges.first!
            } else {
                return Exchange(date: beginOfDay, createsByUser: createsByUser, createDate: createDate,
                                context: context)
            }
        } catch let error {
            print("ERROR", error)
            return Exchange(date: beginOfDay, createsByUser: createsByUser, createDate: createDate, context: context)
        }
    }

    private static func isExistExchange(date: Date, context: NSManagedObjectContext) -> Bool {
        let fetchRequest = Exchange.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "date = %@",
                                             Calendar.current.startOfDay(for: date) as CVarArg)
        if let count = try? context.count(for: fetchRequest), count == 0 {
            return true
        } else {
            return false
        }
    }

    static func lastExchangeDate(context: NSManagedObjectContext) -> Date? {
        let fetchRequest = Exchange.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            let exchanges = try context.fetch(fetchRequest)
            if !exchanges.isEmpty {
                return exchanges.first?.date
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

    func delete() {
        self.ratesList.forEach({ rate in
            rate.delete()
        })
        managedObjectContext?.delete(self)
    }

    static func createExchangeRatesFrom(currencyHistoricalData: CurrencyHistoricalDataProtocol,
                                        context: NSManagedObjectContext) {
        guard let ecxhangeDate = currencyHistoricalData.ecxhangeDate() else {return}
        guard let accCurrency = Currency.getAccountingCurrency(context: context) else {return}
        let exchange = getOrCreate(date: ecxhangeDate, context: context)

        try? currencyHistoricalData.listOfCurrencies().forEach { code in
            guard let rate = currencyHistoricalData.exchangeRate(pay: accCurrency.code, forOne: code) else {return}
            guard let currency = try Currency.getCurrencyForCode(code, context: context) else {return}
            do {
                try Rate.create(rate, forExchange: exchange, withCurrency: currency, context: context)
            } catch let error {
                print(#function, error.localizedDescription)
            }
        }
    }
}
