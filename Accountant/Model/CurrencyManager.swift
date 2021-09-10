//
//  CurrencyManager.swift
//  Accounting
//
//  Created by Roman Topchii on 31.12.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation
import CoreData

class CurrencyManager {
    
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
    
    static func createAndGetCurrency(code: String, name: String?, createdByUser : Bool = true, context: NSManagedObjectContext) throws -> Currency{
        guard isFreeCurrencyCode(code,context: context) == true else {
            throw CurrencyError.thisCurrencyAlreadyExists
        }
        let date = Date()
        let currency = Currency(context: context)
        currency.createdByUser = createdByUser
        currency.createDate = date
        currency.modifiedByUser = createdByUser
        currency.modifyDate = date
        currency.code = code  //ISO code
        currency.name = name
        return currency
    }
    
    
    static func createCurrency(code: String, name: String?, createdByUser : Bool = true, context: NSManagedObjectContext) throws {
        try createAndGetCurrency(code: code, name: name, createdByUser : createdByUser, context: context)
    }
    
    static func removeCurrency(_ currency: Currency, context: NSManagedObjectContext) throws {
        guard currency.accounts?.allObjects.count == 0 else {
            throw CurrencyError.thisCurrencyUsedInAccounts
        }
        guard currency.isAccounting else {
            throw CurrencyError.thisIsAccountingCurrency
        }
        context.delete(currency)
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
    
    
    //FIXME:- need to create new predicate how to check is it awailiable to change accounting currency
    static func accountingCurrencyCanBeChanged(context: NSManagedObjectContext) throws -> Bool {
        let currencyFetchRequest : NSFetchRequest<TransactionItem> = NSFetchRequest<TransactionItem>(entityName: "TransactionItem")
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
            try AccountManager.changeCurrencyForBaseAccounts(to: newCurr, modifyDate: modifyDate, modifiedByUser: modifiedByUser, context: context)
            oldCurr.isAccounting = false
            oldCurr.modifyDate = modifyDate
            oldCurr.modifiedByUser = modifiedByUser
            
            newCurr.isAccounting = true
            newCurr.modifyDate = modifyDate
            newCurr.modifiedByUser = modifiedByUser
        }
        else {
            try AccountManager.changeCurrencyForBaseAccounts(to: newCurr, context: context)
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
    static func deleteAllCurrencies(context: NSManagedObjectContext) throws {
        let currencyFetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: Currency.entity().name!)
        currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true)]
        
        let currencies = try context.fetch(currencyFetchRequest)
        currencies.forEach({
            context.delete($0)
        })
        
    }
    
    static func addCurrencies(context: NSManagedObjectContext) {
        let currencies = [
            "AUD", "CAD", "CNY", "HRK", "CZK", "DKK", "HKD", "HUF", "INR", "IDR", "ILS", "JPY", "KZT", "KRW", "MXN", "MDL", "NZD", "NOK", "RUB", "SAR", "SGD", "ZAR", "SEK", "CHF", "EGP", "GBP", "UAH", "USD", "BYN", "AZN", "RON", "TRY", "BGN", "EUR", "PLN", "DZD", "BDT", "AMD", "IRR", "IQD", "KGS", "LBP", "LYD", "MYR", "MAD", "VND", "THB", "AED", "TND", "UZS", "TWD", "TMT", "GHS", "RSD", "TJS", "GEL", "BRL"]
        currencies.forEach({
            try? createCurrency(code: $0, name: nil, createdByUser: false, context: context)
        })
    }
}
