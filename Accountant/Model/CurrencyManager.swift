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
    
    static func createAndGetCurrency(code: String, iso4217: Int16, name: String?, createdByUser : Bool = true, context: NSManagedObjectContext) throws -> Currency{
        guard isFreeCurrencyCode(code,context: context) == true else {
            throw CurrencyError.thisCurrencyAlreadyExists
        }
        let date = Date()
        let currency = Currency(context: context)
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
    static func deleteAllCurrencies(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let currencyFetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: Currency.entity().name!)
        currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true)]
        
        let currencies = try context.fetch(currencyFetchRequest)
        currencies.forEach({
            context.delete($0)
        })
        
    }
    
    static func addCurrencies(context: NSManagedObjectContext) {
        let currencies = [(code: "UAH", iso4217: 980), (code: "AUD", iso4217: 36), (code: "CAD", iso4217: 124), (code: "CNY", iso4217: 156), (code: "HRK", iso4217: 191), (code: "CZK", iso4217: 203), (code: "DKK", iso4217: 208), (code: "HKD", iso4217: 344), (code: "HUF", iso4217: 348), (code: "INR", iso4217: 356), (code: "IDR", iso4217: 360), (code: "ILS", iso4217: 376), (code: "JPY", iso4217: 392), (code: "KZT", iso4217: 398), (code: "KRW", iso4217: 410), (code: "MXN", iso4217: 484), (code: "MDL", iso4217: 498), (code: "NZD", iso4217: 554), (code: "NOK", iso4217: 578), (code: "RUB", iso4217: 643), (code: "SAR", iso4217: 682), (code: "SGD", iso4217: 702), (code: "ZAR", iso4217: 710), (code: "SEK", iso4217: 752), (code: "CHF", iso4217: 756), (code: "EGP", iso4217: 818), (code: "GBP", iso4217: 826), (code: "USD", iso4217: 840), (code: "BYN", iso4217: 933), (code: "RON", iso4217: 946), (code: "TRY", iso4217: 949), (code: "XDR", iso4217: 960), (code: "BGN", iso4217: 975), (code: "EUR", iso4217: 978), (code: "PLN", iso4217: 985), (code: "DZD", iso4217: 12), (code: "BDT", iso4217: 50), (code: "AMD", iso4217: 51), (code: "IRR", iso4217: 364), (code: "IQD", iso4217: 368), (code: "KGS", iso4217: 417), (code: "LBP", iso4217: 422), (code: "LYD", iso4217: 434), (code: "MYR", iso4217: 458), (code: "MAD", iso4217: 504), (code: "PKR", iso4217: 586), (code: "VND", iso4217: 704), (code: "THB", iso4217: 764), (code: "AED", iso4217: 784), (code: "TND", iso4217: 788), (code: "UZS", iso4217: 860), (code: "TMT", iso4217: 934), (code: "RSD", iso4217: 941), (code: "AZN", iso4217: 944), (code: "TJS", iso4217: 972), (code: "GEL", iso4217: 981), (code: "BRL", iso4217: 986)]
        
        
        currencies.forEach({
            try? createCurrency(code: $0.code, iso4217: Int16($0.iso4217), name: nil, createdByUser: false, context: context)
        })
    }
}
