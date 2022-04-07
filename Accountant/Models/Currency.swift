//
//  Currency.swift
//  Accounting
//
//  Created by Roman Topchii on 31.12.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation
import CoreData

final class Currency: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Currency> {
        return NSFetchRequest<Currency>(entityName: "Currency")
    }
    
    @NSManaged public var code: String?
    @NSManaged public var createDate: Date?
    @NSManaged public var createdByUser: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var isAccounting: Bool
    @NSManaged public var iso4217: Int16
    @NSManaged public var modifiedByUser: Bool
    @NSManaged public var modifyDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var accounts: NSSet?
    @NSManaged public var exchangeRates: NSSet?
    
    static func isFreeCurrencyCode(_ code : String, context: NSManagedObjectContext) -> Bool {
        let currencyFetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: "Currency")
        currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: false)]
        currencyFetchRequest.predicate = NSPredicate(format: "code = %@", code)
        do {
            let currencies = try context.fetch(currencyFetchRequest)
            if currencies.isEmpty {
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
    
    static func createAndGetCurrency(code: String, iso4217: Int16, name: String?, createdByUser : Bool = true, context: NSManagedObjectContext) throws -> Currency {
        guard isFreeCurrencyCode(code,context: context) == true else {
            throw CurrencyError.thisCurrencyAlreadyExists
        }
        let date = Date()
        let currency = Currency(context: context)
        currency.id = UUID()
        currency.createdByUser = createdByUser
        currency.createDate = date
        currency.modifiedByUser = createdByUser
        currency.modifyDate = date
        currency.code = code  //UAH
        currency.iso4217 = iso4217  //980
        currency.name = name
        return currency
    }
    
    
    static func createCurrency(code: String, iso4217: Int16, name: String?, createdByUser : Bool = true, context: NSManagedObjectContext) throws {
        try createAndGetCurrency(code: code, iso4217: iso4217, name: name, createdByUser : createdByUser, context: context)
    }
    
    func removeCurrency(context: NSManagedObjectContext) throws {
        guard self.accounts?.allObjects.count == 0 else {
            throw CurrencyError.thisCurrencyUsedInAccounts
        }
        guard self.isAccounting else {
            throw CurrencyError.thisIsAccountingCurrency
        }
        context.delete(self)
    }
    
    static func getCurrencyForCode(_ code : String, context: NSManagedObjectContext) throws -> Currency? {
        let currencyFetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: Currency.entity().name!)
        currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true)]
        currencyFetchRequest.predicate = NSPredicate(format: "code = %@", code)
        let currencies = try context.fetch(currencyFetchRequest)
        if currencies.isEmpty {
            return nil
        }
        else {
            return currencies[0]
        }
    }
    
    static func getCurrencyForISO4217(_ iso4217 : Int16, context: NSManagedObjectContext) throws -> Currency? {
        let currencyFetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: Currency.entity().name!)
        currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "iso4217", ascending: true)]
        currencyFetchRequest.predicate = NSPredicate(format: "iso4217 = \(iso4217)")
        let currencies = try context.fetch(currencyFetchRequest)
        if currencies.isEmpty {
            return nil
        }
        else {
            return currencies[0]
        }
    }
    
    
    //FIXME:- need to create new predicate how to check is it awailiable to change accounting currency
    static func accountingCurrencyCanBeChanged(context: NSManagedObjectContext) throws -> Bool {
        let currencyFetchRequest : NSFetchRequest<TransactionItem> = NSFetchRequest<TransactionItem>(entityName: TransactionItem.entity().name!)
        currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        currencyFetchRequest.predicate = NSPredicate(format: "account.currency.isAccounting = false")
        
        if try context.fetch(currencyFetchRequest).isEmpty {
            return true
        }
        else {
            let transactionItems = try context.fetch(currencyFetchRequest)
            for itemInForeignCurrency in transactionItems {
                for item in itemInForeignCurrency.transaction?.items?.allObjects as! [TransactionItem] {
                    if item.account!.currency!.isAccounting == true {
                        return false
                    }
                }
            }
            return true
        }
    }
    
    
    static func changeAccountingCurrency(old oldCurr: Currency?, new newCurr: Currency, modifyDate: Date = Date(), modifiedByUser: Bool = true, context: NSManagedObjectContext) throws {
        if let oldCurr = oldCurr {
            guard try accountingCurrencyCanBeChanged(context: context) else {throw CurrencyError.thisCurrencyAlreadyUsedInTransaction}
            try Account.changeCurrencyForBaseAccounts(to: newCurr, modifyDate: modifyDate, modifiedByUser: modifiedByUser, context: context)
            oldCurr.isAccounting = false
            oldCurr.modifyDate = modifyDate
            oldCurr.modifiedByUser = modifiedByUser
            
            newCurr.isAccounting = true
            newCurr.modifyDate = modifyDate
            newCurr.modifiedByUser = modifiedByUser
        }
        else {
            try Account.changeCurrencyForBaseAccounts(to: newCurr, context: context)
            newCurr.isAccounting = true
            newCurr.modifyDate = modifyDate
            newCurr.modifiedByUser = modifiedByUser
        }
    }
    
    
    
    static func getAccountingCurrency(context: NSManagedObjectContext) -> Currency? {
        let currencyFetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: Currency.entity().name!)
        currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true)]
        currencyFetchRequest.predicate = NSPredicate(format: "isAccounting = true")
        do{
            let currencies = try context.fetch(currencyFetchRequest)
            if currencies.isEmpty == false {
                return currencies.first!
            }
            else {
                return nil
            }
        }
        catch let error {
            print("ERROR", error)
            return nil
        }
    }
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllCurrencies(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let currencyFetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: Currency.entity().name!)
        currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true)]
        
        let currencies = try context.fetch(currencyFetchRequest)
        currencies.forEach({
            context.delete($0)
        })
        
    }
}
