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
            var newAccount = parent.getSubAccountWith(name: LocalisationManager.getLocalizedName(.other1))
            if newAccount == nil {
                newAccount = try createAndGetAccount(parent: parent,
                                                     name: LocalisationManager.getLocalizedName(.other1),
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
                throw Account.Error.accountAlreadyExists(name: name)
            } else {
                throw Account.Error.categoryAlreadyExists(name: name)
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
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue).\(Schema.Account.parent.rawValue) = nil") // swiftlint:disable:this line_length
        return (try? context.fetch(fetchRequest)) ?? []
    }

    static func getAccountList(context: NSManagedObjectContext) throws -> [Account] {
        let accountFetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        return try context.fetch(accountFetchRequest)
    }

    static func getAccountWithPath(_ path: String, context: NSManagedObjectContext) -> Account? {
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        do {
            let accounts = try context.fetch(fetchRequest)
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
        request.predicate = NSPredicate(format: "\(Schema.Account.id.rawValue) = %@", argumentArray: [id.uuidString])
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        return try? context.fetch(request).first
    }

    static func exportAccountsToString(context: NSManagedObjectContext) -> String {
        /*
         let accountFetchRequest: NSFetchRequest<Account> = fetchRequest()
         let sortDescroptors = [NSSortDescriptor(key: "\(Schema.Account.parent.rawValue).\(Schema.Account.name.rawValue)", ascending: true),
         NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
         accountFetchRequest.sortDescriptors = sortDescroptors
         do {
         let storedAccounts = try context.fetch(accountFetchRequest)
         var export: String = "ParentAccount_path,Account_name,active,Account_type,Account_currency,Account_SubType,LinkedAccount_path\n"
         for account in storedAccounts {

         var accountType = ""
         switch account.type {
         case TypeEnum.assets:
         accountType = "Assets"
         case TypeEnum.liabilities:
         accountType = "Liabilities"
         default:
         accountType = "Out of enumeration"
         }

         var accountSubType = ""
         switch account.subType {
         case SubTypeEnum.none:
         accountSubType = ""
         case SubTypeEnum.cash:
         accountSubType = "Cash"
         case SubTypeEnum.debitCard:
         accountSubType = "DebitCard"
         case SubTypeEnum.creditCard:
         accountSubType = "CreditCard"
         default:
         accountSubType = "Out of enumeration"
         }

         export +=  "\(account.parent != nil ? account.parent!.path : "" ),"
         export +=  "\(account.name),"
         export +=  "\(account.active),"
         export +=  "\(accountType),"
         export +=  "\(account.currency?.code ?? "MULTICURRENCY"),"
         export +=  "\(accountSubType),"
         export +=  "\(account.linkedAccount != nil ? account.linkedAccount!.path: "" )\n"
         }
         return export
         } catch let error {
         print("ERROR", error)
         */
        return ""
        //        }
    }

    static func importAccounts(_ data: String, context: NSManagedObjectContext) throws { // swiftlint:disable:this cyclomatic_complexity function_body_length
        /*
         var accountToBeAdded: [Account] = []
         var inputMatrix: [[String]] = []
         let rows = data.components(separatedBy: "\n")
         for row in rows {
         let columns = row.components(separatedBy: ",")
         inputMatrix.append(columns)
         }
         inputMatrix.remove(at: 0)

         for row in inputMatrix {
         guard row.count > 1 else {break}

         let parent = AccountHelper.getAccountWithPath(row[0], context: context)

         let name = String(row[1])

         var active = false
         switch row[2] {
         case "false":
         active = false
         case "true":
         active = true
         default:
         break // throw ImportAccountError.invalidactiveValue
         }

         var accountType: Int16 = 0
         switch row[3] {
         case "Assets":
         accountType = TypeEnum.assets.rawValue
         case "Liabilities":
         accountType = TypeEnum.liabilities.rawValue
         default:
         break // throw ImportAccountError.invalidAccountTypeValue
         }

         let curency = try? Currency.getCurrencyForCode(row[4], context: context)

         var accountSubType: Int16 = 0
         switch row[5] {
         case "":
         accountSubType = 0
         case "Cash":
         accountSubType = 1
         case "DebitCard":
         accountSubType = 2
         case "CreditCard":
         accountSubType = 3
         default:
         break // throw ImportAccountError.invalidAccountSubTypeValue
         }

         let linkedAccount = AccountHelper.getAccountWithPath(row[6], context: context)

         let account = try? AccountHelper.createAndGetAccount(parent: parent,
         name: name,
         type: TypeEnum(rawValue: accountType)!,
         currency: curency,
         impoted: true,
         context: context)
         account?.linkedAccount = linkedAccount
         account?.subType = SubTypeEnum(rawValue: accountSubType) ?? .none
         account?.active = active

         // CHECKING
         if let account = account {
         accountToBeAdded.append(account)
         var accountTypes = ""
         switch account.type {
         case TypeEnum.assets:
         accountTypes = "Assets"
         case TypeEnum.liabilities:
         accountTypes = "Liabilities"
         default:
         accountTypes = "Out of enumeration"
         }

         var accountSubTypes = ""
         switch account.subType {
         case SubTypeEnum.none:
         accountSubTypes = ""
         case SubTypeEnum.cash:
         accountSubTypes = "Cash"
         case SubTypeEnum.debitCard:
         accountSubTypes = "DebitCard"
         case SubTypeEnum.creditCard:
         accountSubTypes = "CreditCard"
         default:
         accountSubTypes = "Out of enumeration"
         }
         var export = ""
         export +=  "\(account.parent != nil ? account.parent!.path: "" ),"
         export +=  "\(account.name),"
         export +=  "\(account.active),"
         export +=  "\(accountTypes),"
         export +=  "\(account.currency?.code ?? "MULTICURRENCY"),"
         export +=  "\(accountSubTypes),"
         export +=  "\(account.linkedAccount != nil ? account.linkedAccount!.path: "" )\n"
         //            print(export)
         } else {
         print("There is no account")
         }
         }
         */
    }
}
