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

    static func isFreeCurrencyCode(_ code: String, context: NSManagedObjectContext) -> Bool {
        let fetchRequest = fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Currency.code.rawValue, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Currency.code.rawValue) = %@", code)
        do {
            let currencies = try context.fetch(fetchRequest)
            if currencies.isEmpty {
                return true
            } else {
                return false
            }
        } catch let error {
            print("ERROR", error)
            return false
        }
    }

    static func createAndGet(code: String, iso4217: Int16, name: String?, createdByUser: Bool = true,
                             createDate: Date = Date(), context: NSManagedObjectContext) throws -> Currency {
        guard isFreeCurrencyCode(code, context: context) == true else {
            throw CurrencyError.thisCurrencyAlreadyExists
        }
        return Currency(code: code, iso4217: iso4217, name: name, createdByUser: createdByUser,
                        createDate: createDate, context: context)
    }

    static func create(code: String, iso4217: Int16, name: String?, createdByUser: Bool = true,
                       context: NSManagedObjectContext) throws {
        _ = try createAndGet(code: code, iso4217: iso4217, name: name, createdByUser: createdByUser,
                                 context: context)
    }

    func delete() throws {
        guard self.accountsList.count == 0 else {
            throw CurrencyError.thisCurrencyUsedInAccounts
        }
        guard self.isAccounting else {
            throw CurrencyError.thisIsAccountingCurrency
        }
        managedObjectContext?.delete(self)
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

    // FIXME: - need to create new predicate how to check is it awailiable to change accounting currency
    static func accountingCurrencyCanBeChanged(context: NSManagedObjectContext) throws -> Bool {
        let fetchRequest = TransactionItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.TransactionItem.createDate.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.TransactionItem.account.rawValue).\(Schema.Account.currency).\(Schema.Currency.isAccounting.rawValue) = false")

        if try context.fetch(fetchRequest).isEmpty {
            return true
        } else {
            let transactionItems = try context.fetch(fetchRequest)
            for itemInForeignCurrency in transactionItems {
                guard let items = itemInForeignCurrency.transaction?.itemsList else {return false}
                for item in items where item.account!.currency!.isAccounting == true {
                    return false
                }
            }
            return true
        }
    }

    static func changeAccountingCurrency(old oldCurr: Currency?, new newCurr: Currency, modifyDate: Date = Date(),
                                         modifiedByUser: Bool = true, context: NSManagedObjectContext) throws {
        if let oldCurr = oldCurr {
            guard try accountingCurrencyCanBeChanged(context: context)
            else {throw CurrencyError.thisCurrencyAlreadyUsedInTransaction}

            try Account.changeCurrencyForBaseAccounts(to: newCurr, modifyDate: modifyDate,
                                                      modifiedByUser: modifiedByUser, context: context)
            oldCurr.isAccounting = false
            oldCurr.modifyDate = modifyDate
            oldCurr.modifiedByUser = modifiedByUser

            newCurr.isAccounting = true
            newCurr.modifyDate = modifyDate
            newCurr.modifiedByUser = modifiedByUser
        } else {
            try Account.changeCurrencyForBaseAccounts(to: newCurr, context: context)
            newCurr.isAccounting = true
            newCurr.modifyDate = modifyDate
            newCurr.modifiedByUser = modifiedByUser
        }
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
