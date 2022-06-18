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

    @NSManaged public var name: String
    @NSManaged public var active: Bool
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
        self.active = true
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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountType> {
        return NSFetchRequest<AccountType>(entityName: "AccountType")
    }
}
