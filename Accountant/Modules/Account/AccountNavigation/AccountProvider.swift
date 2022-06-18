//
//  AccountProvider.swift
//  Accountant
//
//  Created by Roman Topchii on 21.04.2022.
//

import Foundation
import CoreData

class AccountProvider {

    enum ActionEnum {
        case create
        case rename
        case delete
        case changeActiveStatus
    }

    var parent: Account?
    var excludeAccountList: [Account] = []
    var showHiddenAccounts: Bool = true
    var canModifyAccountStructure: Bool = true
    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?

    private(set) var persistentContainer: NSPersistentContainer
    private(set) var isSwipeAvailable: Bool = true

    private lazy var context: NSManagedObjectContext = {
        if let parent = parent, let managedObjectContext = parent.managedObjectContext {
            return managedObjectContext
        } else {
            return persistentContainer.viewContext
        }
    }()

    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    lazy var fetchedResultsController: NSFetchedResultsController<Account> = {
        let fetchRequest = Account.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.path.rawValue, ascending: true)]
        var predicate = NSPredicate()
        if let parent = parent {
            predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue) = %@ && "
                                    + "NOT (SELF IN %@) && "
                                    +  "(\(Schema.Account.active.rawValue) = true "
                                    + "|| \(Schema.Account.active.rawValue) != %@)",
                                    argumentArray: [parent, excludeAccountList, showHiddenAccounts])
        } else {
            predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue).\(Schema.Account.name) = %@ && "
                                    + "NOT (SELF IN %@) && "
                                    +  "(\(Schema.Account.active.rawValue) = true "
                                    + "|| \(Schema.Account.active.rawValue) != %@)",
                                    argumentArray: ["Accounts", excludeAccountList, showHiddenAccounts])
        }
        fetchRequest.predicate = predicate

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("###\(#function): Failed to performFetch: \(nserror), \(nserror.userInfo)")
        }
        return controller
    }()

    func addCategoty(parent: Account, name: String, createdByUser: Bool = true,
                     createDate: Date = Date(), shouldSave: Bool = true) throws {
        let backgroundContext = persistentContainer.newBackgroundContext()

        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Account.id.rawValue) = %@", parent.id as CVarArg)

        guard let parent = try backgroundContext.fetch(fetchRequest).first else {return}

        guard !name.isEmpty else {throw Account.Error.emptyName}

        // accounts with reserved names can create only app
        guard createdByUser == false || AccountHelper.isReservedAccountName(name) == false
        else {throw Account.Error.reservedName(name: name)}

        guard AccountHelper.isFreeAccountName(parent: parent, name: name, context: backgroundContext) == true else {
            if parent.currency == nil {
                throw Account.Error.accountAlreadyExists(name: name)
            } else {
                throw Account.Error.categoryAlreadyExists(name: name)
            }
        }

        guard parent.rootAccount.currency != nil else {return}
        backgroundContext.performAndWait {
            // Adding "Other" account for cases when parent containts transactions
            if parent.isFreeFromTransactionItems == false,
               AccountHelper.isReservedAccountName(name) == false {
                var otherAccount = parent.getSubAccountWith(name: LocalisationManager.getLocalizedName(.other1))
                if otherAccount == nil {
                    otherAccount = Account(parent: parent,
                                         name: LocalisationManager.getLocalizedName(.other1),
                                         context: backgroundContext)
                }
                if let otherAccount = otherAccount {
                    TransactionItemHelper.moveTransactionItemsFrom(oldAccount: parent, newAccount: otherAccount,
                                                             modifiedByUser: createdByUser, modifyDate: createDate)
                }
            }
            let newAccount = Account(parent: parent, name: name, createdByUser: createdByUser,
                        createDate: createDate, context: backgroundContext)
            if let defultChildType = parent.type.defultChildType {
                newAccount.type = defultChildType
            } else {
                fatalError("parent.type.defultChildType should return value")
            }
            if shouldSave {
                backgroundContext.save(with: .addAccount)
            }
        }
    }

    func renameAccount(at indexPath: IndexPath, newName: String, modifiedByUser: Bool = true,
                       modifyDate: Date = Date(), shouldSave: Bool = true) throws {
        let account = fetchedResultsController.object(at: indexPath)
        guard AccountHelper.isReservedAccountName(newName) == false
        else {throw Account.Error.reservedName(name: newName)}

        guard AccountHelper.isFreeAccountName(parent: account.parent, name: newName, context: context)
        else {
            if self.parent?.currency == nil {
                throw Account.Error.accountAlreadyExists(name: newName)
            } else {
                throw Account.Error.categoryAlreadyExists(name: newName)
            }
        }

        let objectID  = fetchedResultsController.object(at: indexPath).objectID
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.performAndWait {

            guard let accountInBackgroundContext = backgroundContext.object(with: objectID) as? Account else {
                fatalError("###\(#function): Failed to cast object to Account")
            }
            accountInBackgroundContext.name = newName
            accountInBackgroundContext.path = account.pathCalc
            accountInBackgroundContext.modifyDate = Date()
            accountInBackgroundContext.modifiedByUser = true

            for child in accountInBackgroundContext.childrenList {
                child.path = child.pathCalc
            }

            if shouldSave {
                backgroundContext.save(with: .renameAccount)
            }
        }
    }

    func allowedActions(at indexPath: IndexPath) -> [ActionEnum] {
        guard isSwipeAvailable else {return []}
        let selectedAccount = fetchedResultsController.object(at: indexPath)
        var result: [ActionEnum] = []
        if let parent = selectedAccount.parent, (
            parent.name == LocalisationManager.getLocalizedName(.money) // can have only one lvl of subAccounts
            || parent.name == LocalisationManager.getLocalizedName(.credits) // can have only one lvl od subAccounts
            || parent.name == LocalisationManager.getLocalizedName(.debtors) // can have only one lvl od subAccounts
            || selectedAccount.name == LocalisationManager.getLocalizedName(.other1) // can not have subAccount
            || selectedAccount.name == LocalisationManager.getLocalizedName(.beforeAccountingPeriod) // coz it used in system generated transactions
        ) {

        } else if selectedAccount.parent == nil && selectedAccount.name == LocalisationManager.getLocalizedName(.capital) {
            // can not have subAccount, coz it used in system generated transactions

        } else {
            result.append(.create)
        }

        if selectedAccount.canBeRenamed {
            result.append(.rename)
            result.append(.delete)
        }

        if selectedAccount.parent != nil || (selectedAccount.parent == nil && selectedAccount.createdByUser == true) {
            result.append(.changeActiveStatus)
        }
        return result
    }

    func changeActiveStatus(indexPath: IndexPath, modifiedByUser: Bool = true, modifyDate: Date = Date(),
                            shouldSave: Bool = true) throws {

        let objectID  = fetchedResultsController.object(at: indexPath).objectID
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.performAndWait {

            guard let accountInBackgroundContext = backgroundContext.object(with: objectID) as? Account else {
                fatalError("###\(#function): Failed to cast object to Account")
            }

            let oldActive = accountInBackgroundContext.active

            accountInBackgroundContext.active = !oldActive
            accountInBackgroundContext.modifyDate = modifyDate
            accountInBackgroundContext.modifiedByUser = modifiedByUser

            if oldActive {// deactivation
                for anc in accountInBackgroundContext.childrenList.filter({$0.active == oldActive}) {
                    anc.active = !oldActive
                    anc.modifyDate = modifyDate
                    anc.modifiedByUser = modifiedByUser
                }
            } else {// activation
                for anc in accountInBackgroundContext.ancestorList.filter({$0.active == oldActive}) {
                    anc.active = !oldActive
                    anc.modifyDate = modifyDate
                    anc.modifiedByUser = modifiedByUser
                }
            }

            if shouldSave {
                backgroundContext.save(with: .changeAccountActiveStatus)
            }
        }
    }

    func delete(at indexPath: IndexPath, shouldSave: Bool = true) throws {
        let account = fetchedResultsController.object(at: indexPath)

        var accounts = account.childrenList
        accounts.append(account)
        var accountUsedInTransactionItem: [Account] = []
        for acc in accounts where !acc.isFreeFromTransactionItems {
            accountUsedInTransactionItem.append(acc)
        }

        if !accountUsedInTransactionItem.isEmpty {
            var accountListString: String = ""
            accountUsedInTransactionItem.forEach({
                accountListString += "\n" + $0.path
            })

            if account.parent?.currency == nil {
                throw Account.Error.accountUsedInTransactionItem(name: accountListString)
            } else {
                throw Account.Error.categoryUsedInTransactionItem(name: accountListString)
            }
        }
        if let linkedAccount = account.linkedAccount, !linkedAccount.isFreeFromTransactionItems {
            throw Account.Error.linkedAccountUsedTranItem(name: linkedAccount.path)
        }

        let objectID  = fetchedResultsController.object(at: indexPath).objectID
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.performAndWait {

            guard let accountInBackgroundContext = backgroundContext.object(with: objectID) as? Account else {
                fatalError("###\(#function): Failed to cast object to Account")
            }

            if let linkedAccount = accountInBackgroundContext.linkedAccount {
                backgroundContext.delete(linkedAccount)
            }
            accountInBackgroundContext.childrenList.forEach({
                backgroundContext.delete($0)
            })
            backgroundContext.delete(accountInBackgroundContext)
            if shouldSave {
                backgroundContext.save(with: .deleteAccount)
            }
        }
    }

    func isFreeAccountName(name: String) -> Bool {
        if let parent = parent {
            for child in parent.childrenList where child.name == name {
                return false
            }
            return true
        } else {
            let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue) = nil && " +
                                                 "\(Schema.Account.name.rawValue) = %@", name)
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

    func resetPredicate() {
        var predicate = NSPredicate()
        if let parent = parent {
            predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue) = %@ && "
                                    + "NOT (SELF IN %@) && "
                                    +  "(\(Schema.Account.active.rawValue) = true "
                                    + "|| \(Schema.Account.active.rawValue) != %@)",
                                    argumentArray: [parent, excludeAccountList, showHiddenAccounts])
        } else {
            predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue).\(Schema.Account.name) = %@ && "
                                    + "NOT (SELF IN %@) && "
                                    +  "(\(Schema.Account.active.rawValue) = true "
                                    + "|| \(Schema.Account.active.rawValue) != %@)",
                                    argumentArray: ["Accounts", excludeAccountList, showHiddenAccounts])
        }
        fetchedResultsController.fetchRequest.predicate = predicate
    }

    func search(_ text: String) {
        if text.count != 0 {
            var prdct = NSPredicate()
            if let parent = parent {
                prdct = NSPredicate(format: "SELF != %@ && NOT (SELF IN %@)"
                                    + "&& \(Schema.Account.path.rawValue) CONTAINS[c] %@ "
                                    + "&& \(Schema.Account.path.rawValue) CONTAINS[c] %@ "
                                    + "&& (\(Schema.Account.active.rawValue) = true "
                                    + "|| \(Schema.Account.active.rawValue) != %@)",
                                    argumentArray: [parent, excludeAccountList, parent.path, text, showHiddenAccounts])
            } else {
                prdct = NSPredicate(format: "\(Schema.Account.path.rawValue) CONTAINS[c] %@ && "
                                    + "(\(Schema.Account.active.rawValue) = true "
                                    + "|| \(Schema.Account.active.rawValue) != %@) "
                                    + "&& NOT (SELF IN %@)",
                                    argumentArray: [text, showHiddenAccounts, excludeAccountList])
            }
            fetchedResultsController.fetchRequest.predicate = prdct
            isSwipeAvailable = false
        } else {
            resetPredicate()
            isSwipeAvailable = true
        }
        reloadData()
    }

    func reloadData() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("###\(#function): Failed to performFetch: \(nserror), \(nserror.userInfo)")
        }
    }
}
