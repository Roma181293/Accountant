//
//  AccountTests.swift
//  AccountingTests
//
//  Created by Roman Topchii on 07.01.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import XCTest
@testable import Accountant
import CoreData

class AccountTests: XCTestCase {
    
    var coreDataStack: CoreDataStack!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack.shared
        context = coreDataStack.persistentContainer.viewContext
        HolderManager.createDefaultHolders(context: context)
        KeeperManager.createDefaultKeepers(context: context)
        Currency.addCurrencies(context: context)
        do {
        let currency = try Currency.getCurrencyForCode("UAH", context: context)!
        try Currency.changeAccountingCurrency(old: nil, new: currency, context: context)
        SeedDataManager.addBaseAccounts(accountingCurrency: currency, context: context)
        }
        catch let error{
            print("error", error.localizedDescription)
        }
    }
    
    override func tearDown() {
        super.tearDown()
        coreDataStack = nil
    }
    
    
    func testIsReservedAccountName() {
        XCTAssertTrue(SeedDataManager.isReservedAccountName("Expenses"))
        XCTAssertFalse(SeedDataManager.isReservedAccountName("Food"))
    }
    
    func testIsFreeAccountName () {
        let name1 = "Name1"
        let accType = AccountType.assets.rawValue
        let name2 = "Name2"
        
        //Chkeck for case when parent == nil
        XCTAssertTrue(SeedDataManager.isFreeAccountName(parent: nil, name: name1, context: context))
        
        var account1: Account?
        XCTAssertNoThrow(account1 = try SeedDataManager.createAndGetAccount(parent: nil, name: name1, type: accType, currency: nil, createdByUser: true, context: context), "Account should be created")
        XCTAssertNotNil(account1)
        
        XCTAssertFalse(SeedDataManager.isFreeAccountName(parent: nil, name: name1, context: context), "Name should be used by account1")
        
        
        //Chkeck for case when parent != nil
        XCTAssertTrue(SeedDataManager.isFreeAccountName(parent: account1, name: name2, context: context), "Name should be free to use")
        
        var account2: Account?
        XCTAssertNoThrow(account2 = try SeedDataManager.createAndGetAccount(parent: account1, name: name2, type: nil, currency: nil, createdByUser: true, context: context), "Account should be created")
        XCTAssertNotNil(account2)
        XCTAssertFalse(SeedDataManager.isFreeAccountName(parent: account1, name: name2, context: context), "Name should be used by account1")
        context.rollback()
    }
    
    func testIsFreeFromTransactionItems () {
        
    }
    
    
    func testNotReservedNameAccountCreatedByUser () throws {
        let name1 = "Name1"
        let name2 = "Name2"
        let accType = AccountType.assets.rawValue
        let subType = AccountSubType.cash.rawValue
        
        //WO Parent
        var accountWOParent: Account!
        XCTAssertNoThrow(accountWOParent = try SeedDataManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: nil, subType: subType, createdByUser: true, context: context), "Account should be created")
        
        XCTAssertTrue(accountWOParent.name == name)
        XCTAssertTrue(accountWOParent.path == name)
        XCTAssertTrue(accountWOParent.type == accType)
        XCTAssertTrue(accountWOParent.subType == subType)
        XCTAssertNotNil(accountWOParent.type)
        XCTAssertNil(accountWOParent.parent)
        XCTAssertNil(accountWOParent.currency)
        XCTAssertTrue(accountWOParent.createdByUser)
        XCTAssertTrue(accountWOParent.modifiedByUser)
        XCTAssertFalse(accountWOParent.isHidden)
        
        
        XCTAssertNoThrow(try SeedDataManager.changeAccountIsHiddenStatus(accountWOParent))
        XCTAssertTrue(accountWOParent.isHidden)
        
        //With Parent
        var accountWithParent: Account!
        XCTAssertNoThrow(accountWithParent = try SeedDataManager.createAndGetAccount(parent: accountWOParent, name: name2, type: AccountType.liabilities.rawValue, currency: nil, createdByUser: true, context: context), "Account should not be created")
        XCTAssertNotNil(accountWithParent)
        
        //Check inherited attributes values
        XCTAssertEqual(accountWithParent.type, accountWOParent.type)
        XCTAssertEqual(accountWithParent.path, (accountWOParent.path ?? "") + ":" + (accountWithParent.name ?? ""))
        XCTAssertTrue(accountWithParent.isHidden == true)
        
        context.rollback()
    }
    
    func testCatchCreateAndGetMethodErrors () {
        
        var account : Account?
        
        XCTAssertThrowsError(account = try SeedDataManager.createAndGetAccount(parent: nil, name: "", type: nil, currency: nil, createdByUser: true, context: context), "User cannot create empty named account",{error in
            XCTAssertEqual(error as? AccountError, AccountError.emptyName)
            context.rollback()
        })
        XCTAssertNil(account)
       
        
        XCTAssertThrowsError(account = try SeedDataManager.createAndGetAccount(parent: nil, name: "Other", type: nil, currency: nil, createdByUser: true, context: context), "Attribute type is required for root account",{error in
            XCTAssertEqual(error as? AccountError, AccountError.attributeTypeShouldBeInitializeForRootAccount)
            context.rollback()
        })
        XCTAssertNil(account)
        
        
        XCTAssertThrowsError(account = try SeedDataManager.createAndGetAccount(parent: nil, name: "Other", type: AccountType.assets.rawValue, currency: nil, createdByUser: true, context: context), "User can not create account with reserved name", {error in
            XCTAssertEqual(error as? AccountError, AccountError.reservedName(name: "Other"))
            context.rollback()
        })
        XCTAssertNil(account)
        
        
        XCTAssertNoThrow(account = try SeedDataManager.createAndGetAccount(parent: nil, name: "Other", type: AccountType.assets.rawValue, currency: nil, createdByUser: false, context: context), "App can create account with reserved name")
        XCTAssertNotNil(account)
        
        
        XCTAssertNoThrow(account = try SeedDataManager.createAndGetAccount(parent: nil, name: "Non reserved name", type: AccountType.assets.rawValue, currency: nil, createdByUser: false, context: context), "App can create account with non reserved name")
        XCTAssertNotNil(account)
        
        context.rollback()
    }
    
    
    func testDuplicatedOtherAccountDontCreate() {
        
        var account1: Account?
        XCTAssertNoThrow(account1 = try SeedDataManager.createAndGetAccount(parent: nil, name: "SomeName1", type: AccountType.assets.rawValue, currency: nil, createdByUser: true, context: context), "Account should be created")
        XCTAssertNotNil(account1)
        
        var account2: Account?
        XCTAssertNoThrow(account2 = try SeedDataManager.createAndGetAccount(parent: account1, name: "SomeName2", type: nil, currency: nil, createdByUser: true, context: context), "Account should be created")
        XCTAssertNotNil(account2)
        
        
        TransactionManager.addTransaction(date: Date(), debit: account2!, credit: account2!, debitAmount: 10, creditAmount: 10, comment: nil, createdByUser: true, context: context)
        
        
        var account3: Account?
        XCTAssertNoThrow(account2 = try SeedDataManager.createAndGetAccount(parent: account2, name: "SomeName3", type: nil, currency: nil, createdByUser: true, context: context), "Account should be created")
        XCTAssertNotNil(account2)
        
        
        TransactionManager.addTransaction(date: Date(), debit: account2!, credit: account2!, debitAmount: 10, creditAmount: 10, comment: nil, createdByUser: true, context: context)
        
        var account4: Account?
        XCTAssertNoThrow(account3 = try SeedDataManager.createAndGetAccount(parent: account2, name: "SomeName4", type: nil, currency: nil, createdByUser: true, context: context), "Account should be created")
        XCTAssertNotNil(account2)
        
        
        XCTAssertTrue(SeedDataManager.getAllChildrenForAcctount(account2!).count == 3)
        
        context.rollback()
    }
   
    
    func testAccountCreatedByAppNotReservedName () {
        let name = "Some name"
        let accType = AccountType.assets.rawValue
        do {
            let account = try SeedDataManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: nil, createdByUser: false, context: context)
            XCTAssertTrue(account.name == name)
            XCTAssertTrue(account.path == name)
            XCTAssertTrue(account.type == accType)
            XCTAssertTrue(account.subType == 0)
            XCTAssertNil(account.parent)
            XCTAssertNil(account.currency)
            XCTAssertFalse(account.createdByUser)
            XCTAssertFalse(account.modifiedByUser)
            context.rollback()
        }
        catch {
            XCTAssertTrue(false)
        }
        
    }
    
    func testAccountCreatedByAppReservedName () {
        let name = "Expense"
        let accType = AccountType.assets.rawValue
        do {
            let account = try SeedDataManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: nil, createdByUser: false, context: context)
            XCTAssertTrue(account.name == name)
            XCTAssertTrue(account.path == name)
            XCTAssertTrue(account.type == accType)
            XCTAssertTrue(account.subType == 0)
            XCTAssertNil(account.parent)
            XCTAssertNil(account.currency)
            XCTAssertFalse(account.createdByUser)
            XCTAssertFalse(account.modifiedByUser)
            context.rollback()
        }
        catch {
            XCTAssertTrue(false)
        }
    }
    
    func testCreatMoneyAccount () {
        let name = "Some name"
        let accType = AccountType.assets.rawValue
        let moneyAccountType = AccountSubType.cash.rawValue
        do {
            let account = try SeedDataManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: nil, subType: moneyAccountType, createdByUser: false, context: context)
            XCTAssertTrue(account.name == name)
            XCTAssertTrue(account.path == name)
            XCTAssertTrue(account.type == accType)
            XCTAssertTrue(account.subType == moneyAccountType)
            XCTAssertNil(account.parent)
            XCTAssertNil(account.currency)
            XCTAssertFalse(account.createdByUser)
            XCTAssertFalse(account.modifiedByUser)
            context.rollback()
        }
        catch {
            XCTAssertTrue(false)
        }
    }

    
    func testAccountWithParent() {
        let name1 = "Name1"
        let accType = AccountType.assets.rawValue
        let name2 = "Name2"
      
        do {
            let account1 = try SeedDataManager.createAndGetAccount(parent: nil, name: name1, type: accType, currency: nil, createdByUser: false, context: context)
            let account2 = try SeedDataManager.createAndGetAccount(parent: account1, name: name2, type: nil, currency: nil, createdByUser: false, context: context)
            XCTAssertTrue(account2.parent == account1) //создание субсчета 2 для счета 1
            XCTAssertTrue(account2.type == account1.type) //субсчет наследуют тип счета от родителя
            XCTAssertTrue(account1.path == name1)
            XCTAssertTrue(account2.path == "\(name1):\(name2)")
            
            context.rollback()
        }
        catch {
            XCTAssertTrue(false)
        }
    }
    
    func testDuplicatedAccountName() throws {
        let name1 = "Name1"
        let accType = AccountType.assets.rawValue
        let name2 = "Name2"
        
        var account1: Account?
        XCTAssertNoThrow(account1 = try SeedDataManager.createAndGetAccount(parent: nil, name: name1, type: accType, currency: nil, createdByUser: true, context: context), "Account should be created")
        XCTAssertNotNil(account1)
        
        var account2: Account?
        XCTAssertNoThrow(account2 = try SeedDataManager.createAndGetAccount(parent: account1, name: name2, type: nil, currency: nil, createdByUser: true, context: context), "Account should be created")
        XCTAssertNotNil(account2)
        
        XCTAssertThrowsError(try SeedDataManager.createAndGetAccount(parent: account1, name: name2, type: nil, currency: nil, createdByUser: true, context: context), "Duplicated name",{error in
            XCTAssertEqual(error as? AccountError, AccountError.accountAlreadyExists(name: name2))
            context.rollback()
        })
        
        context.rollback()
    }
    
    func testCreateZeroLvlAccountWithCurrency() { // счет нулевого уровня должен иметь валюту = nil или валюте учета (нужно ли ограничение что это долна быть валюта учета?)
        let name = "Capital"
        let accType = AccountType.assets.rawValue
        do {
            let currency = try Currency.createAndGetCurrency(code: "AUD", iso4217: 036, name: "Австралійський долар", context: context)
        try Currency.changeAccountingCurrency(old: nil, new: currency, context: context)

        let account = try SeedDataManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: currency, createdByUser:  false, context: context)

        XCTAssertTrue(account.name == name)
        XCTAssertTrue(account.type == accType)
        XCTAssertNil(account.parent)
        XCTAssertTrue(account.currency?.isAccounting == true)
        XCTAssertFalse(account.createdByUser)
        }
        catch {
            XCTAssertTrue(false)
        }
        context.rollback()
    }
}
