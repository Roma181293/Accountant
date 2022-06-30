//
//  Account.swift
//  Accountant
//
//  Created by Roman Topchii on 08.03.2022.
//

import Foundation
import CoreData

final class Account: BaseEntity {

    @NSManaged public var active: Bool
    @NSManaged public var name: String
    @NSManaged public var path: String
    @NSManaged public var type: AccountType
    @NSManaged public var bankAccount: BankAccount?
    @NSManaged public var currency: Currency?
    @NSManaged public var directChildren: Set<Account>!
    @NSManaged public var holder: Holder?
    @NSManaged public var keeper: Keeper?
    @NSManaged public var linkedAccount: Account?
    @NSManaged public var parent: Account?
    @NSManaged public var transactionItems: Set<TransactionItem>!

    convenience init(parent: Account?, name: String, type: AccountType, currency: Currency?, keeper: Keeper?,
                     holder: Holder?, createdByUser: Bool = true,
                     createDate: Date = Date(), context: NSManagedObjectContext) {

        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        if let parent = parent {
            self.parent = parent
            self.active = parent.active
        } else {
            self.active = true
        }
        self.name = name
        self.path = pathCalc
        self.currency = currency
        self.keeper = keeper
        self.holder = holder
        self.type = type
    }

    convenience init(parent: Account, name: String, createdByUser: Bool = true,
                     createDate: Date = Date(), context: NSManagedObjectContext) {

        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.parent = parent
        self.name = name
        self.path = pathCalc
        self.currency = parent.currency
        if let type = parent.type.defultChildType {
            self.type = type
        } else {
            fatalError("if parent.type allow create child account then it shoud be presented")
        }
        self.active = parent.active
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }
}
