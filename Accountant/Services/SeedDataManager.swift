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

// swiftlint:disable all
class SeedDataManager {

    static func refreshTestData(coreDataStack: CoreDataStack) throws {
        try SeedDataManager.clearAllData(coreDataStack: coreDataStack)
        try SeedDataManager.addTestData(coreDataStack: coreDataStack)
    }
    
    static func clearAllData(coreDataStack: CoreDataStack) throws {
        guard let env = coreDataStack.activeEnviroment()else {return}
        let context = coreDataStack.persistentContainer.viewContext
        try deleteAllTransactions(context: context, env: env)
        try deleteAllAccounts(context: context, env: env)
        try deleteAllCurrencies(context: context, env: env)
        try deleteAllKeepers(context: context, env: env)
        try deleteAllHolders(context: context, env: env)
        try deleteAllBankAccounts(context: context, env: env)
        try deleteAllUBP(context: context, env: env)
        try deleteAllRates(context: context, env: env)
        try deleteAllExchanges(context: context, env: env)
        try CoreDataStack.shared.saveContext(context)
    }

    static public func addTestData(coreDataStack: CoreDataStack) throws {
        guard let env = coreDataStack.activeEnviroment(), env == .test else {return}
        let context = coreDataStack.persistentContainer.viewContext
        addCurrencies(context: context)
        guard let currency = try Currency.getCurrencyForCode("UAH", context: context) else {return}
        try Currency.setAccountingCurrency(currency, context: context)
        addTestKeepers(context: context)
        addTestHolders(context: context)
        try addTestBaseAccountsWithTransaction(accountingCurrency: currency, context: context)
        try CoreDataStack.shared.saveContext(context)
    }

    static public func createCurrenciesHoldersKeepers(coreDataStack: CoreDataStack) throws {
        let context = coreDataStack.persistentContainer.viewContext
        addCurrencies(context: context)
        addHolders(context: context)
        addKeepers(context: context)
    }

    // MARK: - Account
    static public func addBaseAccounts(accountingCurrency: Currency, context: NSManagedObjectContext) {
        LocalisationManager.createAllLocalizedAccountName()

        try? Account.createAccount(parent: nil, name: LocalisationManager.getLocalizedName(.money), type: Account.TypeEnum.assets, currency: nil, createdByUser: false, context: context)
        try? Account.createAccount(parent: nil, name: LocalisationManager.getLocalizedName(.credits), type: Account.TypeEnum.liabilities, currency: nil, createdByUser: false, context: context)
        try? Account.createAccount(parent: nil, name: LocalisationManager.getLocalizedName(.debtors), type: Account.TypeEnum.assets, currency: nil, createdByUser: false, context: context)
        try? Account.createAccount(parent: nil, name: LocalisationManager.getLocalizedName(.capital), type: Account.TypeEnum.liabilities, currency: accountingCurrency, createdByUser: false, context: context)

        let expense = try? Account.createAndGetAccount(parent: nil, name: LocalisationManager.getLocalizedName(.expense), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: expense, name: NSLocalizedString("Food", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: expense, name: NSLocalizedString("Transport", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: expense, name: NSLocalizedString("Gifts", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        let home = try? Account.createAndGetAccount(parent: expense, name: NSLocalizedString("Home", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: home, name: NSLocalizedString("Utility", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: home, name: NSLocalizedString("Rent", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: home, name: NSLocalizedString("Renovation", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)

        let income = try? Account.createAndGetAccount(parent: nil, name: LocalisationManager.getLocalizedName(.income), type: Account.TypeEnum.liabilities, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: income, name: NSLocalizedString("Salary", comment: ""), type: Account.TypeEnum.liabilities, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: income, name: NSLocalizedString("Gifts", comment: ""), type: Account.TypeEnum.liabilities, currency: accountingCurrency, createdByUser: false, context: context)
        try? Account.createAccount(parent: income, name: NSLocalizedString("Interest on deposits", comment: ""), type: Account.TypeEnum.liabilities, currency: accountingCurrency, createdByUser: false, context: context)
    }
    
    private static func deleteAllAccounts(context: NSManagedObjectContext, env: Environment?) throws {
        let fetchRequest = Account.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        let accounts = try context.fetch(fetchRequest)
        accounts.forEach({
            context.delete($0)
        })
    }

    // MARK: - Currency
    private static func addCurrencies(context: NSManagedObjectContext) {
        let dataProvider = CurrencyProvider(with: CoreDataStack.shared.persistentContainer)
        /*
            symbols added based on
            https://www.eurochange.co.uk/travel-money/world-currency-abbreviations-symbols-and-codes-travel-money
        */
        let currencies = [(code: "UAH", iso4217: 980, symbol:"₴"),
                          (code: "AUD", iso4217: 36, symbol:"$"),
                          (code: "CAD", iso4217: 124, symbol:"$"),
                          (code: "CNY", iso4217: 156, symbol:"¥"),
                          (code: "HRK", iso4217: 191, symbol:"kn"),
                          (code: "CZK", iso4217: 203, symbol:"Kč"),
                          (code: "DKK", iso4217: 208, symbol:"kr"),
                          (code: "HKD", iso4217: 344, symbol:"$"),
                          (code: "HUF", iso4217: 348, symbol:"Ft"),
                          (code: "INR", iso4217: 356, symbol:"₹"),
                          (code: "IDR", iso4217: 360, symbol:"Rp"),
                          (code: "ILS", iso4217: 376, symbol:"₪"),
                          (code: "JPY", iso4217: 392, symbol:"¥"),
                          (code: "KZT", iso4217: 398, symbol:"лв"),
                          (code: "KRW", iso4217: 410, symbol:"₩"),
                          (code: "MXN", iso4217: 484, symbol:"$"),
                          (code: "MDL", iso4217: 498, symbol:"L"),
                          (code: "NZD", iso4217: 554, symbol:"$"),
                          (code: "NOK", iso4217: 578, symbol:"kr"),
                          (code: "RUB", iso4217: 643, symbol:"₽"),
                          (code: "SAR", iso4217: 682, symbol:"﷼"),
                          (code: "SGD", iso4217: 702, symbol:"$"),
                          (code: "ZAR", iso4217: 710, symbol:"R"),
                          (code: "SEK", iso4217: 752, symbol:"kr"),
                          (code: "CHF", iso4217: 756, symbol:"CHF"),
                          (code: "EGP", iso4217: 818, symbol:"£"),
                          (code: "GBP", iso4217: 826, symbol:"£"),
                          (code: "USD", iso4217: 840, symbol:"$"),
                          (code: "BYN", iso4217: 933, symbol:"Br"),
                          (code: "RON", iso4217: 946, symbol:"lei"),
                          (code: "TRY", iso4217: 949, symbol:"₺"),
                          (code: "BGN", iso4217: 975, symbol:"лв"),
                          (code: "EUR", iso4217: 978, symbol:"€"),
                          (code: "PLN", iso4217: 985, symbol:"zł"),
                          (code: "DZD", iso4217: 12, symbol:"DZD"), // symbol not found
                          (code: "BDT", iso4217: 50, symbol:"BDT"), // symbol not found
                          (code: "AMD", iso4217: 51, symbol:"AMD"),
                          (code: "IRR", iso4217: 364, symbol:"﷼"),
                          (code: "IQD", iso4217: 368, symbol:"IQD"), // symbol not found
                          (code: "KGS", iso4217: 417, symbol:"лв"),
                          (code: "LBP", iso4217: 422, symbol:"£"),
                          (code: "LYD", iso4217: 434, symbol:"LYD"),
                          (code: "MYR", iso4217: 458, symbol:"RM"),
                          (code: "MAD", iso4217: 504, symbol:"MAD"),
                          (code: "PKR", iso4217: 586, symbol:"₨"),
                          (code: "VND", iso4217: 704, symbol:"₫"),
                          (code: "THB", iso4217: 764, symbol:"฿"),
                          (code: "AED", iso4217: 784, symbol:"د.إ"),
                          (code: "TND", iso4217: 788, symbol:"£"),
                          (code: "UZS", iso4217: 860, symbol:"лв"),
                          (code: "TMT", iso4217: 934, symbol:"TMT"), // symbol not found
                          (code: "RSD", iso4217: 941, symbol:"Дин"),
                          (code: "AZN", iso4217: 944, symbol:"₼"),
                          (code: "TJS", iso4217: 972, symbol:"TJS"),
                          (code: "GEL", iso4217: 981, symbol:"₾"),
                          (code: "BRL", iso4217: 986, symbol:"R$")]
        for item in currencies {
            dataProvider.addCurrency(code: item.code, iso4217: Int16(item.iso4217), name: nil, createdByUser: false, context: context)
        }
    }

    static func deleteAllCurrencies(context: NSManagedObjectContext, env: Environment?) throws {
        let fetchRequest = Currency.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true)]
        let currencies = try context.fetch(fetchRequest)
        currencies.forEach({
            context.delete($0)
        })
    }

    // MARK: - Keeper
    private static func addKeepers(context: NSManagedObjectContext) {
        let keeperProvider = KeeperProvider(with: CoreDataStack.shared.persistentContainer, fetchedResultsControllerDelegate: nil, mode: nil)
        keeperProvider.addKeeper(name: NSLocalizedString("Cash", comment: ""), type: .cash, createdByUser: false, context: context)
        keeperProvider.addKeeper(name: NSLocalizedString("Monobank",comment: ""), type: .bank, createdByUser: false, context: context)
    }
    
    private static func addTestKeepers(context: NSManagedObjectContext) {
        let keeperProvider = KeeperProvider(with: CoreDataStack.shared.persistentContainer, fetchedResultsControllerDelegate: nil, mode: nil)
        keeperProvider.addKeeper(name: NSLocalizedString("Cash", comment: ""), type: .cash, createdByUser: false, context: context)
        keeperProvider.addKeeper(name: NSLocalizedString("Bank1", comment: ""), type: .bank, context: context)
        keeperProvider.addKeeper(name: NSLocalizedString("Bank2", comment: ""), type: .bank, context: context)
        keeperProvider.addKeeper(name: NSLocalizedString("Hanna", comment: ""), type: .person, context: context)
        keeperProvider.addKeeper(name: NSLocalizedString("Monobank",comment: ""), type: .bank, createdByUser: false, context: context)
    }
    
    private static func deleteAllKeepers(context: NSManagedObjectContext, env: Environment?) throws {
        let fetchRequest = Keeper.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let keepers = try context.fetch(fetchRequest)
        keepers.forEach({
            context.delete($0)
        })
    }

    // MARK: - Holder
    private static func addHolders(context: NSManagedObjectContext) {
        let holderProvider = HolderProvider(with: CoreDataStack.shared.persistentContainer, fetchedResultsControllerDelegate: nil)
        holderProvider.addHolder(name: NSLocalizedString("Me", comment: ""), icon: "😎", createdByUser: false, context: context)
    }

    private static func addTestHolders(context: NSManagedObjectContext) {
        let holderProvider = HolderProvider(with: CoreDataStack.shared.persistentContainer, fetchedResultsControllerDelegate: nil)
        holderProvider.addHolder(name: NSLocalizedString("Me", comment: ""),icon: "😎", createdByUser: false, context: context)
        holderProvider.addHolder(name: NSLocalizedString("Kate", comment: ""), icon: "👩🏻‍🦰", context: context)
    }

    private static func deleteAllHolders(context: NSManagedObjectContext, env: Environment?) throws {
        let fetchRequest = Holder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let holders = try context.fetch(fetchRequest)
        holders.forEach({
            context.delete($0)
        })
    }
    // MARK: - UBP
    private static func deleteAllUBP(context: NSManagedObjectContext, env: Environment?) throws {
        let fetchRequest = UserBankProfile.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let ubp = try context.fetch(fetchRequest)
        ubp.forEach({
            context.delete($0)
        })
    }

    // MARK: - BankAccoutn
    private static func deleteAllBankAccounts(context: NSManagedObjectContext, env: Environment?) throws {
        let fetchRequest = BankAccount.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let bankAccounts = try context.fetch(fetchRequest)
        bankAccounts.forEach({
            context.delete($0)
        })
    }

    // MARK: - Rate
    private static func deleteAllRates(context: NSManagedObjectContext, env: Environment?) throws {
        let fetchRequest = Rate.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        let rates = try context.fetch(fetchRequest)
        rates.forEach({
            context.delete($0)
        })
    }

    // MARK: - Exchange
    private static func deleteAllExchanges(context: NSManagedObjectContext, env: Environment?) throws {
        let fetchRequest = Exchange.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        let exchanges = try context.fetch(fetchRequest)
        exchanges.forEach({
            context.delete($0)
        })
    }

    // MARK: - Transaction
    private static func deleteAllTransactions(context: NSManagedObjectContext, env: Environment?) throws {
        let fetchRequest = Transaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        let transactions = try context.fetch(fetchRequest)
        for transaction in transactions {
            for item in transaction.itemsList {
                context.delete(item)
            }
            context.delete(transaction)
        }
    }

    // MARK: - Account
    private static func addTestBaseAccountsWithTransaction(accountingCurrency: Currency,
                                                           context: NSManagedObjectContext) throws {
        LocalisationManager.createAllLocalizedAccountName()

        // MARK: - Get keepers
        let bank1 = try? Keeper.getKeeperForName(NSLocalizedString("Bank1", comment: ""), context: context)
        let bank2 = try? Keeper.getKeeperForName(NSLocalizedString("Bank2", comment: ""), context: context)
        let hanna = try? Keeper.getKeeperForName(NSLocalizedString("Hanna", comment: ""), context: context)
        let cashKeeper = try? Keeper.getCashKeeper(context: context)

        let me = try? Holder.get(NSLocalizedString("Me", comment: ""), context: context)
        let kate = try? Holder.get(NSLocalizedString("Kate", comment: ""), context: context)

        let money = try? Account.createAndGetAccount(parent: nil, name: LocalisationManager.getLocalizedName(.money), type: Account.TypeEnum.assets, currency: nil, createdByUser: false, context: context)

        let credits = try? Account.createAndGetAccount(parent: nil, name: LocalisationManager.getLocalizedName(.credits), type: Account.TypeEnum.liabilities, currency: nil, createdByUser: false, context: context)
        let debtors = try? Account.createAndGetAccount(parent: nil, name: LocalisationManager.getLocalizedName(.debtors), type: Account.TypeEnum.assets, currency: nil, createdByUser: false, context: context)
        let capital = try? Account.createAndGetAccount(parent: nil, name: LocalisationManager.getLocalizedName(.capital), type: Account.TypeEnum.liabilities, currency: accountingCurrency, createdByUser: false, context: context)

        let deposit = try? Account.createAndGetAccount(parent: debtors, name: NSLocalizedString("Deposit", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, keeper: bank1, holder: me, createdByUser: false, context: context)
        let _ = try? Account.createAndGetAccount(parent: debtors, name: NSLocalizedString("Hanna", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, keeper: hanna, holder: me, createdByUser: false, context: context)

        let salaryCard = try? Account.createAndGetAccount(parent: money, name: NSLocalizedString("Salary card", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, keeper: bank2, holder: me, subType: Account.SubTypeEnum.debitCard, createdByUser: false, context: context)
        let cash = try? Account.createAndGetAccount(parent: money, name: NSLocalizedString("Cash", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, keeper: cashKeeper, holder: kate, subType: Account.SubTypeEnum.cash, createdByUser: false, context: context)

        let creditcard_A = try? Account.createAndGetAccount(parent: money, name: NSLocalizedString("Credit card", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, keeper: bank1, holder: me, subType: Account.SubTypeEnum.creditCard, createdByUser: false, context: context)
        let creditcard_L = try? Account.createAndGetAccount(parent: credits, name: NSLocalizedString("Credit card", comment: ""), type: Account.TypeEnum.liabilities, currency: accountingCurrency, keeper: bank1, holder: me, createdByUser: false, context: context)
        creditcard_A?.linkedAccount = creditcard_L

        let expense = try? Account.createAndGetAccount(parent: nil, name: LocalisationManager.getLocalizedName(.expense), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        let food = try? Account.createAndGetAccount(parent: expense, name: NSLocalizedString("Food", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        let _ = try? Account.createAndGetAccount(parent: expense, name: NSLocalizedString("Transport", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        let gifts_E = try? Account.createAndGetAccount(parent: expense, name: NSLocalizedString("Gifts", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        let home = try? Account.createAndGetAccount(parent: expense, name: NSLocalizedString("Home", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        let utility = try? Account.createAndGetAccount(parent: home, name: NSLocalizedString("Utility", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        let rent = try? Account.createAndGetAccount(parent: home, name: NSLocalizedString("Rent", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)
        let _ = try? Account.createAndGetAccount(parent: home, name: NSLocalizedString("Renovation", comment: ""), type: Account.TypeEnum.assets, currency: accountingCurrency, createdByUser: false, context: context)

        let income = try? Account.createAndGetAccount(parent: nil, name: LocalisationManager.getLocalizedName(.income), type: Account.TypeEnum.liabilities, currency: accountingCurrency, createdByUser: false, context: context)
        let salary = try? Account.createAndGetAccount(parent: income, name: NSLocalizedString("Salary", comment: ""), type: Account.TypeEnum.liabilities, currency: accountingCurrency, createdByUser: false, context: context)
        let _ = try? Account.createAndGetAccount(parent: income, name: NSLocalizedString("Gifts", comment: ""), type: Account.TypeEnum.liabilities, currency: accountingCurrency, createdByUser: false, context: context)
        let interestOnDeposits = try? Account.createAndGetAccount(parent: income, name: NSLocalizedString("Interest on deposits", comment: ""), type: Account.TypeEnum.liabilities, currency: accountingCurrency, createdByUser: false, context: context)

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
// swiftlint:enable all
