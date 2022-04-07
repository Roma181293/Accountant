//
//  TransactionItem.swift
//  Accountant
//
//  Created by Roman Topchii on 25.07.2021.
//

import Foundation
import CoreData

final class TransactionItem: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionItem> {
        return NSFetchRequest<TransactionItem>(entityName: "TransactionItem")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var type: Int16
    @NSManaged public var account: Account?
    @NSManaged public var transaction: Transaction?
    @NSManaged public var createDate: Date?
    @NSManaged public var createdByUser: Bool
    @NSManaged public var modifyDate: Date?
    @NSManaged public var modifiedByUser: Bool

    
    convenience init(transaction: Transaction, type: AccountingMethod, account: Account, amount: Double, createdByUser: Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
        self.account = account
        self.amount = amount
        self.transaction = transaction
        self.type = type.rawValue
        self.createdByUser = createdByUser
        self.createDate = createDate
        self.modifiedByUser = createdByUser
        self.modifyDate = createDate
    }
    
    static func moveTransactionItemsFrom(oldAccount: Account, newAccount: Account, modifiedByUser: Bool = true, modifyDate: Date = Date()){
        for item in oldAccount.transactionItemsList {
            item.account = newAccount
            item.modifyDate = modifyDate
            item.modifiedByUser = modifiedByUser
        }
    }
}
