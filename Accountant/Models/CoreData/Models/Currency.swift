//
//  Currency.swift
//  Accounting
//
//  Created by Roman Topchii on 31.12.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation
import CoreData

final class Currency: BaseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Currency> {
        return NSFetchRequest<Currency>(entityName: "Currency")
    }

    @NSManaged public var code: String
    @NSManaged public var iso4217: Int16
    @NSManaged public var name: String?
    @NSManaged public var isAccounting: Bool
    @NSManaged public var accounts: Set<Account>!
    @NSManaged public var exchangeRates: Set<Rate>!

    convenience init(code: String, iso4217: Int16, name: String?, createdByUser: Bool = true,
                     createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.code = code // UAH
        self.iso4217 = iso4217 // 980
        self.name = name
        self.isAccounting = false
    }

    var accountsList: [Account] {
        return Array(accounts)
    }

    var exchangeRatesList: [Account] {
        return Array(accounts)
    }

    static func getCurrencyForCode(_ code: String, context: NSManagedObjectContext) throws -> Currency? {
        let fetchRequest = fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Currency.code.rawValue, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Currency.code.rawValue) = %@", code)
        let currencies = try context.fetch(fetchRequest)
        if currencies.isEmpty {
            return nil
        } else {
            return currencies[0]
        }
    }

    static func getCurrencyForISO4217(_ iso4217: Int16, context: NSManagedObjectContext) throws -> Currency? {
        let fetchRequest = fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Currency.iso4217.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Currency.iso4217.rawValue) = \(iso4217)")
        let currencies = try context.fetch(fetchRequest)
        if currencies.isEmpty {
            return nil
        } else {
            return currencies[0]
        }
    }

    static func setAccountingCurrency(_ currency: Currency, modifyDate: Date = Date(),
                                      modifiedByUser: Bool = true, context: NSManagedObjectContext) throws {
        currency.isAccounting = true
        currency.modifyDate = modifyDate
        currency.modifiedByUser = modifiedByUser
    }

    static func getAccountingCurrency(context: NSManagedObjectContext) -> Currency? {
        let fetchRequest = fetchRequest()
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
