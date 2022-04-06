//
//  SeedDataManager.swift
//  Accounting
//
//  Created by Roman Topchii on 03.01.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import Foundation
import CoreData
import Charts

class SeedDataManager {
    
    static func addCurrencies(context: NSManagedObjectContext) {
        let currencies = [(code: "UAH", iso4217: 980), (code: "AUD", iso4217: 36), (code: "CAD", iso4217: 124), (code: "CNY", iso4217: 156), (code: "HRK", iso4217: 191), (code: "CZK", iso4217: 203), (code: "DKK", iso4217: 208), (code: "HKD", iso4217: 344), (code: "HUF", iso4217: 348), (code: "INR", iso4217: 356), (code: "IDR", iso4217: 360), (code: "ILS", iso4217: 376), (code: "JPY", iso4217: 392), (code: "KZT", iso4217: 398), (code: "KRW", iso4217: 410), (code: "MXN", iso4217: 484), (code: "MDL", iso4217: 498), (code: "NZD", iso4217: 554), (code: "NOK", iso4217: 578), (code: "RUB", iso4217: 643), (code: "SAR", iso4217: 682), (code: "SGD", iso4217: 702), (code: "ZAR", iso4217: 710), (code: "SEK", iso4217: 752), (code: "CHF", iso4217: 756), (code: "EGP", iso4217: 818), (code: "GBP", iso4217: 826), (code: "USD", iso4217: 840), (code: "BYN", iso4217: 933), (code: "RON", iso4217: 946), (code: "TRY", iso4217: 949), (code: "BGN", iso4217: 975), (code: "EUR", iso4217: 978), (code: "PLN", iso4217: 985), (code: "DZD", iso4217: 12), (code: "BDT", iso4217: 50), (code: "AMD", iso4217: 51), (code: "IRR", iso4217: 364), (code: "IQD", iso4217: 368), (code: "KGS", iso4217: 417), (code: "LBP", iso4217: 422), (code: "LYD", iso4217: 434), (code: "MYR", iso4217: 458), (code: "MAD", iso4217: 504), (code: "PKR", iso4217: 586), (code: "VND", iso4217: 704), (code: "THB", iso4217: 764), (code: "AED", iso4217: 784), (code: "TND", iso4217: 788), (code: "UZS", iso4217: 860), (code: "TMT", iso4217: 934), (code: "RSD", iso4217: 941), (code: "AZN", iso4217: 944), (code: "TJS", iso4217: 972), (code: "GEL", iso4217: 981), (code: "BRL", iso4217: 986)]
        
        
        currencies.forEach({
            try? Currency.createCurrency(code: $0.code, iso4217: Int16($0.iso4217), name: nil, createdByUser: false, context: context)
        })
    }
    
    static func createDefaultKeepers(context: NSManagedObjectContext) {
        try? Keeper.createKeeper(name: NSLocalizedString("Cash", comment: ""), type: .cash, createdByUser: false, context: context)
        try? Keeper.createKeeper(name: NSLocalizedString("Monobank",comment: ""), type: .bank, createdByUser: false, context: context)
    }
    
    static func createTestKeepers(context: NSManagedObjectContext) throws {
        try Keeper.createKeeper(name: NSLocalizedString("Cash", comment: ""), type: .cash, createdByUser: false, context: context)
        try Keeper.createKeeper(name: NSLocalizedString("Bank1", comment: ""), type: .bank, context: context)
        try Keeper.createKeeper(name: NSLocalizedString("Bank2", comment: ""), type: .bank, context: context)
        try Keeper.createKeeper(name: NSLocalizedString("Hanna", comment: ""), type: .person, context: context)
        try Keeper.createKeeper(name: NSLocalizedString("Monobank",comment: ""), type: .bank, createdByUser: false, context: context)
    }
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllKeepers(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let keeperFetchRequest : NSFetchRequest<Keeper> = NSFetchRequest<Keeper>(entityName: Keeper.entity().name!)
        keeperFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let keepers = try context.fetch(keeperFetchRequest)
        keepers.forEach({
            context.delete($0)
        })
    }
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllHolders(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let holderFetchRequest : NSFetchRequest<Holder> = NSFetchRequest<Holder>(entityName: Holder.entity().name!)
        holderFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let holders = try context.fetch(holderFetchRequest)
        holders.forEach({
            context.delete($0)
        })
        
    }
    
    static func createDefaultHolders(context: NSManagedObjectContext) {
        try? Holder.create(name: NSLocalizedString("Me", comment: ""),icon: "😎", createdByUser: false, context: context)
    }
    
    static func createTestHolders(context: NSManagedObjectContext) throws {
        try Holder.create(name: NSLocalizedString("Me", comment: ""),icon: "😎", createdByUser: false, context: context)
        try Holder.create(name: NSLocalizedString("Kate", comment: ""),icon: "👩🏻‍🦰", context: context)
    }
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllUBP(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let fetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let ubp = try context.fetch(fetchRequest)
        ubp.forEach({
            context.delete($0)
        })
    }
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllBankAccounts(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let fetchRequest : NSFetchRequest<BankAccount> = NSFetchRequest<BankAccount>(entityName: BankAccount.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let ba = try context.fetch(fetchRequest)
        ba.forEach({
            context.delete($0)
        })
    }
    
    static func addBaseAccounts(accountingCurrency: Currency, context: NSManagedObjectContext) {
        AccountsNameLocalisationManager.createAllLocalizedAccountName()
        
        try? Account.createAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.money), type: AccountType.assets.rawValue, currency: nil, createdByUser: false, context: context)
        try? Account.createAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.credits), type: AccountType.liabilities.rawValue, currency: nil, createdByUser: false, context: context)
        try? Account.createAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.debtors), type: AccountType.assets.rawValue, currency: nil, createdByUser: false, context: context)
        try? Account.createAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.capital), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        
        let expense = try? Account.createAndGetAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.expense), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: expense, name: NSLocalizedString("Food", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: expense, name: NSLocalizedString("Transport", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: expense, name: NSLocalizedString("Gifts", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let home = try? Account.createAndGetAccount(parent: expense, name: NSLocalizedString("Home", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: home, name: NSLocalizedString("Utility", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: home, name: NSLocalizedString("Rent", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: home, name: NSLocalizedString("Renovation", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        
        
        let income = try? Account.createAndGetAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.income), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: income, name: NSLocalizedString("Salary", comment: ""), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: income, name: NSLocalizedString("Gifts", comment: ""), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: income, name: NSLocalizedString("Interest on deposits", comment: ""), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        
    }
    
    
    static func addBaseAccountsTest(accountingCurrency: Currency, context: NSManagedObjectContext) {
        AccountsNameLocalisationManager.createAllLocalizedAccountName()
        
        //MARK: - Get keepers
        let bank1 = try? Keeper.getKeeperForName(NSLocalizedString("Bank1", comment: ""), context: context)
        let bank2 = try? Keeper.getKeeperForName(NSLocalizedString("Bank2", comment: ""), context: context)
        let hanna = try? Keeper.getKeeperForName(NSLocalizedString("Hanna", comment: ""), context: context)
        let cashKeeper = try? Keeper.getCashKeeper(context: context)
        
        let me = try? Holder.get(NSLocalizedString("Me", comment: ""), context: context)
        let kate = try? Holder.get(NSLocalizedString("Kate", comment: ""), context: context)
        
        
        let money = try? Account.createAndGetAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.money), type: AccountType.assets.rawValue, currency: nil, createdByUser: false, context: context)
        
        let credits = try? Account.createAndGetAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.credits), type: AccountType.liabilities.rawValue, currency: nil, createdByUser: false, context: context)
        let debtors = try? Account.createAndGetAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.debtors), type: AccountType.assets.rawValue, currency: nil, createdByUser: false, context: context)
        let capital = try? Account.createAndGetAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.capital), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        
        let deposit = try? Account.createAndGetAccount(parent: debtors, name: NSLocalizedString("Deposit", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, keeper: bank1, holder: me, createdByUser: false, context: context)
        let lend = try? Account.createAndGetAccount(parent: debtors, name: NSLocalizedString("Hanna", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, keeper: hanna, holder: me, createdByUser: false, context: context)
        
        let salaryCard = try? Account.createAndGetAccount(parent: money, name: NSLocalizedString("Salary card", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, keeper: bank2, holder: me, subType: AccountSubType.debitCard.rawValue, createdByUser: false, context: context)
        let cash = try? Account.createAndGetAccount(parent: money, name: NSLocalizedString("Cash", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, keeper: cashKeeper, holder: kate, subType: AccountSubType.cash.rawValue, createdByUser: false, context: context)
        
        let creditcard_A = try? Account.createAndGetAccount(parent: money, name: NSLocalizedString("Credit card", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, keeper: bank1, holder: me, subType: AccountSubType.creditCard.rawValue, createdByUser: false, context: context)
        let creditcard_L = try? Account.createAndGetAccount(parent: credits, name: NSLocalizedString("Credit card", comment: ""), type: AccountType.liabilities.rawValue, currency: accountingCurrency, keeper: bank1, holder: me, createdByUser: false, context: context)
        creditcard_A?.linkedAccount = creditcard_L
        
        let expense = try? Account.createAndGetAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.expense), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let food = try? Account.createAndGetAccount(parent: expense, name: NSLocalizedString("Food", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let transport = try? Account.createAndGetAccount(parent: expense, name: NSLocalizedString("Transport", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let gifts_E = try? Account.createAndGetAccount(parent: expense, name: NSLocalizedString("Gifts", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let home = try? Account.createAndGetAccount(parent: expense, name: NSLocalizedString("Home", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let utility = try? Account.createAndGetAccount(parent: home, name: NSLocalizedString("Utility", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let rent = try? Account.createAndGetAccount(parent: home, name: NSLocalizedString("Rent", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let renovation = try? Account.createAndGetAccount(parent: home, name: NSLocalizedString("Renovation", comment: ""), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        
        
        let income = try? Account.createAndGetAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.income), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let salary = try? Account.createAndGetAccount(parent: income, name: NSLocalizedString("Salary", comment: ""), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let gifts_I = try? Account.createAndGetAccount(parent: income, name: NSLocalizedString("Gifts", comment: ""), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        let interestOnDeposits = try? Account.createAndGetAccount(parent: income, name: NSLocalizedString("Interest on deposits", comment: ""), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        
        
        let calendar = Calendar.current
        
        
        
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                          debit: deposit!,
                                          credit: capital!,
                                          debitAmount: 50000,
                                          creditAmount: 50000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                          debit: creditcard_A!,
                                          credit: creditcard_L!,
                                          debitAmount: 5000,
                                          creditAmount: 5000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                          debit: cash!,
                                          credit: capital!,
                                          debitAmount: 2000,
                                          creditAmount: 2000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                          debit: salaryCard!,
                                          credit: capital!,
                                          debitAmount: 20000,
                                          creditAmount: 20000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -59, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -55, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 800,
                                          creditAmount: 800,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -50, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -49, to: Date())!,
                                          debit: cash!,
                                          credit: salaryCard!,
                                          debitAmount: 4000,
                                          creditAmount: 4000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -47, to: Date())!,
                                          debit: gifts_E!,
                                          credit: cash!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -46, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 200,
                                          creditAmount: 200,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -44, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -42, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 500,
                                          creditAmount: 500,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -40, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -39, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 100,
                                          creditAmount: 100,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -38, to: Date())!,
                                          debit: cash!,
                                          credit: salaryCard!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -37, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -36, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -35, to: Date())!,
                                          debit: rent!,
                                          credit: cash!,
                                          debitAmount: 5000,
                                          creditAmount: 5000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -34, to: Date())!,
                                          debit: utility!,
                                          credit: salaryCard!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -32, to: Date())!,
                                          debit: salaryCard!,
                                          credit: salary!,
                                          debitAmount: 20000,
                                          creditAmount: 20000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -31, to: Date())!,
                                          debit: salaryCard!,
                                          credit: interestOnDeposits!,
                                          debitAmount: 200,
                                          creditAmount: 200,
                                          context: context)
        
        
        
        
        
        
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -29, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -25, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 800,
                                          creditAmount: 800,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -20, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -19, to: Date())!,
                                          debit: cash!,
                                          credit: salaryCard!,
                                          debitAmount: 4000,
                                          creditAmount: 4000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -17, to: Date())!,
                                          debit: gifts_E!,
                                          credit: cash!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -16, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 200,
                                          creditAmount: 200,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -14, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -12, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 500,
                                          creditAmount: 500,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -10, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -9, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 100,
                                          creditAmount: 100,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -8, to: Date())!,
                                          debit: cash!,
                                          credit: salaryCard!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -7, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -6, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -5, to: Date())!,
                                          debit: rent!,
                                          credit: cash!,
                                          debitAmount: 5000,
                                          creditAmount: 5000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -4, to: Date())!,
                                          debit: utility!,
                                          credit: salaryCard!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -2, to: Date())!,
                                          debit: salaryCard!,
                                          credit: salary!,
                                          debitAmount: 20000,
                                          creditAmount: 20000,
                                          context: context)
        Transaction.addTransactionWith2TranItems(date: calendar.date(byAdding: .day, value: -1, to: Date())!,
                                          debit: salaryCard!,
                                          credit: interestOnDeposits!,
                                          debitAmount: 200,
                                          creditAmount: 200,
                                          context: context)
    }
}
