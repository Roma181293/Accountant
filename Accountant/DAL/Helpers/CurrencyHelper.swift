//
//  CurrencyHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation
import CoreData

class CurrencyHelper {
    
    class func getCurrencyForCode(_ code: String, context: NSManagedObjectContext) throws -> Currency? {
        let fetchRequest = Currency.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Currency.code.rawValue, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Currency.code.rawValue) = %@", code)
        return try context.fetch(fetchRequest).first
    }

    class func getById(_ id: UUID, context: NSManagedObjectContext) -> Currency? {
        let fetchRequest = Currency.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Currency.code.rawValue, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Currency.id.rawValue) = %@", id.uuidString)
        return try? context.fetch(fetchRequest).first
    }

    class func getCurrencyForISO4217(_ iso4217: Int16, context: NSManagedObjectContext) throws -> Currency? {
        let fetchRequest = Currency.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Currency.iso4217.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Currency.iso4217.rawValue) = \(iso4217)")
        let currencies = try context.fetch(fetchRequest)
        if currencies.isEmpty {
            return nil
        } else {
            return currencies[0]
        }
    }

    class func setAccountingCurrency(_ currency: Currency, modifyDate: Date = Date(),
                                     modifiedByUser: Bool = true, context: NSManagedObjectContext) throws {
        currency.isAccounting = true
        currency.modifyDate = modifyDate
        currency.modifiedByUser = modifiedByUser
    }

    class func getAccountingCurrency(context: NSManagedObjectContext) -> Currency? {
        let fetchRequest = Currency.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Currency.code.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Currency.isAccounting.rawValue) = true")
        do {
            let currencies = try context.fetch(fetchRequest)
            if currencies.isEmpty == false {
                return currencies.first!
            } else {
                return nil
            }
        } catch let error {
            print("ERROR", error)
            return nil
        }
    }
}
