//
//  SeedDataService.swift
//  Accounting
//
//  Created by Roman Topchii on 03.01.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import Foundation
import CoreData
import Charts

// swiftlint:disable all
class SeedDataService {

    static public func addTestData(persistentContainer: PersistentContainer) throws {
        guard persistentContainer.environment == .test else {return}
        let context = persistentContainer.viewContext
        addCurrencies(context: context)
        guard let currency = try CurrencyHelper.getCurrencyForCode("UAH", context: context) else {return}
        try CurrencyHelper.setAccountingCurrency(currency, context: context)
        addTestKeepers(context: context)
        addTestHolders(context: context)
        try addTestBaseAccountsWithTransaction(accountingCurrency: currency, context: context)
        try CoreDataStack.shared.saveContext(context)
    }

    static public func addProdData(persistentContainer: PersistentContainer) throws {
        let context = persistentContainer.viewContext
        addCurrencies(context: context)
        addHolders(context: context)
        addKeepers(context: context)
    }

    // MARK: - Account
    static public func addBaseAccounts(accountingCurrency: Currency, context: NSManagedObjectContext) {
        LocalisationManager.createAllLocalizedAccountName()

        // swiftlint:disable line_length
        let accounting = AccountType(name: "Accounting", classification: .none, allowsTransactions: false, priority: 1, context: context)

        let creditorsConsolid = AccountType(parent: accounting, name: "Creditors consolidation", classification: .liabilities, balanceCalcFullTime: true, allowsTransactions: false, priority: 1, context: context)
        let creditor = AccountType(parent: creditorsConsolid, name: "Creditor", classification: .liabilities, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .nonCash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let moneyConsolid = AccountType(parent: accounting, name: "Money consolidation", classification: .assets, balanceCalcFullTime: true, allowsTransactions: false, priority: 1, context: context)
        let creditCard = AccountType(parent: moneyConsolid, name: "Credit Card", classification: .assets, hasCurrency: true, linkedAccountType: creditor, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .bank, checkAmountBeforDeactivate: true, priority: 3, context: context)
        let debitCard = AccountType(parent: moneyConsolid, name: "Debit Card", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .bank, checkAmountBeforDeactivate: true, priority: 2, context: context)
        let cash = AccountType(parent: moneyConsolid, name: "Cash", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .cash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let debtorsConsolid = AccountType(parent: accounting, name: "Debtors consolidation", classification: .assets, balanceCalcFullTime: true, allowsTransactions: false, priority: 1, context: context)
        let debtor = AccountType(parent: debtorsConsolid, name: "Debtor", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .nonCash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let incomeConsolid = AccountType(parent: accounting, name: "Income consolidation", classification: .liabilities, hasCurrency: true, allowsTransactions: false, priority: 1, context: context)

        let expenseConsolid = AccountType(parent: accounting, name: "Expense consolidation", classification: .assets, hasCurrency: true, allowsTransactions: false, priority: 1, context: context)

        let capitalConsolid = AccountType(parent: accounting, name: "Capital consolidation", classification: .liabilities, hasCurrency: true, balanceCalcFullTime: true, priority: 1, context: context)

        let assetsCategoryConsolid = AccountType(parent: accounting, name: "Liabilities category consolidation", classification: .liabilities, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, allowsTransactions: false, priority: 1, context: context)

        let liabilityCategoryConsolid = AccountType(parent: accounting, name: "Assets category consolidation", classification: .assets, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, allowsTransactions: false, priority: 2, context: context)

        let liabilitiesCategory = AccountType(name: "Liabilities category", classification: .liabilities, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: false, priority: 1, context: context)
        liabilitiesCategory.parents = [liabilityCategoryConsolid, incomeConsolid, capitalConsolid, liabilitiesCategory]

        let assetsCategory = AccountType(name: "Assets category", classification: .assets, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: false, priority: 2, context: context)
        assetsCategory.parents = [assetsCategoryConsolid, expenseConsolid, assetsCategory]

        let expenseBeforeAccountingPeriod = AccountType(name: "Expense before accounting period", classification: .assets, hasCurrency: true, canBeDeleted: false, canChangeActiveStatus: true, canBeRenamed: false, canBeCreatedByUser: false, checkAmountBeforDeactivate: true, priority: 1, context: context)
        // swiftlint:enable line_length

        let accounts = try? AccountHelper.createAndGetAccount(parent: nil, name: LocalisationManager.getLocalizedName(.accounts), type: accounting, currency: nil, createdByUser: false, context: context)

        try? AccountHelper.createAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.money), type: moneyConsolid, currency: nil, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.credits), type: creditorsConsolid, currency: nil, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.debtors), type: debtorsConsolid, currency: nil, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.capital), type: capitalConsolid, currency: accountingCurrency, createdByUser: false, context: context)

        let expense = try? AccountHelper.createAndGetAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.expense), type: expenseConsolid, currency: accountingCurrency, createdByUser: false, context: context)

        let beforeAccountingPeriod = try? AccountHelper.createAndGetAccount(parent: expense, name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        try? beforeAccountingPeriod?.changeActiveStatus()

        try? AccountHelper.createAccount(parent: expense, name: NSLocalizedString("Food", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: expense, name: NSLocalizedString("Transport", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: expense, name: NSLocalizedString("Gifts", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        let home = try? AccountHelper.createAndGetAccount(parent: expense, name: NSLocalizedString("Home", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: home, name: NSLocalizedString("Utility", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: home, name: NSLocalizedString("Rent", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: home, name: NSLocalizedString("Renovation", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)

        let income = try? AccountHelper.createAndGetAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.income), type: liabilityCategoryConsolid, currency: accountingCurrency, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: income, name: NSLocalizedString("Salary", comment: ""), type: liabilitiesCategory, currency: accountingCurrency, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: income, name: NSLocalizedString("Gifts", comment: ""), type: liabilitiesCategory, currency: accountingCurrency, createdByUser: false, context: context)
        try? AccountHelper.createAccount(parent: income, name: NSLocalizedString("Interest on deposits", comment: ""), type: liabilitiesCategory, currency: accountingCurrency, createdByUser: false, context: context)
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

    // MARK: - Keeper
    private static func addKeepers(context: NSManagedObjectContext) {
        let keeperProvider = KeeperProvider(with: CoreDataStack.shared.persistentContainer, fetchedResultsControllerDelegate: nil)
        keeperProvider.addKeeper(name: NSLocalizedString("Cash", comment: ""), type: .cash, createdByUser: false, context: context)
        keeperProvider.addKeeper(name: NSLocalizedString("Monobank",comment: ""), type: .bank, createdByUser: false, context: context)
    }
    
    private static func addTestKeepers(context: NSManagedObjectContext) {
        let keeperProvider = KeeperProvider(with: CoreDataStack.shared.persistentContainer, fetchedResultsControllerDelegate: nil)
        keeperProvider.addKeeper(name: NSLocalizedString("Cash", comment: ""), type: .cash, createdByUser: false, context: context)
        keeperProvider.addKeeper(name: NSLocalizedString("Bank1", comment: ""), type: .bank, context: context)
        keeperProvider.addKeeper(name: NSLocalizedString("Bank2", comment: ""), type: .bank, context: context)
        keeperProvider.addKeeper(name: NSLocalizedString("Hanna", comment: ""), type: .person, context: context)
        keeperProvider.addKeeper(name: NSLocalizedString("Monobank",comment: ""), type: .bank, createdByUser: false, context: context)
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


    // MARK: - Account
    private static func addTestBaseAccountsWithTransaction(accountingCurrency: Currency,
                                                           context: NSManagedObjectContext) throws {
        LocalisationManager.createAllLocalizedAccountName()

        // MARK: - Get keepers
        let bank1 = try? KeeperHelper.getKeeperForName(NSLocalizedString("Bank1", comment: ""), context: context)
        let bank2 = try? KeeperHelper.getKeeperForName(NSLocalizedString("Bank2", comment: ""), context: context)
        let hanna = try? KeeperHelper.getKeeperForName(NSLocalizedString("Hanna", comment: ""), context: context)
        let cashKeeper = try? KeeperHelper.getCashKeeper(context: context)

        let me = try? HolderHelper.get(NSLocalizedString("Me", comment: ""), context: context)
        let kate = try? HolderHelper.get(NSLocalizedString("Kate", comment: ""), context: context)



        // swiftlint:disable line_length
        let accounting = AccountType(name: "Accounting", classification: .none, allowsTransactions: false, priority: 1, context: context)

        let creditorsConsolid = AccountType(parent: accounting, name: "Creditors consolidation", classification: .liabilities, balanceCalcFullTime: true, allowsTransactions: false, priority: 1, context: context)
        let creditor = AccountType(parent: creditorsConsolid, name: "Creditor", classification: .liabilities, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .nonCash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let moneyConsolid = AccountType(parent: accounting, name: "Money consolidation", classification: .assets, balanceCalcFullTime: true, allowsTransactions: false, priority: 1, context: context)
        let creditCard = AccountType(parent: moneyConsolid, name: "Credit Card", classification: .assets, hasCurrency: true, linkedAccountType: creditor, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .bank, checkAmountBeforDeactivate: true, priority: 3, context: context)
        let debitCard = AccountType(parent: moneyConsolid, name: "Debit Card", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .bank, checkAmountBeforDeactivate: true, priority: 2, context: context)
        let cash = AccountType(parent: moneyConsolid, name: "Cash", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .cash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let debtorsConsolid = AccountType(parent: accounting, name: "Debtors consolidation", classification: .assets, balanceCalcFullTime: true, allowsTransactions: false, priority: 1, context: context)
        let debtor = AccountType(parent: debtorsConsolid, name: "Debtor", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .nonCash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let incomeConsolid = AccountType(parent: accounting, name: "Income consolidation", classification: .liabilities, hasCurrency: true, allowsTransactions: false, priority: 1, context: context)

        let expenseConsolid = AccountType(parent: accounting, name: "Expense consolidation", classification: .assets, hasCurrency: true, allowsTransactions: false, priority: 1, context: context)

        let capitalConsolid = AccountType(parent: accounting, name: "Capital consolidation", classification: .liabilities, hasCurrency: true, balanceCalcFullTime: true, priority: 1, context: context)

        let assetsCategoryConsolid = AccountType(parent: accounting, name: "Liabilities category consolidation", classification: .liabilities, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, allowsTransactions: false, priority: 1, context: context)

        let liabilityCategoryConsolid = AccountType(parent: accounting, name: "Assets category consolidation", classification: .assets, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, allowsTransactions: false, priority: 2, context: context)

        let liabilitiesCategory = AccountType(name: "Liabilities category", classification: .liabilities, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: false, priority: 1, context: context)
        liabilitiesCategory.parents = [liabilityCategoryConsolid, incomeConsolid, capitalConsolid, liabilitiesCategory]

        let assetsCategory = AccountType(name: "Assets category", classification: .assets, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: false, priority: 2, context: context)
        assetsCategory.parents = [assetsCategoryConsolid, expenseConsolid, assetsCategory]

        let expenseBeforeAccountingPeriod = AccountType(name: "Expense before accounting period", classification: .assets, hasCurrency: true, canBeDeleted: false, canChangeActiveStatus: true, canBeRenamed: false, canBeCreatedByUser: false, checkAmountBeforDeactivate: true, priority: 1, context: context)
        // swiftlint:enable line_length


        let accounts = try? AccountHelper.createAndGetAccount(parent: nil, name: LocalisationManager.getLocalizedName(.accounts), type: accounting, currency: nil, createdByUser: false, context: context)

        let money = try? AccountHelper.createAndGetAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.money), type: moneyConsolid, currency: nil, createdByUser: false, context: context)
        let credits = try? AccountHelper.createAndGetAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.credits), type: creditorsConsolid, currency: nil, createdByUser: false, context: context)
        let debtors = try? AccountHelper.createAndGetAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.debtors), type: debtorsConsolid, currency: nil, createdByUser: false, context: context)
        let capital = try? AccountHelper.createAndGetAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.capital), type: capitalConsolid, currency: accountingCurrency, createdByUser: false, context: context)


        let deposit = try? AccountHelper.createAndGetAccount(parent: debtors, name: NSLocalizedString("Deposit", comment: ""), type: debtor, currency: accountingCurrency, keeper: bank1, holder: me, createdByUser: false, context: context)
        let _ = try? AccountHelper.createAndGetAccount(parent: debtors, name: NSLocalizedString("Hanna", comment: ""), type: debtor, currency: accountingCurrency, keeper: hanna, holder: me, createdByUser: false, context: context)

        let salaryCard = try? AccountHelper.createAndGetAccount(parent: money, name: NSLocalizedString("Salary card", comment: ""), type: debitCard, currency: accountingCurrency, keeper: bank2, holder: me, createdByUser: false, context: context)
        let cashAcc = try? AccountHelper.createAndGetAccount(parent: money, name: NSLocalizedString("Cash", comment: ""), type: cash, currency: accountingCurrency, keeper: cashKeeper, holder: kate, createdByUser: false, context: context)

        let creditcard_A = try? AccountHelper.createAndGetAccount(parent: money, name: NSLocalizedString("Credit card", comment: ""), type: creditCard, currency: accountingCurrency, keeper: bank1, holder: me, createdByUser: false, context: context)
        let creditcard_L = try? AccountHelper.createAndGetAccount(parent: credits, name: NSLocalizedString("Credit card", comment: ""), type: creditor, currency: accountingCurrency, keeper: bank1, holder: me, createdByUser: false, context: context)
        creditcard_A?.linkedAccount = creditcard_L
        creditcard_L?.linkedAccount = creditcard_A

        let expense = try? AccountHelper.createAndGetAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.expense), type: expenseConsolid, currency: accountingCurrency, createdByUser: false, context: context)

        let beforeAccountingPeriod = try? AccountHelper.createAndGetAccount(parent: expense, name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        try? beforeAccountingPeriod?.changeActiveStatus()

        let food = try? AccountHelper.createAndGetAccount(parent: expense, name: NSLocalizedString("Food", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        let _ = try? AccountHelper.createAndGetAccount(parent: expense, name: NSLocalizedString("Transport", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        let gifts_E = try? AccountHelper.createAndGetAccount(parent: expense, name: NSLocalizedString("Gifts", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        let home = try? AccountHelper.createAndGetAccount(parent: expense, name: NSLocalizedString("Home", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        let utility = try? AccountHelper.createAndGetAccount(parent: home, name: NSLocalizedString("Utility", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        let rent = try? AccountHelper.createAndGetAccount(parent: home, name: NSLocalizedString("Rent", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)
        let _ = try? AccountHelper.createAndGetAccount(parent: home, name: NSLocalizedString("Renovation", comment: ""), type: assetsCategory, currency: accountingCurrency, createdByUser: false, context: context)

        let income = try? AccountHelper.createAndGetAccount(parent: accounts, name: LocalisationManager.getLocalizedName(.income), type: incomeConsolid, currency: accountingCurrency, createdByUser: false, context: context)
        let salary = try? AccountHelper.createAndGetAccount(parent: income, name: NSLocalizedString("Salary", comment: ""), type: liabilitiesCategory, currency: accountingCurrency, createdByUser: false, context: context)
        let _ = try? AccountHelper.createAndGetAccount(parent: income, name: NSLocalizedString("Gifts", comment: ""), type: liabilitiesCategory, currency: accountingCurrency, createdByUser: false, context: context)
        let interestOnDeposits = try? AccountHelper.createAndGetAccount(parent: income, name: NSLocalizedString("Interest on deposits", comment: ""), type: liabilitiesCategory, currency: accountingCurrency, createdByUser: false, context: context)

        let calendar = Calendar.current
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                           debit: deposit!,
                                           credit: capital!,
                                           debitAmount: 50000,
                                           debitAmountInAccountingCurrency: 50000,
                                           creditAmount: 50000,
                                           creditAmountInAccountingCurrency: 50000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                           debit: creditcard_A!,
                                           credit: creditcard_L!,
                                           debitAmount: 5000,
                                           debitAmountInAccountingCurrency: 5000,
                                           creditAmount: 5000,
                                           creditAmountInAccountingCurrency: 5000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                           debit: cashAcc!,
                                           credit: capital!,
                                           debitAmount: 2000,
                                           debitAmountInAccountingCurrency: 2000,
                                           creditAmount: 2000,
                                           creditAmountInAccountingCurrency: 2000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                           debit: salaryCard!,
                                           credit: capital!,
                                           debitAmount: 20000,
                                           debitAmountInAccountingCurrency: 2000,
                                           creditAmount: 2000,
                                           creditAmountInAccountingCurrency: 2000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -59, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -55, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 800,
                                           debitAmountInAccountingCurrency: 800,
                                           creditAmount: 800,
                                           creditAmountInAccountingCurrency: 800,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -50, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -49, to: Date())!,
                                           debit: cashAcc!,
                                           credit: salaryCard!,
                                           debitAmount: 4000,
                                           debitAmountInAccountingCurrency: 4000,
                                           creditAmount: 4000,
                                           creditAmountInAccountingCurrency: 4000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -47, to: Date())!,
                                           debit: gifts_E!,
                                           credit: cashAcc!,
                                           debitAmount: 1000,
                                           debitAmountInAccountingCurrency: 1000,
                                           creditAmount: 1000,
                                           creditAmountInAccountingCurrency: 1000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -46, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 200,
                                           debitAmountInAccountingCurrency: 200,
                                           creditAmount: 200,
                                           creditAmountInAccountingCurrency: 200,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -44, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -42, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 500,
                                           debitAmountInAccountingCurrency: 500,
                                           creditAmount: 500,
                                           creditAmountInAccountingCurrency: 500,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -40, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -39, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 100,
                                           debitAmountInAccountingCurrency: 100,
                                           creditAmount: 100,
                                           creditAmountInAccountingCurrency: 100,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -38, to: Date())!,
                                           debit: cashAcc!,
                                           credit: salaryCard!,
                                           debitAmount: 1000,
                                           debitAmountInAccountingCurrency: 1000,
                                           creditAmount: 1000,
                                           creditAmountInAccountingCurrency: 1000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -37, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -36, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -35, to: Date())!,
                                           debit: rent!,
                                           credit: cashAcc!,
                                           debitAmount: 5000,
                                           debitAmountInAccountingCurrency: 5000,
                                           creditAmount: 5000,
                                           creditAmountInAccountingCurrency: 5000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -34, to: Date())!,
                                           debit: utility!,
                                           credit: salaryCard!,
                                           debitAmount: 1000,
                                           debitAmountInAccountingCurrency: 1000,
                                           creditAmount: 1000,
                                           creditAmountInAccountingCurrency: 1000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -32, to: Date())!,
                                           debit: salaryCard!,
                                           credit: salary!,
                                           debitAmount: 20000,
                                           debitAmountInAccountingCurrency: 20000,
                                           creditAmount: 20000,
                                           creditAmountInAccountingCurrency: 20000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -31, to: Date())!,
                                           debit: salaryCard!,
                                           credit: interestOnDeposits!,
                                           debitAmount: 200,
                                           debitAmountInAccountingCurrency: 200,
                                           creditAmount: 200,
                                           creditAmountInAccountingCurrency: 200,
                                           context: context)
        
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -29, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -25, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 800,
                                           debitAmountInAccountingCurrency: 800,
                                           creditAmount: 800,
                                           creditAmountInAccountingCurrency: 800,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -20, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -19, to: Date())!,
                                           debit: cashAcc!,
                                           credit: salaryCard!,
                                           debitAmount: 4000,
                                           debitAmountInAccountingCurrency: 4000,
                                           creditAmount: 4000,
                                           creditAmountInAccountingCurrency: 4000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -17, to: Date())!,
                                           debit: gifts_E!,
                                           credit: cashAcc!,
                                           debitAmount: 1000,
                                           debitAmountInAccountingCurrency: 1000,
                                           creditAmount: 1000,
                                           creditAmountInAccountingCurrency: 1000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -16, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 200,
                                           debitAmountInAccountingCurrency: 200,
                                           creditAmount: 200,
                                           creditAmountInAccountingCurrency: 200,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -14, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -12, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 500,
                                           debitAmountInAccountingCurrency: 500,
                                           creditAmount: 500,
                                           creditAmountInAccountingCurrency: 500,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -10, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -9, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 100,
                                           debitAmountInAccountingCurrency: 100,
                                           creditAmount: 100,
                                           creditAmountInAccountingCurrency: 100,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -8, to: Date())!,
                                           debit: cashAcc!,
                                           credit: salaryCard!,
                                           debitAmount: 1000,
                                           debitAmountInAccountingCurrency: 1000,
                                           creditAmount: 1000,
                                           creditAmountInAccountingCurrency: 1000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -7, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -6, to: Date())!,
                                           debit: food!,
                                           credit: salaryCard!,
                                           debitAmount: 300,
                                           debitAmountInAccountingCurrency: 300,
                                           creditAmount: 300,
                                           creditAmountInAccountingCurrency: 300,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -5, to: Date())!,
                                           debit: rent!,
                                           credit: cashAcc!,
                                           debitAmount: 5000,
                                           debitAmountInAccountingCurrency: 5000,
                                           creditAmount: 5000,
                                           creditAmountInAccountingCurrency: 5000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -4, to: Date())!,
                                           debit: utility!,
                                           credit: salaryCard!,
                                           debitAmount: 1000,
                                           debitAmountInAccountingCurrency: 1000,
                                           creditAmount: 1000,
                                           creditAmountInAccountingCurrency: 1000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -2, to: Date())!,
                                           debit: salaryCard!,
                                           credit: salary!,
                                           debitAmount: 20000,
                                           debitAmountInAccountingCurrency: 20000,
                                           creditAmount: 20000,
                                           creditAmountInAccountingCurrency: 20000,
                                           context: context)
        TransactionHelper.createSimpleTran(date: calendar.date(byAdding: .day, value: -1, to: Date())!,
                                           debit: salaryCard!,
                                           credit: interestOnDeposits!,
                                           debitAmount: 200,
                                           debitAmountInAccountingCurrency: 200,
                                           creditAmount: 200,
                                           creditAmountInAccountingCurrency: 200,
                                           context: context)
    }
}
// swiftlint:enable all
