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

class AccountTests: XCTestCase {  // swiftlint:disable:this type_body_length

    var coreDataStack: CoreDataStack!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack.shared
        context = coreDataStack.persistentContainer.viewContext

        do {
            try SeedDataService.createCurrenciesHoldersKeepers(coreDataStack: coreDataStack)
            let currency = try Currency.getCurrencyForCode("UAH", context: context)!
            try Currency.changeAccountingCurrency(old: nil, new: currency, context: context)
            SeedDataService.addBaseAccounts(accountingCurrency: currency, context: context)
        } catch let error {
            print("error", error.localizedDescription)
        }
    }

    override func tearDown() {
        super.tearDown()
        coreDataStack = nil
    }

    func testIsReservedAccountName() {
        XCTAssertTrue(Account.isReservedAccountName("Expenses"))
        XCTAssertFalse(Account.isReservedAccountName("Food"))
    }

    func testIsFreeAccountName () {
        let name1 = "Name1"
        let accType = Account.TypeEnum.assets
        let name2 = "Name2"

        // Chkeck for case when parent == nil
        XCTAssertTrue(Account.isFreeAccountName(parent: nil, name: name1, context: context))

        var account1: Account?
        XCTAssertNoThrow(account1 = try Account.createAndGetAccount(parent: nil,
                                                                    name: name1,
                                                                    type: accType,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created")

        XCTAssertNotNil(account1)

        XCTAssertFalse(Account.isFreeAccountName(parent: nil,
                                                 name: name1,
                                                 context: context),
                       "Name should be used by account1")

        // Chkeck for case when parent != nil
        XCTAssertTrue(Account.isFreeAccountName(parent: account1,
                                                name: name2,
                                                context: context),
                      "Name should be free to use")

        var account2: Account?
        XCTAssertNoThrow(account2 = try Account.createAndGetAccount(parent: account1,
                                                                    name: name2,
                                                                    type: .liabilities,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created")

        XCTAssertTrue(account2?.type == account1?.type)
        XCTAssertNotNil(account2)
        XCTAssertFalse(Account.isFreeAccountName(parent: account1,
                                                 name: name2,
                                                 context: context),
                       "Name should be used by account1")

        context.rollback()
    }

    func testNotReservedNameAccountCreatedByUser () throws {
        let name1 = "Name1"
        let name2 = "Name2"
        let accType = Account.TypeEnum.assets
        let subType = Account.SubTypeEnum.cash

        // WO Parent
        var accountWOParent: Account!
        XCTAssertNoThrow(accountWOParent = try Account.createAndGetAccount(parent: nil,
                                                                           name: name1,
                                                                           type: accType,
                                                                           currency: nil,
                                                                           subType: subType,
                                                                           createdByUser: true,
                                                                           context: context),
                         "Account should be created")

        XCTAssertTrue(accountWOParent.name == name1)
        XCTAssertTrue(accountWOParent.path == name1)
        XCTAssertTrue(accountWOParent.type == accType)
        XCTAssertTrue(accountWOParent.subType == subType)
        XCTAssertNotNil(accountWOParent.type)
        XCTAssertNil(accountWOParent.parent)
        XCTAssertNil(accountWOParent.currency)
        XCTAssertTrue(accountWOParent.createdByUser)
        XCTAssertTrue(accountWOParent.modifiedByUser)
        XCTAssertTrue(accountWOParent.active)

        XCTAssertNoThrow(try accountWOParent.changeActiveStatus())
        XCTAssertFalse(accountWOParent.active)

        // With Parent
        var accountWithParent: Account!
        XCTAssertNoThrow(accountWithParent = try Account.createAndGetAccount(parent: accountWOParent,
                                                                             name: name2,
                                                                             type: .liabilities,
                                                                             currency: nil,
                                                                             createdByUser: true,
                                                                             context: context),
                         "Account should not be created")
        XCTAssertNotNil(accountWithParent)

        // Check inherited attributes values
        XCTAssertEqual(accountWithParent.type, accountWOParent.type)
        XCTAssertEqual(accountWithParent.path, accountWOParent.path + ":" + accountWithParent.name)
        XCTAssertFalse(accountWithParent.active)
        context.rollback()
    }

    func testCatchCreateAndGetMethodErrors () { // swiftlint:disable:this function_body_length
        var account: Account?
        XCTAssertThrowsError(
            account = try Account.createAndGetAccount(parent: nil,
                                                                       name: "",
                                                                       type: .assets,
                                                                       currency: nil,
                                                                       createdByUser: true,
                                                                       context: context),
                             "User cannot create empty named account", {error in
            XCTAssertEqual(error as? AccountError, AccountError.emptyName)
            context.rollback()
        })
        XCTAssertNil(account)

        XCTAssertThrowsError(
            account = try Account.createAndGetAccount(parent: nil,
                                                                       name: "",
                                                                       type: .assets,
                                                                       currency: nil,
                                                                       createdByUser: false,
                                                                       context: context),
                             "App cannot create empty named account", {error in
            XCTAssertEqual(error as? AccountError, AccountError.emptyName)
            context.rollback()
        })
        XCTAssertNil(account)

        XCTAssertThrowsError(
            account = try Account.createAndGetAccount(parent: nil,
                                                                       name: "Other",
                                                                       type: .assets,
                                                                       currency: nil,
                                                                       createdByUser: true,
                                                                       context: context),
                             "User cannot create account with reserved name", {error in
            XCTAssertEqual(error as? AccountError, AccountError.reservedName(name: "Other"))}
        )
        XCTAssertNil(account)

        XCTAssertNoThrow(
            account = try Account.createAndGetAccount(parent: nil,
                                                                   name: "Other",
                                                                   type: .assets,
                                                                   currency: nil,
                                                                   createdByUser: false,
                                                                   context: context),
                         "App can create account with reserved name"
        )
        XCTAssertNotNil(account)

        XCTAssertNoThrow(account = try Account.createAndGetAccount(parent: nil,
                                                                   name: "Non reserved name",
                                                                   type: .assets,
                                                                   currency: nil,
                                                                   createdByUser: false,
                                                                   context: context),
                         "App can create account with non reserved name"
        )
        XCTAssertNotNil(account)

        context.rollback()
    }

    func testDuplicatedOtherAccountDontCreate() { // swiftlint:disable:this function_body_length

        var account1: Account?
        XCTAssertNoThrow(account1 = try Account.createAndGetAccount(parent: nil,
                                                                    name: "account1",
                                                                    type: .assets,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created")
        XCTAssertNotNil(account1)

        var account2: Account?
        XCTAssertNoThrow(account2 = try Account.createAndGetAccount(parent: account1,
                                                                    name: "account2",
                                                                    type: .assets,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created")
        XCTAssertNotNil(account2)

        Transaction.addTransactionWith2TranItems(date: Date(),
                                                 debit: account2!,
                                                 credit: account2!,
                                                 debitAmount: 10,
                                                 creditAmount: 10,
                                                 comment: nil,
                                                 createdByUser: true,
                                                 context: context)

        var account3: Account?
        XCTAssertNoThrow(account3 = try Account.createAndGetAccount(parent: account2,
                                                                    name: "account3",
                                                                    type: .assets,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created")
        XCTAssertNotNil(account3)

        Transaction.addTransactionWith2TranItems(date: Date(),
                                                 debit: account2!,
                                                 credit: account2!,
                                                 debitAmount: 10,
                                                 creditAmount: 10,
                                                 comment: nil,
                                                 createdByUser: true,
                                                 context: context)
        XCTAssertThrowsError(try Account.createAccount(parent: account2,
                                                       name: "Other",
                                                       type: .assets,
                                                       currency: nil,
                                                       createdByUser: true,
                                                       context: context),
                             "Account shouldn't be created", {error in
            XCTAssertEqual(error as? AccountError, AccountError.reservedName(name: "Other"))}
        )

        var account5: Account?
        XCTAssertNoThrow(account5 = try Account.createAndGetAccount(parent: account2,
                                                                    name: "Other",
                                                                    type: .assets,
                                                                    currency: nil,
                                                                    createdByUser: false,
                                                                    context: context),
                         "Account should be created. Coz app can create other account"
        )
        XCTAssertNotNil(account5)

        XCTAssertEqual(account2?.childrenList.count, 3)

        context.rollback()
    }

    func testMoveTransactionItemsFromConsolidatedAccount() { // swiftlint:disable:this function_body_length
        var account1: Account?
        XCTAssertNoThrow(account1 = try Account.createAndGetAccount(parent: nil,
                                                                    name: "account1",
                                                                    type: .assets,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created")
        XCTAssertNotNil(account1)

        var account2: Account?
        XCTAssertNoThrow(account2 = try Account.createAndGetAccount(parent: account1,
                                                                    name: "account2",
                                                                    type: .assets,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created")
        XCTAssertNotNil(account2)

        Transaction.addTransactionWith2TranItems(date: Date(),
                                                 debit: account2!,
                                                 credit: account2!,
                                                 debitAmount: 10,
                                                 creditAmount: 10,
                                                 comment: nil,
                                                 createdByUser: true,
                                                 context: context)

        var account3: Account?
        XCTAssertNoThrow(account3 = try Account.createAndGetAccount(parent: account2,
                                                                    name: "account3",
                                                                    type: .assets,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created")
        XCTAssertNotNil(account3)

        let other = account2?.getSubAccountWith(name: LocalizationManager.getLocalizedName(.other1))
        XCTAssertEqual(other?.transactionItemsList.count, 2)

        Transaction.addTransactionWith2TranItems(date: Date(),
                                                 debit: account2!,
                                                 credit: account2!,
                                                 debitAmount: 10,
                                                 creditAmount: 10,
                                                 comment: nil,
                                                 createdByUser: true,
                                                 context: context)

        var account4: Account?
        XCTAssertNoThrow(account4 = try Account.createAndGetAccount(parent: account2,
                                                                    name: "account4",
                                                                    type: .assets,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created"
        )
        XCTAssertEqual(other?.transactionItemsList.count, 4)

        context.rollback()
    }

    func testAccountCreatedByAppNotReservedName () {
        let name = "Some name"
        let accType = Account.TypeEnum.assets
        do {
            let account = try Account.createAndGetAccount(parent: nil,
                                                          name: name,
                                                          type: accType,
                                                          currency: nil,
                                                          createdByUser: false,
                                                          context: context)
            XCTAssertTrue(account.name == name)
            XCTAssertTrue(account.path == name)
            XCTAssertTrue(account.type == accType)
            XCTAssertTrue(account.subType == .none)
            XCTAssertNil(account.parent)
            XCTAssertNil(account.currency)
            XCTAssertFalse(account.createdByUser)
            XCTAssertFalse(account.modifiedByUser)
            context.rollback()
        } catch {
            XCTAssertTrue(false)
        }
    }

    func testAccountCreatedByAppReservedName () {
        let name = "Expense"
        let accType = Account.TypeEnum.assets
        do {
            let account = try Account.createAndGetAccount(parent: nil,
                                                          name: name,
                                                          type: accType,
                                                          currency: nil,
                                                          createdByUser: false,
                                                          context: context)
            XCTAssertTrue(account.name == name)
            XCTAssertTrue(account.path == name)
            XCTAssertTrue(account.type == accType)
            XCTAssertTrue(account.subType == .none)
            XCTAssertNil(account.parent)
            XCTAssertNil(account.currency)
            XCTAssertFalse(account.createdByUser)
            XCTAssertFalse(account.modifiedByUser)
            context.rollback()
        } catch {
            XCTAssertTrue(false)
        }
    }

    func testCreatMoneyAccount () {
        let name = "Some name"
        let accType = Account.TypeEnum.assets
        let moneyAccountType = Account.SubTypeEnum.cash
        do {
            let account = try Account.createAndGetAccount(parent: nil,
                                                          name: name,
                                                          type: accType,
                                                          currency: nil,
                                                          subType: moneyAccountType,
                                                          createdByUser: false,
                                                          context: context)
            XCTAssertTrue(account.name == name)
            XCTAssertTrue(account.path == name)
            XCTAssertTrue(account.type == accType)
            XCTAssertTrue(account.subType == moneyAccountType)
            XCTAssertNil(account.parent)
            XCTAssertNil(account.currency)
            XCTAssertFalse(account.createdByUser)
            XCTAssertFalse(account.modifiedByUser)
            context.rollback()
        } catch {
            XCTAssertTrue(false)
        }
    }

    func testAccountWithParent() {
        let name1 = "Name1"
        let accType = Account.TypeEnum.assets
        let name2 = "Name2"
        do {
            let account1 = try Account.createAndGetAccount(parent: nil,
                                                           name: name1,
                                                           type: accType,
                                                           currency: nil,
                                                           createdByUser: false,
                                                           context: context)
            let account2 = try Account.createAndGetAccount(parent: account1,
                                                           name: name2,
                                                           type: accType,
                                                           currency: nil,
                                                           createdByUser: false,
                                                           context: context)
            XCTAssertTrue(account2.parent == account1) // создание субсчета 2 для счета 1
            XCTAssertTrue(account2.type == account1.type) // субсчет наследуют тип счета от родителя
            XCTAssertTrue(account1.path == name1)
            XCTAssertTrue(account2.path == "\(name1):\(name2)")
            context.rollback()
        } catch {
            XCTAssertTrue(false)
        }
    }

    func testDuplicatedAccountName() throws {
        let name1 = "Name1"
        let accType = Account.TypeEnum.assets
        let name2 = "Name2"

        var account1: Account?
        XCTAssertNoThrow(account1 = try Account.createAndGetAccount(parent: nil,
                                                                    name: name1,
                                                                    type: accType,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created")
        XCTAssertNotNil(account1)

        var account2: Account?
        XCTAssertNoThrow(account2 = try Account.createAndGetAccount(parent: account1,
                                                                    name: name2,
                                                                    type: accType,
                                                                    currency: nil,
                                                                    createdByUser: true,
                                                                    context: context),
                         "Account should be created")
        XCTAssertNotNil(account2)

        XCTAssertThrowsError(try Account.createAndGetAccount(parent: account1,
                                                             name: name2,
                                                             type: accType,
                                                             currency: nil,
                                                             createdByUser: true,
                                                             context: context),
                             "Duplicated name", {error in
            XCTAssertEqual(error as? AccountError, AccountError.accountAlreadyExists(name: name2))
            context.rollback()
        })
        context.rollback()
    }
} // swiftlint:disable:this file_length
