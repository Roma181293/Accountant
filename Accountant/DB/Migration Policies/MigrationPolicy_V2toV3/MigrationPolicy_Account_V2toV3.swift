//
//  MigrationPolicy_V2toV3Account.swift
//  Accountant
//
//  Created by Roman Topchii on 12.04.2022.
//

import Foundation
import CoreData

// swiftlint:disable line_length
class MigrationPolicy_Account_V2toV3: NSEntityMigrationPolicy { // swiftlint:disable:this type_name

    private let rootAccountToTypeMapping: [(accountName: String, accountTypeName: AccountType.NameEnum)] =
    [(LocalisationManager.getLocalizedName(.money), .moneyConsolidation),
     (LocalisationManager.getLocalizedName(.debtors), .debtorsConsolidation),
     (LocalisationManager.getLocalizedName(.credits), .creditorsConsolidation),
     (LocalisationManager.getLocalizedName(.expense), .expenseConsolidation),
     (LocalisationManager.getLocalizedName(.income), .incomeConsolidation),
     (LocalisationManager.getLocalizedName(.capital), .capitalConsolidation)]

    override func begin(_ mapping: NSEntityMapping, with manager: NSMigrationManager) throws {
        try super.begin(mapping, with: manager)
        seedAccountTypes(context: manager.destinationContext)
    }

    override func createDestinationInstances(forSource sInstance: NSManagedObject, // swiftlint:disable:this cyclomatic_complexity
                                             in mapping: NSEntityMapping,
                                             manager: NSMigrationManager) throws {

        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        if let destAccount = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).last {
            if sInstance.value(forKey: "parent") == nil {
                if let typeName = rootAccountToTypeMapping.filter({
                    $0.accountName == (sInstance.value(forKey: "name") as? String)
                }).first {
                    destAccount.setValue(getAccountTypeBy(typeName.accountTypeName, context: manager.destinationContext), forKey: "type")
                } else if sInstance.value(forKey: "type") as! Int16 == 0 { // swiftlint:disable:this force_cast
                    destAccount.setValue(getAccountTypeBy(.liabilitiesCategoryConsolidation, context: manager.destinationContext), forKey: "type")
                } else if sInstance.value(forKey: "type") as! Int16 == 1 { // swiftlint:disable:this force_cast
                    destAccount.setValue(getAccountTypeBy(.assetsCategoryConsolidation, context: manager.destinationContext), forKey: "type")
                }
            } else if let sourceParent = sInstance.value(forKey: "parent") as? NSManagedObject {
                if let parentName = sourceParent.value(forKey: "name") as? String,
                   let oldType = sourceParent.value(forKey: "type") as? Int16 {

                    if parentName == LocalisationManager.getLocalizedName(.money),
                       let subType = sInstance.value(forKey: "subType") as? Int16 {
                        switch subType {
                        case 1: destAccount.setValue(getAccountTypeBy(.cash, context: manager.destinationContext), forKey: "type")
                        case 2: destAccount.setValue(getAccountTypeBy(.debitCard, context: manager.destinationContext), forKey: "type")
                        case 3: destAccount.setValue(getAccountTypeBy(.creditCard, context: manager.destinationContext), forKey: "type")
                        default: break
                        }
                    } else if parentName == LocalisationManager.getLocalizedName(.debtors) {
                        destAccount.setValue(getAccountTypeBy(.debtor, context: manager.destinationContext), forKey: "type")
                    } else if parentName == LocalisationManager.getLocalizedName(.credits) {
                        destAccount.setValue(getAccountTypeBy(.creditor, context: manager.destinationContext), forKey: "type")
                    } else if oldType == 0 {
                        destAccount.setValue(getAccountTypeBy(.liabilitiesCategory, context: manager.destinationContext), forKey: "type")
                    } else if oldType == 1 {
                        destAccount.setValue(getAccountTypeBy(.assetsCategory, context: manager.destinationContext), forKey: "type")
                    }
                }
            }
        }
    }

    override func endRelationshipCreation(forMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.endRelationshipCreation(forMapping: mapping, manager: manager)

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let accounts = try manager.destinationContext.fetch(fetchRequest)

        for account in accounts {
            if let accountName = account.value(forKey: "name") as? String,
               let accountPath = account.value(forKey: "path") as? String {


                if accountName == LocalisationManager.getLocalizedName(.expense),
                   let currency = account.value(forKey: "currency") as? NSManagedObject {
                    let beforeAccountingPeriod = try getOrCreateAccount(name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod),
                                                                    context: manager.destinationContext)

                    beforeAccountingPeriod.setValue(accountPath+":"+LocalisationManager.getLocalizedName(.beforeAccountingPeriod),
                                                    forKey: "path")
                    beforeAccountingPeriod.setValue(currency, forKey: "currency")
                    beforeAccountingPeriod.setValue(getAccountTypeBy(.expenseBeforeAccountingPeriod,
                                                                     context: manager.destinationContext),
                                                    forKey: "type")
                    beforeAccountingPeriod.setValue(account, forKey: "parent")
                }

                for parent in accounts {
                    if let parentPath = parent.value(forKey: "path") as? String {
                        if parentPath + ":" + accountName == accountPath {
                            account.setValue(parent, forKey: "parent")
                        }
                    } else {
                        print("parent not set")
                    }
                }
            }
        }

        let type = getAccountTypeBy(.accounting, context: manager.destinationContext)
        LocalisationManager.createLocalizedAccountName(.accounts)
        let name = LocalisationManager.getLocalizedName(.accounts)
        let root = try getOrCreateAccount(name: name, context: manager.destinationContext)
        root.setValue(type, forKey: "type")

        for account in accounts where account.value(forKey: "parent") == nil {
            account.setValue(root, forKey: "parent")
        }
    }

    override func performCustomValidation(forMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.performCustomValidation(forMapping: mapping, manager: manager)

        let destContext = manager.destinationContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "path", ascending: true)]

        let results = try destContext.fetch(fetchRequest)
        for account in results {
            print(account.value(forKey: "path") as? String)
            if account.value(forKey: "parent") == nil && account.value(forKey: "name") as? String != LocalisationManager.getLocalizedName(.accounts) {
                throw MigrationError.acountHasNoParent
            }

            if account.value(forKey: "type") == nil {
                throw MigrationError.accountHasNotType
            }
        }
    }

    private enum MigrationError: AppError {
        case acountHasNoParent
        case accountHasNotType
    }

    // FUNCTION($entityPolicy, "activeForIsHidden:" , $source.isHidden)
    @objc func activeFor(isHidden: NSNumber) -> NSNumber {
        if isHidden.boolValue {
            return NSNumber(integerLiteral: 0) // swiftlint:disable:this compiler_protocol_init
        } else {
            return NSNumber(integerLiteral: 1) // swiftlint:disable:this compiler_protocol_init
        }
    }

    private func getOrCreateAccount(name: String, context: NSManagedObjectContext) throws -> NSManagedObject {

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let results = try context.fetch(fetchRequest)

        guard results.last == nil else {return results[0]}

        let entity = NSEntityDescription.entity(forEntityName: "Account", in: context)!
        let accountInstance = NSManagedObject(entity: entity, insertInto: context)
        accountInstance.setValue(UUID(), forKey: "id")
        accountInstance.setValue(name, forKey: "name")
        accountInstance.setValue(name, forKey: "path")
        accountInstance.setValue(true, forKey: "active")

        accountInstance.setValue(Date(), forKey: "createDate")
        accountInstance.setValue(Date(), forKey: "modifyDate")
        accountInstance.setValue(false, forKey: "createdByUser")
        accountInstance.setValue(false, forKey: "modifiedByUser")
        return accountInstance
    }

    private func getAccountTypeBy(_ name: AccountType.NameEnum, context: NSManagedObjectContext) -> NSManagedObject {
        let request = NSFetchRequest<NSManagedObject>(entityName: "AccountType")
        request.predicate = NSPredicate(format: "name = %@", name.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        if let accountType = try? context.fetch(request).first {
            return accountType
        } else {
            fatalError("AccounType with name \"\(name)\"")
        }
    }

    private func creteAccountType(id: UUID = UUID(), parent: NSManagedObject? = nil, name: String, classification: ClassificationEnum,
                                  hasCurrency: Bool = false, linkedAccountType: NSManagedObject? = nil, hasHolder: Bool = false,
                                  hasKeeper: Bool = false, hasInitialBalance: Bool = false, balanceCalcFullTime: Bool = false,
                                  canBeDeleted: Bool = false, canChangeActiveStatus: Bool = false, canBeRenamed: Bool = false,
                                  canBeCreatedByUser: Bool = false, allowsTransactions: Bool = true, keeperGroup: KeeperGroup = .none,
                                  checkAmountBeforDeactivate: Bool = false, priority: Int16 = 1, context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: "AccountType", in: context)!
        let instance = NSManagedObject(entity: entity, insertInto: context)

        instance.setValue(id, forKey: "id")
        instance.setValue(Date(), forKey: "createDate")
        instance.setValue(Date(), forKey: "modifyDate")
        instance.setValue(false, forKey: "createdByUser")
        instance.setValue(false, forKey: "modifiedByUser")
        instance.setValue(name, forKey: "name")
        instance.setValue(true, forKey: "active")
        instance.setValue(classification.rawValue, forKey: "classification")
        instance.setValue(hasCurrency, forKey: "hasCurrency")
        instance.setValue(hasHolder, forKey: "hasHolder")
        instance.setValue(hasKeeper, forKey: "hasKeeper")
        instance.setValue(hasInitialBalance, forKey: "hasInitialBalance")
        if let parent = parent, (parent.value(forKey: "balanceCalcFullTime") as? Bool) == true {
            instance.setValue(true, forKey: "balanceCalcFullTime")
        } else {
            instance.setValue(balanceCalcFullTime, forKey: "balanceCalcFullTime")
        }
        instance.setValue(canBeDeleted, forKey: "canBeDeleted")
        instance.setValue(canChangeActiveStatus, forKey: "canChangeActiveStatus")
        instance.setValue(canBeRenamed, forKey: "canBeRenamed")
        instance.setValue(canBeCreatedByUser, forKey: "canBeCreatedByUser")
        instance.setValue(checkAmountBeforDeactivate, forKey: "checkAmountBeforDeactivate")
        if let parent = parent {
            instance.setValue(NSSet(set: [parent]), forKey: "parents")
        }
        instance.setValue(allowsTransactions, forKey: "allowsTransactions")
        if hasKeeper {
            instance.setValue(keeperGroup.rawValue, forKey: "keeperGroup")
        } else {
            instance.setValue(KeeperGroup.none.rawValue, forKey: "keeperGroup")
        }
        instance.setValue(priority, forKey: "priority")

        instance.setValue(linkedAccountType, forKey: "linkedAccountType")
        linkedAccountType?.setValue(hasInitialBalance, forKey: "hasInitialBalance")
        return instance
    }

    private func seedAccountTypes(context: NSManagedObjectContext) {

        let accounting = creteAccountType(name: "Accounting", classification: .none, allowsTransactions: false, priority: 1, context: context)

        let creditorsConsolid = creteAccountType(parent: accounting, name: "Creditors consolidation", classification: .liabilities, balanceCalcFullTime: true, allowsTransactions: false, priority: 1, context: context)
        let creditor = creteAccountType(parent: creditorsConsolid, name: "Creditor", classification: .liabilities, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .nonCash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let moneyConsolid = creteAccountType(parent: accounting, name: "Money consolidation", classification: .assets, balanceCalcFullTime: true, allowsTransactions: false, priority: 1, context: context)
        let creditCard = creteAccountType(parent: moneyConsolid, name: "Credit Card", classification: .assets, hasCurrency: true, linkedAccountType: creditor, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .bank, checkAmountBeforDeactivate: true, priority: 3, context: context)
        let debitCard = creteAccountType(parent: moneyConsolid, name: "Debit Card", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .bank, checkAmountBeforDeactivate: true, priority: 2, context: context)
        let cash = creteAccountType(parent: moneyConsolid, name: "Cash", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .cash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let debtorsConsolid = creteAccountType(parent: accounting, name: "Debtors consolidation", classification: .assets, balanceCalcFullTime: true, allowsTransactions: false, priority: 1, context: context)
        let debtor = creteAccountType(parent: debtorsConsolid, name: "Debtor", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperGroup: .nonCash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let incomeConsolid = creteAccountType(parent: accounting, name: "Income consolidation", classification: .liabilities, hasCurrency: true, allowsTransactions: false, priority: 1, context: context)

        let expenseConsolid = creteAccountType(parent: accounting, name: "Expense consolidation", classification: .assets, hasCurrency: true, allowsTransactions: false, priority: 1, context: context)

        let capitalConsolid = creteAccountType(parent: accounting, name: "Capital consolidation", classification: .liabilities, hasCurrency: true, balanceCalcFullTime: true, priority: 1, context: context)

        let assetsCategoryConsolid = creteAccountType(parent: accounting, name: "Liabilities category consolidation", classification: .liabilities, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, allowsTransactions: false, priority: 1, context: context)

        let liabilityCategoryConsolid = creteAccountType(parent: accounting, name: "Assets category consolidation", classification: .assets, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, allowsTransactions: false, priority: 2, context: context)

        let liabilitiesCategory = creteAccountType(name: "Liabilities category", classification: .liabilities, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: false, priority: 1, context: context)
        liabilitiesCategory.setValue(NSSet(set: [liabilityCategoryConsolid, incomeConsolid, capitalConsolid, liabilitiesCategory]), forKey: "parents")

        let assetsCategory = creteAccountType(name: "Assets category", classification: .assets, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: false, priority: 2, context: context)
        assetsCategory.setValue(NSSet(set: [assetsCategoryConsolid, expenseConsolid, assetsCategory]), forKey: "parents")

        let expenseBeforeAccountingPeriod = creteAccountType(name: "Expense before accounting period", classification: .assets, hasCurrency: true, canBeDeleted: false, canChangeActiveStatus: true, canBeRenamed: false, canBeCreatedByUser: false, checkAmountBeforDeactivate: true, priority: 1, context: context)
    }

    @objc enum ClassificationEnum: Int16 {
        case none = 0
        case assets = 1
        case liabilities = 2
    }

    @objc enum KeeperGroup: Int16 {
        case none = 0
        case cash = 1
        case bank = 2
        case nonCash = 3
        case any = 4
    }
    // swiftlint:enable line_length
}
