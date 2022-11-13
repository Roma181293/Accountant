//
//  Account extension.swift
//  Accountant
//
//  Created by Roman Topchii on 17.06.2022.
//

import Foundation
import CoreData

extension Account {

    var rootAccount: Account {
        if let parent = parent, level > 1 {
            return parent.rootAccount
        }
        return self
    }

    var ancestorList: [Account] {
        if let parent = parent {
            return [parent] + parent.ancestorList
        }
        return []
    }

    var pathCalc: String {
        if let parent = parent {
            if level == 1 {
                return name
            } else {
                return parent.pathCalc + ":" + name
            }
        }
        return name
    }

    var level: Int {
        if let parent = parent {
            return parent.level + 1
        }
        return 0
    }

    var directChildrenList: [Account] {
        return Array(directChildren)
    }

    var childrenList: [Account] {
        var result: [Account] = self.directChildrenList
        for child in directChildrenList {
            result.append(contentsOf: child.childrenList)
        }
        return result
    }

    var transactionItemsList: [TransactionItem] {
        return Array(transactionItems)
    }

    var transactionItemsListReadyForBalanceCalc: [TransactionItem] {
        return transactionItemsList.filter({$0.transaction!.status == .applied || $0.transaction!.status == .archived})
    }

    var isFreeFromTransactionItems: Bool {
        return transactionItemsList.isEmpty
    }

    func accountListUsingInTransactions() -> [Account] {
        var accounts = childrenList
        accounts.append(self)
        return accounts.filter({$0.isFreeFromTransactionItems == false})
    }

    func getSubAccountWith(name: String) -> Account? {
        for child in childrenList where child.name == name {
            return child
        }
        return nil
    }

    func changeActiveStatus(modifiedByUser: Bool = true, modifyDate: Date = Date()) throws {

        let oldActive = self.active

        self.active = !oldActive
        self.modifyDate = modifyDate
        self.modifiedByUser = modifiedByUser

        if oldActive {// deactivation
            for anc in self.childrenList.filter({$0.active == oldActive}) {
                anc.active = !oldActive
                anc.modifyDate = modifyDate
                anc.modifiedByUser = modifiedByUser
            }
        } else {// activation
            for anc in self.ancestorList.filter({$0.active == oldActive}) {
                anc.active = !oldActive
                anc.modifyDate = modifyDate
                anc.modifiedByUser = modifiedByUser
            }
        }
    }

    func rename(to newName: String, context: NSManagedObjectContext) throws {
        guard AccountHelper.isReservedAccountName(newName) == false else {throw Account.Error.reservedName(name: newName)}
        guard AccountHelper.isFreeAccountName(parent: self.parent, name: newName, context: context)
        else {
            if self.parent?.currency == nil {
                throw Account.Error.accountNameAlreadyTaken(name: newName)
            } else {
                throw Account.Error.categoryNameAlreadyTaken(name: newName)
            }
        }
        self.name = newName
        self.modifyDate = Date()
        self.modifiedByUser = true
    }

    func canBeRemoved() throws {
        var accounts = childrenList
        accounts.append(self)
        var accountUsedInTransactionItem: [Account] = []
        for acc in accounts where !acc.isFreeFromTransactionItems {
            accountUsedInTransactionItem.append(acc)
        }

        if !accountUsedInTransactionItem.isEmpty {
            var accountListString: String = ""
            accountUsedInTransactionItem.forEach({
                accountListString += "\n" + $0.path
            })

            if parent?.currency == nil {
                throw Account.Error.accountUsedInTransactionItem(name: accountListString)
            } else {
                throw Account.Error.categoryUsedInTransactionItem(name: accountListString)
            }
        }
        if let linkedAccount = linkedAccount, !linkedAccount.isFreeFromTransactionItems {
            throw Account.Error.linkedAccountUsedTranItem(name: linkedAccount.path)
        }
    }

    func delete(eligibilityChacked: Bool = false) throws {
        var accounts = childrenList
        accounts.append(self)
        if eligibilityChacked == false {
            try canBeRemoved()
            if let linkedAccount = linkedAccount {
                accounts.append(linkedAccount)
            }
            accounts.forEach({
                managedObjectContext?.delete($0)
            })
        } else {
            if let linkedAccount = linkedAccount {
                accounts.append(linkedAccount)
            }
            accounts.forEach({
                managedObjectContext?.delete($0)
            })
        }
    }

    enum Error: AppError, Equatable {
        case accountNameAlreadyTaken(name: String)
        case categoryNameAlreadyTaken(name: String)
        case accountUsedInTransactionItem(name: String)
        case categoryUsedInTransactionItem(name: String)
        case creditAccountAlreadyExist(String)  // for cases when creates linked account
        case reservedName(name: String)
        case accountDoesNotExist(name: String)
        case linkedAccountUsedTranItem(name: String)
        case emptyName
        case activeStatusCannotBeChanged
    }
}

extension Account.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .accountNameAlreadyTaken(name):
            return String(format: NSLocalizedString("Account name \"%@\" is already taken. Please use another name",
                                                    comment: ""), name)
        case let .categoryNameAlreadyTaken(name):
            return String(format: NSLocalizedString("Category name \"%@\" is already taken. Please use another name",
                                                    comment: ""), name)
        case .accountUsedInTransactionItem:
            return NSLocalizedString("This account cannot be deleted because of existing transactions", comment: "")
        case .categoryUsedInTransactionItem:
            return NSLocalizedString("This category cannot be deleted because of existing transactions", comment: "")
        case let .creditAccountAlreadyExist(name):
            return String(format: NSLocalizedString("We create an associated credit account with your credit cards. " +
                                                    "Credit account \"%@\" already exists", comment: ""), name)
        case let .reservedName(name):
            return NSLocalizedString("Name \"\(name)\" is reserved by the app. Please use another name", comment: "")
        case let .accountDoesNotExist(name):
            return String(format: NSLocalizedString("\"%@\" account does not exist. Please contact support",
                                                    comment: ""),
                          name)
        case let .linkedAccountUsedTranItem(name):
            return String(format: NSLocalizedString("Linked account \"%@\" cannot be removed because of existing " +
                                                    "transactions", comment: ""), name)
        case .emptyName:
            return NSLocalizedString("Please enter name", comment: "")
        case .activeStatusCannotBeChanged:
            return NSLocalizedString("Active status cannot be changed. Please contact to support", comment: "")
        }
    }
}
