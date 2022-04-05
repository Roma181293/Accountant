//
//  CurrencyTests.swift
//  CurrencyTests
//
//  Created by Roman Topchii on 07.01.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import XCTest
@testable import Accountant
import CoreData

class CurrencyTests: XCTestCase {
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
    
    
    func testAddCurrency() throws {
        let currency = try Currency.createAndGetCurrency(code: "AUD", iso4217: 036, name: "Австралійський долар", createdByUser: false, context: context)
        XCTAssertNotNil(currency, "Currency should not be nil")
        XCTAssertTrue(currency.code == "AUD")
        XCTAssertTrue(currency.name == "Австралійський долар")
        XCTAssertFalse(currency.isAccounting)
        context.rollback()
    }
    
    func testCreateDublicatedCurrency() throws {
        try Currency.createCurrency(code: "XXX", iso4217: 036, name: "XXXX", createdByUser: false, context: context)
        
        do {
            try Currency.createCurrency(code: "XXX", iso4217: 086, name: "XXXX", createdByUser: false, context: context)
        }
        catch let error{
            if let error = error as? CurrencyError {
                XCTAssertTrue(error == .thisCurrencyAlreadyExists)
            }
            else {
                XCTAssertTrue(false)
            }
        }
        
        context.rollback()
    }
    
    func testCreateAndGetCurrencyForCode() throws {
        try Currency.createCurrency(code: "YYY", iso4217: 036, name: "YYYY", createdByUser: false, context: context)
        
        
        guard let currency = try Currency.getCurrencyForCode("YYY", context: context) else {
            print("Currency should not be nil")
            XCTAssertTrue(false)
            return}
        
        XCTAssertNotNil(currency, "Currency should not be nil")
        XCTAssertTrue(currency.code == "YYY")
        XCTAssertTrue(currency.name == "YYYY")
        XCTAssertFalse(currency.isAccounting)
        context.rollback()
    }
    
    
    func testSetAccountingCurrency() throws {
        try Currency.createCurrency(code: "AUD", iso4217: 036, name: "Австралійський долар", createdByUser: false, context: context)
        
        guard let currency = try Currency.getCurrencyForCode("AUD", context: context) else {
            print("Currency should not be nil")
            XCTAssertTrue(false)
            return}
        
        XCTAssertFalse(currency.isAccounting)
        try Currency.changeAccountingCurrency(old: nil, new: currency, context: context)
        XCTAssertTrue(currency.isAccounting)
        
        let accCurrency = Currency.getAccountingCurrency(context: context)
        XCTAssertTrue(currency == accCurrency)
        context.rollback()
    }
    
    
    func testCantRemoveCurrencyWithLinkToAccount() {
        let name = "Capital"
        let accType = AccountType.assets.rawValue
        do {
            let currency = try Currency.createAndGetCurrency(code: "USD", iso4217: 840, name: "USD", context: context)
            try Currency.changeAccountingCurrency(old: nil, new: currency, context: context)
            
            XCTAssertTrue(currency.isAccounting)
            
            try SeedDataManager.createAccount(parent: nil, name: name, type: accType, currency: currency, createdByUser:  false, context: context)
            
            try Currency.removeCurrency(currency, context: context)
            XCTAssertNil(currency)
            
            context.rollback()
        }
        catch let error{
            if let error = error as? CurrencyError {
                XCTAssertTrue(error == .thisCurrencyUsedInAccounts)
            }
            else {
                XCTAssertTrue(false)
            }
        }
    }
    
    func testCantRemoveAccountingCurrency() {
        do {
            let currency = try Currency.createAndGetCurrency(code: "USD", iso4217: 840, name: "USD", context: context)
            try Currency.changeAccountingCurrency(old: nil, new: currency, context: context)
            
            try Currency.removeCurrency(currency, context: context)
            XCTAssertNotNil(currency)
            
            context.rollback()
        }
        catch let error{
            if let error = error as? CurrencyError {
                XCTAssertTrue(error == .thisIsAccountingCurrency)
            }
            else {
                XCTAssertTrue(false)
            }
        }
    }
    
        func testFetchCount() throws {
            let currencyFetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: Currency.entity().name!)
            currencyFetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true),NSSortDescriptor(key: "name", ascending: true)]
            let currencies = try coreDataStack.persistentContainer.viewContext.fetch(currencyFetchRequest)
            print(currencies.count)
            currencies.forEach({print($0.name)})
            XCTAssertTrue (currencies.count == 0)
        }
}
