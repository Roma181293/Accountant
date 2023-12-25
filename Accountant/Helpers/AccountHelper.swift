//
//  AccountHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 17.06.2022.
//

import Foundation
import CoreData

class AccountHelper {
    private static var reservedAccountNames: [String] {
        return [
            // EN
            "Accounts",
            "Income",
            "Expenses",
            "Capital",
            "Money",
            "Debtors",
            "Creditors",
            "Before accounting period",
            "<Other>",
            "Other",
            // UA
            "Рахунки",
            "Доходи",
            "Витрати",
            "Гроші",
            "Борги",
            "Боржники",
            "Капітал",
            "До обліковий період",
            "<Інше>",
            "Інше",
            // RU
            "Счета",
            "Доходы",
            "Расходы",
            "Деньги",
            "Долги",
            "Должники",
            "Капитал",
            "До учетный период",
            "<Прочее>",
            "Прочее"
        ]
    }

    static func isReservedAccountName(_ name: String) -> Bool {
        for item in reservedAccountNames {
            if item.uppercased() == name.uppercased() {
                return true
            }
        }
        return false
    }

    static func isFreeAccountName(parent: Account?, name: String, context: NSManagedObjectContext) -> Bool {
        if let parent = parent {
            for child in parent.childrenList where child.name == name {
                return false
            }
            return true
        } else {
            let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue) = nil and \(Schema.Account.name.rawValue) = %@", name)
            do {
                let accounts = try context.fetch(fetchRequest)
                if accounts.isEmpty {
                    return true
                } else {
                    return false
                }
            } catch let error {
                print("ERROR", error)
                return false
            }
        }
    }

    static func createAndGetAccount(parent: Account?, name: String, type: AccountType, currency: Currency?,
                                    keeper: Keeper? = nil, holder: Holder? = nil,
                                    createdByUser: Bool = true, createDate: Date = Date(),
                                    impoted: Bool = false, context: NSManagedObjectContext)
    throws -> Account {

        try validateAttributes(parent: parent, name: name, type: type, currency: currency, keeper: keeper,
                               holder: holder, createdByUser: createdByUser,
                               impoted: impoted, context: context)

        // Adding "Other" account for cases when parent containts transactions
        if let parent = parent, parent.isFreeFromTransactionItems == false,
           AccountHelper.isReservedAccountName(name) == false {
            var newAccount = parent.getSubAccountWith(name: LocalizationManager.getLocalizedName(.other1))
            if newAccount == nil {
                newAccount = try createAndGetAccount(parent: parent,
                                                     name: LocalizationManager.getLocalizedName(.other1),
                                                     type: type, currency: currency, keeper: keeper, holder: holder,
                                                     createdByUser: false, createDate: createDate,
                                                     context: context)
            }
            if newAccount != nil {
                TransactionItemHelper.moveTransactionItemsFrom(oldAccount: parent, newAccount: newAccount!,
                                                               modifiedByUser: createdByUser, modifyDate: createDate)
            }
        }

        return Account(parent: parent, name: name, type: type, currency: currency, keeper: keeper, holder: holder,
                       createdByUser: createdByUser, createDate: createDate, context: context)
    }

    static func createAccount(parent: Account?, name: String, type: AccountType, currency: Currency?,
                              keeper: Keeper? = nil, holder: Holder? = nil,
                              createdByUser: Bool = true, impoted: Bool = false,
                              context: NSManagedObjectContext) throws {

        _ = try createAndGetAccount(parent: parent, name: name, type: type, currency: currency,
                                    keeper: keeper, holder: holder, createdByUser: createdByUser,
                                    createDate: Date(), impoted: impoted, context: context)
    }

    private static func validateAttributes(parent: Account?, name: String, type: AccountType, currency: Currency?,
                                           keeper: Keeper? = nil, holder: Holder? = nil,
                                           createdByUser: Bool = true, impoted: Bool = false,
                                           context: NSManagedObjectContext) throws {

        guard !name.isEmpty else {throw Account.Error.emptyName}
        // accounts with reserved names can create only app
        if !impoted {
            guard createdByUser == false || isReservedAccountName(name) == false
            else {throw Account.Error.reservedName(name: name)}
        }
        guard isFreeAccountName(parent: parent, name: name, context: context) == true else {
            if parent?.currency == nil {
                throw Account.Error.accountNameAlreadyTaken(name: name)
            } else {
                throw Account.Error.categoryNameAlreadyTaken(name: name)
            }
        }
    }

    static func changeCurrencyForBaseAccounts(to currency: Currency, modifyDate: Date = Date(),
                                              modifiedByUser: Bool = true, context: NSManagedObjectContext) {
        let baseAccounts: [Account] = getRootAccountList(context: context)
        var acc: [Account] = []
        for item in baseAccounts {
            if let currency = item.currency, currency.isAccounting == true {
                acc.append(contentsOf: item.childrenList)
                acc.append(item)
            }
        }
        for account in acc {
            account.currency = currency
            account.modifiedByUser = modifiedByUser
            account.modifyDate = modifyDate
        }
    }

    static func getRootAccountList(context: NSManagedObjectContext) -> [Account] {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        request.predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue).\(Schema.Account.parent.rawValue) = nil") // swiftlint:disable:this line_length
        return (try? context.fetch(request)) ?? []
    }

    static func getAccountList(context: NSManagedObjectContext) throws -> [Account] {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        return try context.fetch(request)
    }

    static func getAccountListWithType(typeId: UUID, context: NSManagedObjectContext) throws -> [Account] {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]

        request.predicate = NSPredicate(format: "\(Schema.Account.type.rawValue).\(Schema.AccountType.id.rawValue) = %@", argumentArray: [typeId.uuidString])
        return try context.fetch(request)
    }

    static func getAccountWithPath(_ path: String, context: NSManagedObjectContext) -> Account? {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        do {
            let accounts = try context.fetch(request)
            if !accounts.isEmpty {
                for account in accounts where account.path == path {
                    return account
                }
                return nil
            } else {
                return nil
            }
        } catch let error {
            print("ERROR", error)
            return nil
        }
    }

    static func getAccountWithId(_ id: UUID, context: NSManagedObjectContext) -> Account? {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.predicate = NSPredicate(format: "\(Schema.Account.id.rawValue) = %@", id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        return try? context.fetch(request).first
    }

    static func existsForeignCurrencyAccount(context: NSManagedObjectContext) -> Bool? {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.predicate = NSPredicate(format: "\(Schema.Account.currency.rawValue).\(Schema.Currency.isAccounting) = false")
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        request.fetchLimit = 1
        return try? context.fetch(request).isEmpty
    }
}
