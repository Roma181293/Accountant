//
//  TransactionItem.swift
//  Accountant
//
//  Created by Roman Topchii on 25.07.2021.
//

import Foundation
import CoreData

final class TransactionItem: BaseEntity {

    @objc enum TypeEnum: Int16 {
        case credit = 0
        case debit = 1
    }

    @NSManaged public var amount: Double
    @NSManaged public var amountInAccountingCurrency: Double
    @NSManaged public var type: TypeEnum
    @NSManaged public var account: Account?
    @NSManaged public var transaction: Transaction?

    convenience init(transaction: Transaction, type: TypeEnum, amount: Double, createdByUser: Bool = true,
                     createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.amount = amount
        self.amountInAccountingCurrency = 0
        self.transaction = transaction
        self.type = type
    }

    convenience init(transaction: Transaction, type: TypeEnum, account: Account?, amount: Double,
                     createdByUser: Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.account = account
        self.amount = amount
        self.amountInAccountingCurrency = 0
        self.transaction = transaction
        self.type = type
    }
    
    convenience init(transaction: Transaction,
                     type: TypeEnum,
                     account: Account? = nil,
                     amount: Double,
                     amountInAccountingCurrency: Double,
                     createdByUser: Bool = true,
                     createDate: Date = Date(),
                     context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.account = account
        self.amount = amount
        self.amountInAccountingCurrency = amountInAccountingCurrency
        self.transaction = transaction
        self.type = type
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionItem> {
        return NSFetchRequest<TransactionItem>(entityName: "TransactionItem")
    }
}
