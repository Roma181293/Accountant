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

    @objc enum KeeperGroup: Int16 {
        case none = 0
        case cash = 1
        case bank = 2
        case nonCash = 3
        case any = 4
    }

    @NSManaged public var name: String
    @NSManaged public var active: Bool
    @NSManaged public var classification: ClassificationEnum

    /// value of this property should has only one parent, otherwise cannot garantee correnct parent for linked account
    ///
    /// linkedAccountType inherit hasInitialBalance from current AccountType
    ///
    /// linkedAccountType should has classification != .none
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
    @NSManaged public var allowsTransactions: Bool
    @NSManaged public var keeperGroup: KeeperGroup
    @NSManaged public var priority: Int16

    convenience init(id: UUID = UUID(), parent: AccountType? = nil, name: String, classification: ClassificationEnum,
                     hasCurrency: Bool = false, linkedAccountType: AccountType? = nil, hasHolder: Bool = false,
                     hasKeeper: Bool = false, hasInitialBalance: Bool = false, balanceCalcFullTime: Bool = false,
                     canBeDeleted: Bool = false, canChangeActiveStatus: Bool = false, canBeRenamed: Bool = false,
                     canBeCreatedByUser: Bool = false, allowsTransactions: Bool = true, keeperGroup: KeeperGroup = .none,
                     checkAmountBeforDeactivate: Bool = false, priority: Int16 = 1, context: NSManagedObjectContext) {

        self.init(id: id, context: context)
        self.name = name
        self.active = true
        self.classification = classification
        self.hasCurrency = hasCurrency
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
        self.allowsTransactions = allowsTransactions
        if hasKeeper {
            self.keeperGroup = keeperGroup
        } else {
            self.keeperGroup = .none
        }
        self.priority = priority

        self.linkedAccountType = linkedAccountType
        linkedAccountType?.hasInitialBalance = hasInitialBalance
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountType> {
        return NSFetchRequest<AccountType>(entityName: "AccountType")
    }
}
