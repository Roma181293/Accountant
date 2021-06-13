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
    var coreDataStack: TestCoreDataStack!
    var context: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        coreDataStack = TestCoreDataStack.shared
        context = coreDataStack.persistentContainer.viewContext
    }
    
    override func tearDown() {
        super.tearDown()
        coreDataStack = nil
    }
    
    
    func testIsReservedAccountName() {
        XCTAssertTrue(AccountManager.isReservedAccountName("Expense"))
        XCTAssertFalse(AccountManager.isReservedAccountName("Food"))
    }
    
    func testAccountCreatedByUserNotReservedName () {
        let name = "Some name"
        let accType = AccountType.assets.rawValue
        do {
            let account = try AccountManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: nil, createdByUser: true, context: context)
            XCTAssertTrue(account.name == name)
            XCTAssertTrue(account.path == name)
            XCTAssertTrue(account.type == accType)
            XCTAssertTrue(account.subType == 0)
            XCTAssertNil(account.parent)
            XCTAssertNil(account.currency)
            XCTAssertTrue(account.createdByUser)
            XCTAssertTrue(account.modifiedByUser)
            context.rollback()
        }
        catch {
            XCTAssertTrue(false)
        }
        
    }
    
    func testAccountCreatedByUserReservedName () {
        let name = "Expense"
        let accType = AccountType.assets.rawValue
        do {
            let account = try AccountManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: nil, createdByUser: true, context: context)
            XCTAssertNil(account)
            context.rollback()
        }
        catch {
            if let error = error as? AccountError {
                XCTAssertTrue(error == .reservedAccountName)
            }
            else {
                XCTAssertTrue(false)
            }
        }
    }
    
    func testAccountCreatedByAppNotReservedName () {
        let name = "Some name"
        let accType = AccountType.assets.rawValue
        do {
            let account = try AccountManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: nil, createdByUser: false, context: context)
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
            let account = try AccountManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: nil, createdByUser: false, context: context)
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
            let account = try AccountManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: nil, subType: moneyAccountType, createdByUser: false, context: context)
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
            let account1 = try AccountManager.createAndGetAccount(parent: nil, name: name1, type: accType, currency: nil, createdByUser: false, context: context)
            let account2 = try AccountManager.createAndGetAccount(parent: account1, name: name2, type: nil, currency: nil, createdByUser: false, context: context)
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
    
    func testDuplicatedAccountName() {
        let name1 = "Name1"
        let accType = AccountType.assets.rawValue
        let name2 = "Name2"
      
        do {
            let account1 = try AccountManager.createAndGetAccount(parent: nil, name: name1, type: accType, currency: nil, createdByUser: false, context: context)
            XCTAssertNotNil(account1)
            let account2 = try AccountManager.createAndGetAccount(parent: account1, name: name2, type: nil, currency: nil, createdByUser: false, context: context)
            XCTAssertNotNil(account2)
            let account3 = try AccountManager.createAndGetAccount(parent: account1, name: name2, type: nil, currency: nil, createdByUser: false, context: context)
            XCTAssertNil(account3)   //создание субсчета 2 для счета 1
            context.rollback()
        }
        catch let error{
            if let error = error as? AccountError {
                XCTAssertTrue(error == .accontWithThisNameAlreadyExists)
            }
            else {
                XCTAssertTrue(false)
            }
        }
    }
    
    func testCreateZeroLvlAccountWithCurrency() { // счет нулевого уровня должен иметь валюту = nil или валюте учета (нужно ли ограничение что это долна быть валюта учета?)
        let name = "Capital"
        let accType = AccountType.assets.rawValue
        do {
        let currency = try CurrencyManager.createAndGetCurrency(code: "AUD", name: "Австралійський долар", context: context)
        try CurrencyManager.changeAccountingCurrency(old: nil, new: currency, context: context)

        let account = try AccountManager.createAndGetAccount(parent: nil, name: name, type: accType, currency: currency, createdByUser:  false, context: context)

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
