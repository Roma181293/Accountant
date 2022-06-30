//
//  AccountTypeHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation
import CoreData

class AccountTypeHelper {

    class func getBy(_ name: AccountType.NameEnum, context: NSManagedObjectContext) -> AccountType {
        let request = AccountType.fetchRequest()
        request.predicate = NSPredicate(format: "\(Schema.AccountType.name.rawValue) = %@", name.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: Schema.AccountType.name.rawValue, ascending: true)]

        if let accountType = try? context.fetch(request).first {
            return accountType
        } else {
            fatalError("AccounType with name \"\(name)\"")
        }
    }

    class func getBy(_ id: UUID, context: NSManagedObjectContext) -> AccountType? {
        let request = AccountType.fetchRequest()
        request.predicate = NSPredicate(format: "\(Schema.AccountType.id.rawValue) = %@", id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: Schema.AccountType.name.rawValue, ascending: true)]
        return try? context.fetch(request).first
    }

    class func seedAccountTypes(context: NSManagedObjectContext) {
        // swiftlint:disable line_length
        let accounting = AccountType(name: "Accounting", classification: .none, isConsolidation: true, priority: 1, context: context)

        let creditorsConsolid = AccountType(parent: accounting, name: "Creditors consolidation", classification: .liabilities, balanceCalcFullTime: true, isConsolidation: true, priority: 1, context: context)
        let creditor = AccountType(parent: creditorsConsolid, name: "Creditor", classification: .liabilities, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperType: .nonCash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let moneyConsolid = AccountType(parent: accounting, name: "Money consolidation", classification: .assets, balanceCalcFullTime: true, isConsolidation: true, priority: 1, context: context)
        let creditCard = AccountType(parent: moneyConsolid, name: "Credit Card", classification: .assets, hasCurrency: true, linkedAccountType: creditor, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperType: .bank, checkAmountBeforDeactivate: true, priority: 3, context: context)
        let debitCard = AccountType(parent: moneyConsolid, name: "Debit Card", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperType: .bank, checkAmountBeforDeactivate: true, priority: 2, context: context)
        let cash = AccountType(parent: moneyConsolid, name: "Cash", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperType: .cash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let debtorsConsolid = AccountType(parent: accounting, name: "Debtors consolidation", classification: .assets, balanceCalcFullTime: true, isConsolidation: true, priority: 1, context: context)
        let debtor = AccountType(parent: debtorsConsolid, name: "Debtor", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, keeperType: .nonCash, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let incomeConsolid = AccountType(parent: accounting, name: "Income consolidation", classification: .liabilities, hasCurrency: true, isConsolidation: true, priority: 1, context: context)

        let expenseConsolid = AccountType(parent: accounting, name: "Expense consolidation", classification: .assets, hasCurrency: true, isConsolidation: true, priority: 1, context: context)

        let capitalConsolid = AccountType(parent: accounting, name: "Capital consolidation", classification: .liabilities, hasCurrency: true, balanceCalcFullTime: true, priority: 1, context: context)

        let assetsCategoryConsolid = AccountType(parent: accounting, name: "Liabilities category consolidation", classification: .liabilities, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, isConsolidation: true, priority: 1, context: context)

        let liabilityCategoryConsolid = AccountType(parent: accounting, name: "Assets category consolidation", classification: .assets, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, isConsolidation: true, priority: 2, context: context)

        let liabilitiesCategory = AccountType(name: "Liabilities category", classification: .liabilities, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)
        liabilitiesCategory.parents = [liabilityCategoryConsolid, incomeConsolid, capitalConsolid, liabilitiesCategory]

        let assetsCategory = AccountType(name: "Assets category", classification: .assets, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)
        assetsCategory.parents = [assetsCategoryConsolid, expenseConsolid, assetsCategory]
        // swiftlint:enable line_length
    }
}
