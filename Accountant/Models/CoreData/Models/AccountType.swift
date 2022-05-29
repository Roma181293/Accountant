//
//  AccountType.swift
//  Accountant
//
//  Created by Roman Topchii on 29.05.2022.
//

import Foundation
import CoreData

class AccountType: BaseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Keeper> {
        return NSFetchRequest<Keeper>(entityName: "AccountType")
    }

    @NSManaged public var name: String
    @NSManaged public var parents: Set<AccountType>!
    @NSManaged public var children: Set<AccountType>!
    @NSManaged public var hasCurrency: Bool
    @NSManaged public var hasLinkedAccount: Bool
    @NSManaged public var hasHolder: Bool
    @NSManaged public var hasKeeper: Bool
    @NSManaged public var balanceCalcFullTime: Bool
    @NSManaged public var canBeDeleted: Bool
    @NSManaged public var canChangeActiveStatus: Bool
    @NSManaged public var canBeRenamed: Bool
    @NSManaged public var canBeCreatedByUser: Bool
    @NSManaged public var checkAmountBeforDeactivate: Bool
    @NSManaged public var priopity: Int16
}

extension AccountType {
    convenience init(id: UUID = UUID(), parent: AccountType? = nil, name: String, hasCurrency: Bool = false,
                     hasLinkedAccount: Bool = false, hasHolder: Bool = false, hasKeeper: Bool = false,
                     balanceCalcFullTime: Bool = false, canBeDeleted: Bool = false, canChangeActiveStatus: Bool = false,
                     canBeRenamed: Bool = false, canBeCreatedByUser: Bool = false,
                     checkAmountBeforDeactivate: Bool = false, priority: Int16 = 1, context: NSManagedObjectContext) {

        self.init(id: id, context: context)
        self.name = name
        self.hasCurrency = hasCurrency
        self.hasLinkedAccount = hasLinkedAccount
        self.hasHolder = hasHolder
        self.hasKeeper = hasKeeper
        if let parent = parent, parent.balanceCalcFullTime == true {
            self.balanceCalcFullTime = parent.balanceCalcFullTime
        }
        self.balanceCalcFullTime = balanceCalcFullTime
        self.canBeDeleted = canBeDeleted
        self.canChangeActiveStatus = canChangeActiveStatus
        self.canBeRenamed = canBeRenamed
        self.checkAmountBeforDeactivate = checkAmountBeforDeactivate
    }

    static func seedAccountTypes(context: NSManagedObjectContext) {
        // swiftlint:disable line_length
        let accounting = AccountType(name: "Accounting", priority: 1, context: context)

        let moneyConsolid = AccountType(parent: accounting, name: "Money consolidation", balanceCalcFullTime: true, priority: 1, context: context)
        let creditCard = AccountType(parent: moneyConsolid, name: "Credit Card", hasCurrency: true, hasLinkedAccount: true, hasHolder: true, hasKeeper: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 3, context: context)
        let debitCard = AccountType(parent: moneyConsolid, name: "Debit Card", hasCurrency: true, hasLinkedAccount: false, hasHolder: true, hasKeeper: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 2, context: context)
        let cash = AccountType(parent: moneyConsolid, name: "Cash", hasCurrency: true, hasLinkedAccount: false, hasHolder: true, hasKeeper: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let debtorsConsolid = AccountType(parent: accounting, name: "Debtors consolidation", balanceCalcFullTime: true, priority: 1, context: context)
        let debtor = AccountType(parent: debtorsConsolid, name: "Debtor", hasCurrency: true, hasLinkedAccount: false, hasHolder: true, hasKeeper: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let creditorsConsolid = AccountType(parent: accounting, name: "Creditors consolidation", balanceCalcFullTime: true, priority: 1, context: context)
        let creditor = AccountType(parent: creditorsConsolid, name: "Creditor", hasCurrency: true, hasLinkedAccount: false, hasHolder: true, hasKeeper: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let incomeConsolid = AccountType(parent: accounting, name: "Income consolidation", hasCurrency: true, priority: 1, context: context)

        let expenseConsolid = AccountType(parent: accounting, name: "Expense consolidation", hasCurrency: true, priority: 1, context: context)

        let capitalConsolid = AccountType(parent: accounting, name: "Capital consolidation", hasCurrency: true, balanceCalcFullTime: true, priority: 1, context: context)

        let category = AccountType(name: "Category", hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)
        category.parents = [incomeConsolid, expenseConsolid, capitalConsolid, category]
        // swiftlint:enable line_length
    }
}
