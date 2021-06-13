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
    // MARK: - Currency
    
    static func isFreeCurrencyName(_ name : String, context: NSManagedObjectContext) -> Bool {
        let currencyFetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: "Currency")
        currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: false)]
        currencyFetchRequest.predicate = NSPredicate(format: "code = %@", name)
        do{
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
    
    static func createAndGetCurrency(code: String, name: String, createdByUser : Bool = true, context: NSManagedObjectContext) throws -> Currency{
        guard isFreeCurrencyName(name,context: context) == true else {
            throw CurrencyError.thisCurrencyAlreadyExists
        }
        let currency = Currency(context: context)
        currency.createdByUser = createdByUser
        currency.createDate = Date()
        currency.code = code  //ISO code
        currency.name = name
        return currency
    }
    
    
    static func createCurrency(code: String, name: String, createdByUser : Bool = true, context: NSManagedObjectContext) throws {
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
        let currencyFetchRequest : NSFetchRequest<Transaction> = NSFetchRequest<Transaction>(entityName: "Transaction")
        currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        currencyFetchRequest.predicate = NSPredicate(format: "(creditAccount.currency.isAccounting = true && debitAccount.currency.isAccounting = false) || (creditAccount.currency.isAccounting == false && debitAccount.currency.isAccounting = true)")
        currencyFetchRequest.fetchBatchSize = 1
        currencyFetchRequest.fetchLimit = 1
        if try context.fetch(currencyFetchRequest).isEmpty {
            return true
        }
        else {
            return false
        }
    }
    
    
    static func changeAccountingCurrency(old oldCurr: Currency?, new newCurr: Currency, context: NSManagedObjectContext) throws {
        try AccountManager.changeCurrencyForBaseAccounts(to: newCurr, context: context)
        if let oldCurr = oldCurr {
            guard try accountingCurrencyCanBeChanged(context: context) else {throw CurrencyError.thisCurrencyAlreadyUsedInTransaction}
            oldCurr.isAccounting = false
            newCurr.isAccounting = true
        }
        else {
            newCurr.isAccounting = true
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
    
    static func addCurrencies(context: NSManagedObjectContext) {
        let currencies = [("AUD", "Австралійський долар"), ("CAD", "Канадський долар"), ("CNY", "Юань Женьміньбі"), ("HRK", "Куна"), ("CZK", "Чеська крона"), ("DKK", "Данська крона"), ("HKD", "Гонконгівський долар"), ("HUF", "Форинт"), ("INR", "Індійська рупія"), ("IDR", "Рупія"), ("ILS", "Новий ізраїльський шекель"), ("JPY", "Єна"), ("KZT", "Теньге"), ("KRW", "Вона"), ("MXN", "Мексиканське песо"), ("MDL", "Молдовський лей"), ("NZD", "Новозеландський долар"), ("NOK", "Норвезька крона"), ("RUB", "Російський рубль"), ("SAR", "Саудівський ріял"), ("SGD", "Сінгапурський долар"), ("ZAR", "Ренд"), ("SEK", "Шведська крона"), ("CHF", "Швейцарський франк"), ("EGP", "Єгипетський фунт"), ("GBP", "Фунт стерлінгів"), ("UAH", "Гривня"), ("USD", "Долар США"), ("BYN", "Білоруський рубль"), ("AZN", "Азербайджанський манат"), ("RON", "Румунський лей"), ("TRY", "Турецька ліра"), ("BGN", "Болгарський лев"), ("EUR", "Євро"), ("PLN", "Злотий"), ("DZD", "Алжирський динар"), ("BDT", "Така"), ("AMD", "Вірменський драм"), ("IRR", "Іранський ріал"), ("IQD", "Іракський динар"), ("KGS", "Сом"), ("LBP", "Ліванський фунт"), ("LYD", "Лівійський динар"), ("MYR", "Малайзійський ринггіт"), ("MAD", "Марокканський дирхам"), ("VND", "Донг"), ("THB", "Бат"), ("AED", "Дирхам ОАЕ"), ("TND", "Туніський динар"), ("UZS", "Узбецький сум"), ("TWD", "Новий тайванський долар"), ("TMT", "Туркменський новий манат"), ("GHS", "Ганське седі"), ("RSD", "Сербський динар"), ("TJS", "Сомоні"), ("GEL", "Ларі"), ("BRL", "Бразильський реал")]//, ("XAU", "Золото"), ("XAG", "Срібло"), ("XPT", "Платина"), ("XPD", "Паладій")]
        
        currencies.forEach({
            try? createCurrency(code: $0.0, name: $0.1, createdByUser: false, context: context)
        })
    }

}
