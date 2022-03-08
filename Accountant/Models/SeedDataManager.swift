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
        let bank1 = try? KeeperManager.getKeeperForName(NSLocalizedString("Bank1", comment: ""), context: context)
        let bank2 = try? KeeperManager.getKeeperForName(NSLocalizedString("Bank2", comment: ""), context: context)
        let hanna = try? KeeperManager.getKeeperForName(NSLocalizedString("Hanna", comment: ""), context: context)
        let cashKeeper = try? KeeperManager.getCashKeeper(context: context)
        
        let me = try? HolderManager.getHolderForName(NSLocalizedString("Me", comment: ""), context: context)
        let kate = try? HolderManager.getHolderForName(NSLocalizedString("Kate", comment: ""), context: context)
        
        
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
        
        
        
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                          debit: deposit!,
                                          credit: capital!,
                                          debitAmount: 50000,
                                          creditAmount: 50000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                          debit: creditcard_A!,
                                          credit: creditcard_L!,
                                          debitAmount: 5000,
                                          creditAmount: 5000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                          debit: cash!,
                                          credit: capital!,
                                          debitAmount: 2000,
                                          creditAmount: 2000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -60, to: Date())!,
                                          debit: salaryCard!,
                                          credit: capital!,
                                          debitAmount: 20000,
                                          creditAmount: 20000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -59, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -55, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 800,
                                          creditAmount: 800,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -50, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -49, to: Date())!,
                                          debit: cash!,
                                          credit: salaryCard!,
                                          debitAmount: 4000,
                                          creditAmount: 4000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -47, to: Date())!,
                                          debit: gifts_E!,
                                          credit: cash!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -46, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 200,
                                          creditAmount: 200,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -44, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -42, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 500,
                                          creditAmount: 500,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -40, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -39, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 100,
                                          creditAmount: 100,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -38, to: Date())!,
                                          debit: cash!,
                                          credit: salaryCard!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -37, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -36, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -35, to: Date())!,
                                          debit: rent!,
                                          credit: cash!,
                                          debitAmount: 5000,
                                          creditAmount: 5000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -34, to: Date())!,
                                          debit: utility!,
                                          credit: salaryCard!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -32, to: Date())!,
                                          debit: salaryCard!,
                                          credit: salary!,
                                          debitAmount: 20000,
                                          creditAmount: 20000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -31, to: Date())!,
                                          debit: salaryCard!,
                                          credit: interestOnDeposits!,
                                          debitAmount: 200,
                                          creditAmount: 200,
                                          context: context)
        
        
        
        
        
        
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -29, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -25, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 800,
                                          creditAmount: 800,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -20, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -19, to: Date())!,
                                          debit: cash!,
                                          credit: salaryCard!,
                                          debitAmount: 4000,
                                          creditAmount: 4000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -17, to: Date())!,
                                          debit: gifts_E!,
                                          credit: cash!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -16, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 200,
                                          creditAmount: 200,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -14, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -12, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 500,
                                          creditAmount: 500,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -10, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -9, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 100,
                                          creditAmount: 100,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -8, to: Date())!,
                                          debit: cash!,
                                          credit: salaryCard!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -7, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -6, to: Date())!,
                                          debit: food!,
                                          credit: salaryCard!,
                                          debitAmount: 300,
                                          creditAmount: 300,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -5, to: Date())!,
                                          debit: rent!,
                                          credit: cash!,
                                          debitAmount: 5000,
                                          creditAmount: 5000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -4, to: Date())!,
                                          debit: utility!,
                                          credit: salaryCard!,
                                          debitAmount: 1000,
                                          creditAmount: 1000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -2, to: Date())!,
                                          debit: salaryCard!,
                                          credit: salary!,
                                          debitAmount: 20000,
                                          creditAmount: 20000,
                                          context: context)
        TransactionManager.addTransaction(date: calendar.date(byAdding: .day, value: -1, to: Date())!,
                                          debit: salaryCard!,
                                          credit: interestOnDeposits!,
                                          debitAmount: 200,
                                          creditAmount: 200,
                                          context: context)
    }
}
