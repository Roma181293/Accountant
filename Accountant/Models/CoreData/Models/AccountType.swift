//
//  AccountType.swift
//  Accountant
//
//  Created by Roman Topchii on 29.05.2022.
//

import Foundation
import CoreData

class AccountType: BaseEntity {

    @objc enum ClassificationEnum: Int16 {
        case none = 0
        case assets = 1
        case liabilities = 2
    }
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountType> {
        return NSFetchRequest<AccountType>(entityName: "AccountType")
    }

    enum NameEnum: String {
        case accounting = "Accounting"
        case moneyConsolidation = "Money consolidation"
        case creditCard = "Credit Card"
        case debitCard = "Debit Card"
        case cash = "Cash"
        case debtorsConsolidation = "Debtors consolidation"
        case debtor = "Debtor"
        case creditorsConsolidation = "Creditors consolidation"
        case creditor = "Creditor"
        case incomeConsolidation = "Income consolidation"
        case expenseConsolidation = "Expense consolidation"
        case capitalConsolidation = "Capital consolidation"
        case liabilitiesCategoryConsolidation = "Liabilities category consolidation"
        case assetsCategoryConsolidation = "Assets category consolidation"
        case liabilitiesCategory = "Liabilities category"
        case assetsCategory = "Assets category"
    }

    @NSManaged public var name: String
    @NSManaged public var classification: ClassificationEnum
    @NSManaged public var linkedAccountType: AccountType?
    @NSManaged public var parents: Set<AccountType>!
    @NSManaged public var children: Set<AccountType>!
    @NSManaged public var hasCurrency: Bool
    @NSManaged public var hasHolder: Bool
    @NSManaged public var hasKeeper: Bool
    @NSManaged public var hasInitialBalance: Bool
    @NSManaged public var balanceCalcFullTime: Bool
    @NSManaged public var canBeDeleted: Bool
    @NSManaged public var canChangeActiveStatus: Bool
    @NSManaged public var canBeRenamed: Bool
    @NSManaged public var canBeCreatedByUser: Bool
    @NSManaged public var checkAmountBeforDeactivate: Bool
    @NSManaged public var isConsolidation: Bool
    @NSManaged public var priority: Int16

    convenience init(id: UUID = UUID(), parent: AccountType? = nil, name: String, classification: ClassificationEnum,
                     hasCurrency: Bool = false, linkedAccountType: AccountType? = nil, hasHolder: Bool = false,
                     hasKeeper: Bool = false, hasInitialBalance: Bool = false, balanceCalcFullTime: Bool = false,
                     canBeDeleted: Bool = false, canChangeActiveStatus: Bool = false, canBeRenamed: Bool = false,
                     canBeCreatedByUser: Bool = false, isConsolidation: Bool = false,
                     checkAmountBeforDeactivate: Bool = false, priority: Int16 = 1, context: NSManagedObjectContext) {

        self.init(id: id, context: context)
        self.name = name
        self.classification = classification
        self.hasCurrency = hasCurrency
        self.linkedAccountType = linkedAccountType
        self.hasHolder = hasHolder
        self.hasKeeper = hasKeeper
        self.hasInitialBalance = hasInitialBalance
        if let parent = parent, parent.balanceCalcFullTime == true {
            self.balanceCalcFullTime = parent.balanceCalcFullTime
        }
        self.balanceCalcFullTime = balanceCalcFullTime
        self.canBeDeleted = canBeDeleted
        self.canChangeActiveStatus = canChangeActiveStatus
        self.canBeRenamed = canBeRenamed
        self.canBeCreatedByUser = canBeCreatedByUser
        self.checkAmountBeforDeactivate = checkAmountBeforDeactivate
        if let parent = parent {
            self.parents = [parent]
        }
        self.isConsolidation = isConsolidation
        self.priority = priority
    }

    var childrenList: [AccountType] {
        return Array(children)
    }

    var hasChildren: Bool {
        return !childrenList.isEmpty
    }

    var hasMoreThenOneChildren: Bool {
        return childrenList.count > 1
    }

    var useCustomViewToCreateAccount: Bool {
        return hasHolder || hasKeeper || hasInitialBalance || linkedAccountType != nil
    }

    var defultChildType: AccountType? {
        if childrenList.isEmpty {
            return nil
        } else {
            return childrenList.sorted(by: {$0.priority > $1.priority}).first
        }
    }

    static func getBy(_ name: NameEnum, context: NSManagedObjectContext) -> AccountType {
        let request = AccountType.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        if let accountType = try? context.fetch(request).first {
            return accountType
        } else {
            fatalError("AccounType with name \"\(name)\"")
        }
    }
}

extension AccountType {
    static func seedAccountTypes(context: NSManagedObjectContext) {
        // swiftlint:disable line_length
        let accounting = AccountType(name: "Accounting", classification: .none, isConsolidation: true, priority: 1, context: context)

        let creditorsConsolid = AccountType(parent: accounting, name: "Creditors consolidation", classification: .liabilities, balanceCalcFullTime: true, isConsolidation: true, priority: 1, context: context)
        let creditor = AccountType(parent: creditorsConsolid, name: "Creditor", classification: .liabilities, hasCurrency: true, hasHolder: true, hasKeeper: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let moneyConsolid = AccountType(parent: accounting, name: "Money consolidation", classification: .assets, balanceCalcFullTime: true, isConsolidation: true, priority: 1, context: context)
        let creditCard = AccountType(parent: moneyConsolid, name: "Credit Card", classification: .assets, hasCurrency: true, linkedAccountType: creditor, hasHolder: true, hasKeeper: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 3, context: context)
        let debitCard = AccountType(parent: moneyConsolid, name: "Debit Card", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 2, context: context)
        let cash = AccountType(parent: moneyConsolid, name: "Cash", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, hasInitialBalance: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let debtorsConsolid = AccountType(parent: accounting, name: "Debtors consolidation", classification: .assets, balanceCalcFullTime: true, isConsolidation: true, priority: 1, context: context)
        let debtor = AccountType(parent: debtorsConsolid, name: "Debtor", classification: .assets, hasCurrency: true, hasHolder: true, hasKeeper: true, balanceCalcFullTime: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)

        let incomeConsolid = AccountType(parent: accounting, name: "Income consolidation", classification: .liabilities, hasCurrency: true, isConsolidation: true, priority: 1, context: context)

        let expenseConsolid = AccountType(parent: accounting, name: "Expense consolidation", classification: .assets, hasCurrency: true, isConsolidation: true, priority: 1, context: context)

        let capitalConsolid = AccountType(parent: accounting, name: "Capital consolidation", classification: .liabilities, hasCurrency: true, balanceCalcFullTime: true, priority: 1, context: context)

        let assetsCategoryConsolid = AccountType(parent: accounting, name: "Liabilities category consolidation", classification: .liabilities, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, isConsolidation: true, priority: 1, context: context)

        let liabilityCategoryConsolid = AccountType(parent: accounting, name: "Assets category consolidation", classification: .assets, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, isConsolidation: true, priority: 2, context: context)

        let liabilitiesCategory = AccountType(name: "Liabilities category", classification: .liabilities ,hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)
        liabilitiesCategory.parents = [liabilityCategoryConsolid, incomeConsolid, capitalConsolid, liabilitiesCategory]

        let assetsCategory = AccountType(name: "Assets category", classification: .assets, hasCurrency: true, canBeDeleted: true, canChangeActiveStatus: true, canBeRenamed: true, canBeCreatedByUser: true, checkAmountBeforDeactivate: true, priority: 1, context: context)
        assetsCategory.parents = [assetsCategoryConsolid, expenseConsolid, assetsCategory]
        // swiftlint:enable line_length
    }
}
